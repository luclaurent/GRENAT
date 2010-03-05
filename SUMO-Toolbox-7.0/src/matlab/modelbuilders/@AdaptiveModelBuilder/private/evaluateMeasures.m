function [s, measureScores, score] = evaluateMeasures(s, model)

% evaluateMeasures (SUMO)
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
%	[s, measureScores, score] = evaluateMeasures(s, model)
%
% Description:
%	This function evaluates the model on all the measures and returns the
%	scores. It also calculates the global score of the model, based on a
%	combination of the (weighted) separate measure scores.

measureScores = [];

% add the best models to the state
state = s.state;
state.bestModels = s.bestModels;

for i = 1 : length(s.measureData.measures)

  mi = s.measureData.measures{i};
  measure = mi.measure;
  outputCoverage = mi.outputCoverage;

  % calculate the value of this measure on the model
  [measure, scores] = measure.processMeasure(model, state, outputCoverage);

  % append to measure values only if used for evaluation
  if(measure.isEnabled())
    measureScores = [measureScores scores];
  end

  % save changes to the measure (if any?)
  mi.measure = measure;

  % save the updated measure item
  mi.scores = scores;
  s.measureData.measures{i} = mi;
end

%% calculate the global score of model

% No longer translate truncate scores at 0
% to prevent confusing the hyperparameter selection

% apply weights (weighted sum)
score = sum(s.measureData.weights .* measureScores);
