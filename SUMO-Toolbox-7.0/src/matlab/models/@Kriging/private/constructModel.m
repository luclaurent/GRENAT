function this = constructModel( this )

% constructModel (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev$
%
% Signature:
%	this = constructModel( this )
%
% Description:
%	Constructs model

    % Number of samples...
    n = size( this.values, 1 );

	if nargout > 1
		[psi dpsi] = correlationMatrix(this, hyperparameters, lambda);
	else
		psi = correlationMatrix(this, hyperparameters, lambda);
	end

	if this.options.lowRankApproximation
		[C P] = cholincsp(psi); %, -Inf);
		
		try
			if ~spok(C)
				lastwarn
				a = 50;
			end
		catch e
			disp( e.getReport() );
			dbstop;
		end
		
		rank = size(C,1);
		C1 = C(1:rank,:);
		C11 = C1(:,1:rank);
		
		if rank < n
			fprintf(1,'WARNING: correlation matrix is rank %i of %i\n', rank, n );
		else
			e = psi + psi' - eye(n);
			e = e(P,P) - C'*C;
			if any( abs(e) > 1e-10 )
				dbstop;
			end
		end
	else
		%% STANDARD
		% Cholesky factorization with check for pos. def.
		[C rd] = chol(psi);
		P = 1:n;
		rank = size(C,2);

		if rd > 0 % not positive definite
			%fprintf( 1, 'WARNING: correlation matrix is ill-conditioned. Using
			%low rank approximation of %i / %i\n', rank, n );
			% penalty
			out = +Inf;
			dout = zeros( 1, size( hyperparameters, 2 ) );
			return
		end
	end
	C = C';
  
    % NOTE:
    % C  is lower triangular
    % C' is upper triangular 
    % C*C' = psi(1:P,1:P) (IF rank == n)

    %% Get least squares solution

    % decorrelation transformation:
    % Yt - Ft*coeff = inv(C)Y - inv(C)F*coeff
    % so Ft = inv(C)F <=> C Ft = F -> solve for Ft

    % Forward substitution
    Ft = C \ this.F(P,:); % T1

    % Bayesian Linear regression:
    %tmp = inv(this.F'*this.F + A)*(this.F'*this.F * betaPrior + A*betaPriorMean

    % Ft can now be ill-conditioned -> QR factorisation of Ft = QG'
    [Q R] = qr(Ft,0);
    if  rcond(R) < 1e-10
		% Check   F  
		disp('WARNING: F/Ft is ill-conditioned');
		out = +Inf;
		dout = +Inf;
		return;
    end

    % Now we know Ft is good, compute Yt
    % so Yt = inv(C)Y <=> C Yt = Y -> solve for Yt
    Yt = C \ this.values(P,:);

    % transformation is done, now fit it:
    % so Q is unitary = orthogonal for real values -> inv(Q) = Q'
    alpha = R \ (Q'*Yt); % polynomial coefficients

    % compute variance
    residual = Yt - Ft*alpha;
    sigma2 = sum(residual.^2)/n;

    %residual2 = this.values - this.F * alpha % simple
    %residual2 = C * residual; % take correlation into account for real variance
    % sigma2 = (residual' * T2) ./ n; % simple

    %% likelihood
    
    % Negative of concentrated log-likelihood
    lnDetPsi=sum(log(diag(C))); % sum(log()) = log(prod())
    %lnDetPsi=log(prod(diag(C))); -> is sometimes -Inf
    out=(n/2).*log(sum(sigma2)) + lnDetPsi;

    % Derivative
    if nargout > 1
		dout = zeros( length(hyperparameters), 1 );

		%% Derivatives (analytical)
		% TODO: fix some small things when modeling multiple outputs
		% at the moment the derivatives for the first output is calculated
		for i=1:length(dpsi)
			% Partial derivative to hyperparameters i
			dpsiCurr = dpsi{i} + dpsi{i}';
			%dpsiCurr = dpsi{i};

			%dout(i,:) = residual2(:,1)' * invpsi * dpsiCurr * invpsi *
			%residual2(:,1); % original formula

			% without inverse
			resinvpsi = (C' \ residual(:,1));
			
			dout(i,:) = resinvpsi' * dpsiCurr(P,P) * resinvpsi;
			%dout(i,:) = 2 .* (resinvpsi' * dpsiCurr(P,P) * resinvpsi); % faster ?
			dout(i,:) = dout(i,:) ./ (2*sigma2(1,1));

			tmp = C' \ (C \ dpsiCurr(P,P)); % expensive
			%tmp = 2 .* (C' \ (C \ dpsiCurr(P,P))); % faster ? but not correct
			dout(i,:) = dout(i,:) -0.5 * trace(tmp);
		end
		dout = -dout;

		%{
		%% Adjoint
		T1 = residual; %C \ (C * residual);
		T2 = C' \ T1;

		% seed
		T2adj = - (C * residual) ./ (2.*sigma2);
		L1 = C'; L2 = C;

		% reverse backward substitution
		[L1adj, T1adj] = reverse_backwardSub( T2adj, L1, T2 );

		% reverse forward substitution
		L2adj = reverse_forwardSub( T1adj, L2, T1 );

		% adjoint of the log of the determinant of psi
		L3adj = diag( - 1 ./ diag( L2 ) );

		Ladj = L1adj' + L2adj + L3adj;

		% reverse cholesky factorisation
		Radj = sparse( reverse_cholesky( L2, Ladj ) );

		dout = zeros( length(hyperparameters), 1 );

		for i=1:length(dpsi)
			% Partial derivative to hyperparameters i and lambda (optional)
			% Take negative
			dout(i,:) = -sum( sum( dpsi{i}' .* Radj ) );
		end
		%}
    else
        dout = [];
    end

    % What is needed for prediction
    % polynomial part: alpha
    % correlation part: gamma, hyperparameters, corr func
    % prediction variance: sigma2, C, R, Ft
    if  nargout > 2
        % Add L1 parameters (generated during the fitting process)
        this.alpha = alpha; % Regression coefficients
		
		if this.options.lowRankApproximation
			% inv(C11') * inv(C) * values or (inv(C)*residual)
			this.gamma = C11 \ residual;
			%this.gamma = (residual' / C11)';
			
			%{
			DEBUG:
			[C2 rd] = chol(psi);
			C2 = C2'
		    Ft2 = C2 \ this.F;
		    [Q2 R2] = qr(Ft2,0);
		    Yt2 = C2 \ this.values;
		    alpha2 = R2 \ (Q2'*Yt2); % polynomial coefficients	
			residual2 = Yt2 - Ft2*alpha2;
			gamma2 = (residual2' / C2)';
			e = abs(this.gamma - gamma2(P,:))
			if any( e > 1e-10 )
				dg= 5
			end
			%}
		else
			%this.gamma = (residual' / C)';
			this.gamma = (C' \ residual);
		end

        this.hyperparameters = hyperparameters;
        this.C = C;
        this.Ft = Ft;
        this.R = R;

        this.rank = rank; % m
        this.P = P;

        % stochastic process variance
        % sigma2 is needed for prediction variance
        this.sigma2 = this.outputScaling(2,:).^2.*sigma2; % unscaled
        %this.sigma2 = sigma2; % scaled
    end
end
