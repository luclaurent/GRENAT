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
%	Initialize the initial weights randomly

dim = model.config.networkDim;

w1size = [dim(2),(dim(1)+1)];
w2size = [dim(end),(dim(2)+1)];

W1 = boundedRand(range(1),range(2),w1size(1),w1size(2));
W2 = boundedRand(range(1),range(2),w2size(1),w2size(2));

model.config.initialWeights.W1 = W1;
model.config.initialWeights.W2 = W2;

