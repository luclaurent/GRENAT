function out = Weierstrass1D(x)

% Weierstrass1D (SUMO)
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
% Revision: $Rev: 6376 $
%
% Signature:
%	out = Weierstrass1D(x)
%
% Description:
%	WEIERSTRASS  Calculates Weierstrass's non-differentiable function
%
%	  w(x) = sum_{k=0}^{\infty} a^k \cos(2\pi b^k x)
%	  with 0 < a < 1 and a*b >= 1
%
%	Author  : Andreas Klimke, Universit Stuttgart
%	Version : 1.0
%	Date    : August 12, 2002

%     Modified by Dirk Gorissen
	
a = 0.5;
b = 3;
kmax = 20;
	
c1(1:kmax+1) = a.^(0:kmax);
c2(1:kmax+1) = 2*pi*b.^(0:kmax);

out = w(x,c1,c2);

%--------------------------------
function y = w(x,c1,c2)

index = 1;
y = zeros(length(x),1);
for k = x
	y(index) = sum(c1 .* cos(c2*k));
	index = index + 1;
end


	

