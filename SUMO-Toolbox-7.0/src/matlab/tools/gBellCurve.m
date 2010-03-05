function y = gBellCurve( x, a, b, c )

% gBellCurve (SUMO)
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
%	y = gBellCurve( x, a, b, c )
%
% Description:
%	A generalized bell curve function

if ~(exist('a', 'var') && exist('b', 'var') && exist('c', 'var'))
	a = 0.19921;
	b = 2.08;
	c = 6.94e-18;
end

tmp = ((x - c)./a).^2;
if (tmp == 0 & b == 0)
    y = 0.5;
elseif (tmp == 0 & b < 0)
    y = 0;
else
    tmp = tmp.^b;
    y = 1./(1 + tmp);
end
