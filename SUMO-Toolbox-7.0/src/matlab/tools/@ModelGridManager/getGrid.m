function values = getGrid(s, modelId)

% getGrid (SUMO)
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
%	values = getGrid(s, modelId)
%
% Description:
%	Return the grid for this model. Returns empty samples and values
%	arrays when no such grid exists.

% transform model id to real grid id
id = s.modelIdToGrids(modelId);

% invalid id, return empty stuff
if (id <= 0) || (id > length(s.grids))
	values = [];
	return;
end

% return the grid
values = s.grids{id};
