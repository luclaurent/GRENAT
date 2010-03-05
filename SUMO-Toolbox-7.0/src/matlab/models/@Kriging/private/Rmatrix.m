function out = Rmatrix(this, degrees)

% Rmatrix (SUMO)
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
%	out = Rmatrix(this, degrees)
%
% Description:
%	Calculates posterior variance matrix of beta polynomial

    % experimental
    [n p] = size(this.samples);
   
    R = 1;
	nrInter = prod( this.options.maxOrder+1 );
	for j=1:p
		% Regression part
		levels = this.levels{j};
		
		k = this.options.maxOrder(j) + 1;
		m = mean(levels);
		delta = levels(2,:) - levels(1,:);
		
		Uj = sqrt(k) .* polynomialCoding( levels, m, k, delta ) ./ repmat(this.polyScaling(j, :), k, 1 );
		%Uj = polynomialCoding( levels, m, k, delta ) ./ repmat(this.polyScaling(j, :), k, 1 );
		Uj = [ones(k,1) Uj];
		
		% Correlation part		
		nSamples = 1:k;
		idx = nSamples(ones(k, 1),:);
		a = tril( idx, -1 ); % idx
		b = triu( idx, 1 )'; % idx
		a = a(a~=0); % remove zero's
		b = b(b~=0); % remove zero's
		dist = levels(a,:) - levels(b,:);
		[dummy dummy dummy rho] = this.correlationFcn( this.hyperparameters(:,j), dist );

		o = (1:k)';
		idx = find(rho > 0);
		psi_j = sparse([a(idx,:); o], [b(idx,:); o], [rho(idx,:); zeros(k,1)]);
		psi_j = (psi_j + psi_j') + diag( ones(k,1) );
		
		%invUj = inv(Uj);
		%Rj =  invUj * psi_j  * invUj';
		Rj = (Uj' * psi_j * Uj) ./ (k.*k);
		
		% only keep diagonal if R becomes too large
		if nrInter > 250
			Rj = diag(Rj) ./ Rj(1,1); % diagonal, scaling
			%Rj = diag(Rj); % diagonal, no scaling
		else
			Rj = Rj ./ Rj(1,1); % full, scaling
		end
		R = kron( R, Rj );
	end
	
	if nrInter > 250
		o = 1:length(R);
		out = sparse( o, o, R );
	else
		out = R;
	end
    return;
    %}
    
    % blind kriging paper
    h21 = (this.levels(2,:)-this.levels(1,:));
    h31 = (this.levels(3,:)-this.levels(1,:));
	[dummy dummy dummy rho] = this.correlationFcn( this.hyperparameters, [h21 ; h31] );
	
	% TODO: cubic
	%h41 = (this.levels(4,:)-this.levels(1,:));
    %[dummy dummy dummy rho] = this.correlationFcn( this.hyperparameters, [h21 ; h31 ; h41] );
    
    if this.options.maxOrder == 2
        rl = (3-3.*rho(2,:))./(3+4.*rho(1,:)+2.*rho(2,:));
        rq = (3-4.*rho(1,:)+rho(2,:))./(3+4.*rho(1,:)+2.*rho(2,:));
		
        rtotal = [rl rq];
	elseif this.options.maxOrder == 3
        rl = (4+2.*rho(1,:)-15./5.*rho(2,:)-18./5*rho(3,:)) ...
			./(4+6.*rho(1,:)+4.*rho(2,:)+2.*rho(3,:));
        rq = (4-2.*rho(1,:)-4.*rho(2,:)+2.*rho(3,:)) ./ ...
			(4+6.*rho(1,:)+4.*rho(2,:)+2.*rho(3,:));
        rc = (4-6.*rho(1,:)+12./5.*rho(2,:)-2./5.*rho(3,:)) ./ ...
			(4+6.*rho(1,:)+4.*rho(2,:)+2.*rho(3,:));
		
        rtotal = [rl rq rc];
    else
        ezdf=ferse; % error
    end

    RM = buildVandermondeMatrix( rtotal, degrees, cfix( @powerBase, size(degrees,2)) );
	
    o = 1:length(RM);
    out = sparse( o, o, RM );
end
