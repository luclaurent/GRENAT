function model = jitterInitialWeights(model);

% jitterInitialWeights (SUMO)
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
%	model = jitterInitialWeights(model);
%
% Description:
%	Give the initial and network weights a little jitter

W1 = model.config.initialWeights.W1;
W2 = model.config.initialWeights.W2;

jitter1 = randn(size(W1));
jitter2 = randn(size(W2));

model.config.initialWeights.W1 = W1 + jitter1;
model.config.initialWeights.W2 = W2 + jitter2;
