function  [corr, dx, dtheta, rho] = corrspline(theta, d)

% corrspline (SUMO)
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
%	[corr, dx, dtheta, rho] = corrspline(theta, d)
%
% Description:
%	Cubic spline correlation function,
%

if nargin == 0
	corr = 'D';
	return;
end

[n m] = size(d);
theta = 10.^theta(:).';

nm = n*m;   term = zeros(nm,1);
xi = reshape(abs(d) .* theta(ones(n,1),:), nm,1);

% Contributions to first and second part of spline
i1 = find(xi <= 0.2);
i2 = find(0.2 < xi & xi < 1);
if  ~isempty(i1)
  term(i1) = 1 - xi(i1).^2 .* (15  - 30*xi(i1));
end
if  ~isempty(i2)
  term(i2) = 1.25 * (1 - xi(i2)).^3;
end

% prod up
term = reshape(term,n,m);
corr = prod(term, 2);

% Derivatives
if  nargout > 1
  % to x
  u = reshape(sign(d) .* theta(ones(n,1),:), nm,1);
  dx = zeros(nm,1);
  if  ~isempty(i1)
    dx(i1) = u(i1) .* ( (90*xi(i1) - 30) .* xi(i1) );
  end
  if  ~isempty(i2)
    dx(i2) = -3.75 * u(i2) .* (1 - xi(i2)).^2;
  end
  ii = 1:n;
  for j = 1:m
    sj = term(:,j);  term(:,j) = dx(ii);
    dx(ii) = prod(term,2);
    term(:,j) = sj;
    ii = ii + n;
  end
  dx = reshape(dx,n,m);

  % to theta
  dtheta = zeros(nm,1);
  u = reshape(log(10) .* abs(d) .* theta(ones(n,1),:), nm,1);
  
  if  ~isempty(i1)
    dtheta(i1) = 30 .* xi(i1) .* u(i1) .* (3 .* xi(i1) - 1);
  end
  if  ~isempty(i2)
    dtheta(i2) = -3.75 .* u(i2) .* (1 - xi(i2)).^2;
  end
  ii = 1:n;
  for j = 1:m
    sj = term(:,j);  term(:,j) = dtheta(ii);
    dtheta(ii) = prod(term,2);
    term(:,j) = sj;
    ii = ii + n;
  end
  dtheta = reshape(dtheta,n,m);
  
end

% Rho
if nargout > 3
    rho = term;
end
