function [dy dsigma2] = predict_derivatives(this, x)

% predict_derivatives (SUMO)
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
%	[dy dsigma2] = predict_derivatives(this, x)
%
% Description:
%	Predicts the derivatives of the prediction mean
%	   and prediction variance
%

	%% Constants
    [n m] = size( this.samples );
    [nx mx] = size(x);
	dim_out = length(this.sigma2);

	assert( nx == 1, 'Prediction of derivatives supports only one point at a time.' );
    
	%% Preprocessing
	x = (x - this.inputScaling(ones(nx,1),:)) ./ this.inputScaling(2.*ones(nx,1),:);

    %% Regression function
	% Orthogonal polynomial coding
	order = max(this.options.maxOrder);
	xT = zeros( nx, order*mx );
	dxT = zeros( mx, order*mx ); % rows: derivative of variable i
	for j=1:mx
		levels = this.levels{j};
		
		k = this.options.maxOrder(j) + 1;
		avg = mean(levels);
		delta = levels(2,:) - levels(1,:);

		[U dU] = polynomialCoding( x(:,j), avg, k, delta );
		xT(:,j:mx:end) = sqrt(k) .* U ./ repmat(this.polyScaling(j, :), nx, 1 );
		
		% only derive j'th variable
		dxT(j,j:mx:end) = sqrt(k) .* dU ./ repmat(this.polyScaling(j, :), nx, 1 );
		dxT([1:j-1 j+1:mx],j:mx:end) = xT(ones(mx-1,1),j:mx:end);
	end
	
	% model matrix (this.regressionFcn is degrees matrix)
    trendx = buildVandermondeMatrix( xT, this.regressionFcn, cfix( @powerBase, size(xT,2) )  );
	
	% only works as powers are 0 or 1 (not higher)
	df = zeros( mx, 1 );
	if size(this.regressionFcn, 1) > 1
		dregrDegrees = this.regressionFcn(2:end,:); % remove constant
		df = [df buildVandermondeMatrix( dxT, dregrDegrees, cfix( @powerBase, size(dxT,2) ) )];
	end
	
    %% Stochastic process (correlation part)
	% distance matrix
    distx = x(ones(n,1),:) - this.samples(this.P,:);
    [corr dx] = feval(this.correlationFcn, this.hyperparameters, distx);

    %% Jacobians (gradients)
	
	% of prediction mean
	% scaled
	dy = df * this.alpha + dx' * this.gamma;
	% unscaled
	dy = dy' .* repmat(this.outputScaling(2, :)',1,mx) ./ repmat(this.inputScaling(2,:),dim_out,1);
	
	% of sigma2 (if needed)
	if nargout > 1		
        % gradient/Jacobian of MSE wanted
		
		% scaled
		corrt = this.C(1:this.rank,1:this.rank) \ corr;
		u = this.Ft.' * corrt - trendx.';
		v = this.R \ u;
		Rv = this.R' \ v;
		g = (this.Ft * Rv - corrt)' * (this.C(1:this.rank,1:this.rank) \ dx) - (df * Rv)';
		
		% unscaled
		dsigma2 = repmat(2 * this.sigma2',1,mx) .* repmat(g ./ this.inputScaling(2,:),dim_out,1);
		
	end
end
