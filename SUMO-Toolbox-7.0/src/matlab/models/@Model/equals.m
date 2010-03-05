function res = equals(s, m, threshold)

% equals (SUMO)
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
% Revision: $Rev: 6385 $
%
% Signature:
%	res = equals(s, m, threshold)
%
% Description:
%	A grid based equality method.
%	Evaluates 'm' and 'this' on a grid and returns true if the mean relative error is <= threshold

if(~exist('threshold','var'))
	threshold = eps;
end

%disp(sprintf('Comparing %s with %s, maximum difference is %d',getDescription(s),getDescription(m),threshold));

[s1 v1] = getGrid(s);
[s1 v2] = getGrid(m);

difference = meanRelativeError(v1,v2);

if( difference > threshold )
	res = false;
else
	res = true;
end
