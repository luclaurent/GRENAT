function model = randomInit(model,range);

% randomInit (SUMO)
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
%	model = randomInit(model,range);
%
% Description:
%	Re-initialize the network with random numbers within a given range

weights = boundedRand(range(1),range(2),length(getx(model.network)),1);
setx(model.network, weights);

%Save the new random weights as initial weights
model.config.initialWeights.IW = model.network.IW;
model.config.initialWeights.LW = model.network.LW;
model.config.initialWeights.b = model.network.b;
