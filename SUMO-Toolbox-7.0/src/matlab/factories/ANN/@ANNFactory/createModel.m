function model = createModel(s,individual);

% createModel (SUMO)
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
%	model = createModel(s,individual);
%
% Description:
%	Given an individual representing a model, return a real model. Or if nothing is passed return a default model

if(~exist('individual','var') || isempty(individual))

  [ni no] = getDimensions(s);
  dim = [ni s.initialSize no];
  dim = dim(dim > 0);

  model = ANNModel(dim,s.epochs,s.trainingGoal);

elseif(isa(individual,'Model'))

  model = individual;
  return;

else

  % individual == the hidden layer structure == positive integers
  individual = floor(individual);
  individual = individual(individual > 0);

  [inDim outDim] = getDimensions(s);

  % add the number of inputs and outputs
  dim = [inDim individual outDim];

  % create the ANN object
  model = ANNModel(dim,s.epochs,s.trainingGoal);

end

% set the transfer functions to match the dimension
tf = buildTransferFcnList(getTransferFunTemplate(s),dim);
	  
% set the remaining config
cfg = getConfig(model);
cfg.transferFunctions = tf;
cfg.trainingTime = getTrainingTime(s);
cfg.performFcn = getPerformFcn(s);
cfg.trainMethod = getTrainMethod(s);
cfg.trainingProgress = getTrainingProgress(s);
cfg.earlyStoppingRatios = getEarlyStoppingRatios(s);

% take the first learning rule
lr = getAllowedLearningRules(s);
cfg.learningRule = lr{1};

model = setConfig(model,cfg);
