function m = setOutputNames( m, names)

% setOutputNames (SUMO)
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
%	m = setOutputNames( m, names)
%
% Description:
%	Set the names of the output parameters

[in out] = getDimensions(m);

if(length(names) ~= out)
	error(sprintf('The number of output names (%d) does not match the number of declared outputs (%d)',length(names),out));
else
	m.outputNames = names;
end
