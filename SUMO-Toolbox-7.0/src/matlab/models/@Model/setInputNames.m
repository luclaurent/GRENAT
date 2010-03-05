function m = setInputNames( m, names)

% setInputNames (SUMO)
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
%	m = setInputNames( m, names)
%
% Description:
%	Set the names of the input parameters

[in out] = getDimensions(m);

if(length(names) ~= in)
	error(sprintf('The number of input names (%d) does not match the number of declared inputs (%d)',length(names),in));
else
	m.inputNames = names;
end
