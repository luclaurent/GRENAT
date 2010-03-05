function s = addGrid(s, values, modelId)

% addGrid (SUMO)
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
%	s = addGrid(s, values, modelId)
%
% Description:
%	Add a new grid to the manager. There can only be one grid for each
%	modelId, and all grids are erased on reset.

s.grids = [s.grids values];
s.modelIdToGrids(modelId) = length(s.grids);
