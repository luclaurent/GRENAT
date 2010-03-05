function  [corr, dx, dtheta, rho] = corrspherical(theta, d)

% corrspherical (SUMO)
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
%	[corr, dx, dtheta, rho] = corrspherical(theta, d)
%
% Description:
%	Spherical correlation function,
%

if nargin == 0
	corr = 'D';
	return;
end

[n m] = size(d);
theta = 10.^theta(:).';
 
inner = min(abs(d) .* theta(ones(n,1),:), 1);
term = 1 - inner .* (1.5 - .5*inner.^2);
corr = prod(term, 2);

% Derivatives
if  nargout > 1
  % to x
  dx = zeros(n,m);
  for j=1:m
    dxj = 1.5.*theta(j) * sign(d(:,j)).*(inner(:,j).^2 - 1);
    dx(:,j) = prod(term(:,[1:j-1 j+1:m]),2) .* dxj;
  end

  % to theta
  dtheta = zeros(n,m);
  for j=1:m
    dthetaj = 1.5.*theta(j).*abs(d(:,j)).*(inner(:,j).^2 - 1);
    dtheta(:,j) = prod(term(:,[1:j-1 j+1:m]),2) .* dthetaj;
  end
end

% Rho
if nargout > 3
    rho = term;
end
