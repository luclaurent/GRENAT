function  [corr, dx, dtheta, rho] = corrgauss(theta, d)

% corrgauss (SUMO)
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
%	[corr, dx, dtheta, rho] = corrgauss(theta, d)
%
% Description:
%	Gaussian correlation function
%

if nargin == 0
	corr = 'D';
	return;
end

[n m] = size(d);
theta = 10.^theta(:).';

inner = -abs(d).^2 .* theta(ones(n,1),:);
corr = exp(sum(inner, 2));

% Derivatives
if  nargout > 1
  % to x
  dx = -2.*theta(ones(n,1),:) .* d .* corr(:,ones(1,m));
  
  % to theta
  dtheta = log(10) .* inner .* corr(:,ones(1,m));
end

% Rho
if nargout > 3
    rho = exp(inner);
end
