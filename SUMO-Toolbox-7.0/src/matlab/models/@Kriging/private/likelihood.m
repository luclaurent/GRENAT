function [out dout] = likelihood( this, F, hyperparameters, lambda )

% likelihood (SUMO)
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
%	[out dout] = likelihood( this, F, hyperparameters, lambda )
%
% Description:
%	Constructs model and/or returns likelihood estimation

	%% correlation
	[this err dpsi] = updateCorrelation( this, hyperparameters, lambda );
	if ~isempty(err)
		out = +Inf;
		dout = zeros( 1, size( hyperparameters, 2 ) );
		return;
	end
	
	%% regression (get least squares solution)
	[this err residual sigma2] = updateRegression( this, F );
	if ~isempty(err)
		out = +Inf;
		dout = zeros( 1, size( hyperparameters, 2 ) );
		return;
	end

    %% likelihood
	
	% Number of samples...
    n = size( this.values, 1 );
	
	% Negative of concentrated log-likelihood
    lnDetPsi=sum(log(diag(this.C))); % sum(log()) = log(prod())
    %lnDetPsi=log(prod(diag(C))); -> is sometimes -Inf
    out=(n/2).*log(sum(sigma2)) + lnDetPsi;

    % Derivative
    if nargout > 1
		dout = zeros( length(hyperparameters), 1 );

		%% Derivatives (analytical)
		% TODO:
		% - fix some small things when modeling multiple outputs
		% at the moment the derivatives for the first output is calculated
		% - lowRank approx. use C11 (fast) or full C (slow) ?
		% atm: C11 (fast) is used
		% - optimize and use adjoint method altogether
		for i=1:length(dpsi)
			% Partial derivative to hyperparameters i
			dpsiCurr = dpsi{i} + dpsi{i}';

			%dout(i,:) = residual2(:,1)' * invpsi * dpsiCurr * invpsi *
			%residual2(:,1); % original formula

			% without inverse
			resinvpsi = (this.C(1:this.rank,1:this.rank)' \ residual(:,1));
			
			dout(i,:) = resinvpsi' * dpsiCurr(this.P(1:this.rank),this.P(1:this.rank)) * resinvpsi;
			%dout(i,:) = 2 .* (resinvpsi' * dpsiCurr(P,P) * resinvpsi); % faster ?
			dout(i,:) = dout(i,:) ./ (2*sigma2(1,1));

			tmp = this.C(1:this.rank,1:this.rank)' \ (this.C(1:this.rank,1:this.rank) \ dpsiCurr(this.P(1:this.rank),this.P(1:this.rank))); % expensive
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

end
