function model = createRandomModel( this )

% createRandomModel (SUMO)
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
%	model = createRandomModel( this )
%
% Description:
%	Return a randomly chosen ANN model

% randomly choose hidden layer structure
dim = [randomInt([0 20]) randomInt([0 20])];

model = this.createModel(dim);

% choose a random training function
model = setLearningRule(model, randomChoose(this.allowedLearningRules));
