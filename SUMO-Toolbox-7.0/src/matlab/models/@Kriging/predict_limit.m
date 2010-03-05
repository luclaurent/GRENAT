function [y sigma2] = predict_limit(this, x)

% predict_limit (SUMO)
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
%	[y sigma2] = predict_limit(this, x)
%
% Description:
%	EXPERIMENTAL
%	Removes mean...
%

	%% Constants
	[n m] = size( this.samples );
    [nx mx] = size(x);
	dim_out = length(this.sigma2); % number of outputs
	
	%% Preprocessing
	x = (x - this.inputScaling(ones(nx,1),:)) ./ this.inputScaling(2.*ones(nx,1),:);
	
	% distance matrix
	nPoints = 1:nx;
	nSamples = 1:n;
	distx = x(nPoints(ones(n, 1),:),:) - this.samples(nSamples(ones(nx, 1),:)',:);

    corr = feval( this.correlationFcn, this.theta, distx );
    corr = reshape(corr, n, nx);
	
	tmp = this.C \ corr;
	tmp = this.C' \ tmp;
	
	%% Denominator
	% corr' * inv(this.C*this.C') * values
	denPart = tmp' * this.values;
	
	%% Numerator
	
	% Regression function
	% Orthogonal polynomial coding
    xl = (x./this.levels(3.*ones(nx,1),:)).*sqrt(3./2);
	xq = (3.*(x./this.levels(3.*ones(nx,1),:)).^2-2)./sqrt(2);
    xT = [xl xq];
	
	% model matrix (this.regressionFcn is degrees matrix)
    trendx = buildVandermondeMatrix( xT, this.regressionFcn, cfix( @powerBase, 2*n)  );
	
	% corr' * inv(this.C*this.C') * F
	numPart = tmp' * this.F;
	
    % scaled prediction
    sy = denPart ./ numPart;
	y = this.outputScaling(ones(nx,1),:) + this.outputScaling(2.*ones(nx,1),:) .* sy;
	
    % Calculate sigma
	% TODO calculate sigma of NEW limit predictor
	% code is still for BLUP
	if nargout > 1		
		%{
		corrt = this.C \ corr;
        u = this.Ft.' * corrt - trendx.';
        v = this.R \ u;
		
		tmp = (1 + sum(v.^2,1) - sum(corrt.^2,1))';
		sigma2 = repmat(this.sigma2,nx,1) .* repmat(tmp,1,dim_out);
		%}
	end
end
