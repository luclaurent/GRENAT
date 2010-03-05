function res = saveobj(wmodel)

% saveobj (SUMO)
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
%	res = saveobj(wmodel)
%
% Description:
%	Called whenever a wrapped model is saved to disk, make sure we remove the wrapper

if(length(wmodel) > 1)
	% convert to a cell to prevent problems with wrappers
	res = cell(1,length(wmodel));
	for i=1:length(res)
		res{i} = getNestedModel(wmodel(i));
	end
else
	% remove the wrapper
	res = wmodel.nestedModel;
end
