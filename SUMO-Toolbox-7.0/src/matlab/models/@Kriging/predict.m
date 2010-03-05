function [y sigma2] = predict(this, x)

% predict (SUMO)
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
%	[y sigma2] = predict(this, x)
%
% Description:
%
%
%

	%% Constants
	[n m] = size( this.samples );
    [nx mx] = size(x);
	dim_out = length(this.sigma2); % number of outputs
	
	%% Preprocessing
	x = (x - this.inputScaling(ones(nx,1),:)) ./ this.inputScaling(2.*ones(nx,1),:);
	
	%% Regression function
	% Orthogonal polynomial coding
	order = max(this.options.maxOrder);
	xT = zeros( nx, order*mx );
	for j=1:mx
		levels = this.levels{j};
		
		k = this.options.maxOrder(j) + 1;
		avg = mean(levels);
		delta = levels(2,:) - levels(1,:);

		xT(:,[j:mx:end]) = sqrt(k) .*polynomialCoding( x(:,j), avg, k, delta ) ./ repmat(this.polyScaling(j, :), nx, 1 );
	end
	
	% model matrix (this.regressionFcn is degrees matrix)
    trendx = buildVandermondeMatrix( xT, this.regressionFcn, cfix( @powerBase, 2*n)  );
    poly = trendx * this.alpha;	
	
    %% GP part
    % distance matrix
	nPoints = 1:nx;
	nSamples = this.P(1:this.rank);
	distx = this.samples(nSamples(ones(nx, 1),:),:) - x(nPoints(ones(this.rank, 1),:)',:);

    corr = feval( this.correlationFcn, this.hyperparameters, distx );
    corr = reshape(corr, nx, this.rank); % K*'
   
    gp = corr * this.gamma;
 
    % scaled prediction
    sy = poly + gp;
	y = this.outputScaling(ones(nx,1),:) + this.outputScaling(2.*ones(nx,1),:) .* sy;
	
    % Calculate sigma
	if nargout > 1		
		corrt = this.C(1:this.rank,1:this.rank) \ corr';
        u = this.Ft.' * corrt - trendx.';
        v = this.R \ u;
		
		tmp = (1 + sum(v.^2,1) - sum(corrt.^2,1))';
		sigma2 = repmat(this.sigma2,nx,1) .* repmat(tmp,1,dim_out);
	end
end
