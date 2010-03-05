function  [corr, dx, dtheta, rho] = corrlin(theta, d)

% corrlin (SUMO)
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
%	[corr, dx, dtheta, rho] = corrlin(theta, d)
%
% Description:
%	Linear correlation function,
%

if nargin == 0
	corr = 'D';
	return;
end

[n m] = size(d);
theta = 10.^theta(:).';

inner = max(1 - abs(d) .* theta(ones(n,1),:), 0);
corr = prod(inner, 2);

% Derivatives
if  nargout > 1
  % to x
  dx = zeros(n,m);
  for  j = 1 : m
    dxj = (-theta(j) * sign(d(:,j)) );
    dx(:,j) = prod(inner(:,[1:j-1 j+1:m]),2) .* dxj;
  end

  % to theta
  % Derivative of min/max via
  % min(a,b) = 0.5(a+b-abs(a-b))
  % min(a,b) = -max(-a,-b)
  % or use branch (if x > a else ...)
  dtheta = zeros(n,m);
  for j=1:m
    dthetaj = theta(j) .* abs(d(:,j));
	dthetaj(dthetaj >= 1,:) = 0; % derive right side of max() (see inner statement above)
    
    dtheta(:,j) = prod(inner(:,[1:j-1 j+1:m]),2) .* -log(10).*dthetaj;
  end
end

% Rho
if nargout > 3
    rho = inner;
end
