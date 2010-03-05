function out = Academic3DAutoMatlab(points)

% Academic3DAutoMatlab (SUMO)
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
%	out = Academic3DAutoMatlab(points)
%
% Description:
%	A 3D test function with auto-sampling in the third dimension.

a = points(:,1);
b = points(:,2);
c = linspace(-1, 1, 5);

out = zeros(0, 4);
for i = 1 : length(c)
	out = [out ; a b repmat(c(i), size(a,1), 1) exp(c(i) + 2) ./ gamma(b * 3) .* (a + 3) ./ 135.0];
end
