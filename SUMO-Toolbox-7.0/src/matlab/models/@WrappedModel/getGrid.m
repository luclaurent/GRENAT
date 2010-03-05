function [samples, values] = getGrid(m)

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
%	[samples, values] = getGrid(m)
%
% Description:
%	Returns a set of samples evaluated on a dense grid to be used for
%	evaluation of the model. Recycles previously evaluated grids.

[samples values] = getGrid(m.nestedModel);

% filter
goodindices = m.filter.filterSamplesFromModel(samples);
samples = samples(goodindices,:);
values = values(goodindices,:);
