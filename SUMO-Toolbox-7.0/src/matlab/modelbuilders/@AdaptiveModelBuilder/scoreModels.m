function [s,scores,allMeasureScores,models] = scoreModels(s, models)

% scoreModels (SUMO)
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
%	[s,scores,allMeasureScores,models] = scoreModels(s, models)
%
% Description:
%	This method attaches a score to a given set of models

% it is important that models be a cell to allow dealing with different model types in the same population

import import ibbt.sumo.profiler.*;

%% calculate & set scores for each model
allScores = zeros(length(models), 1);
allMeasureScores = [];

for m = 1 : length(models)
	model = models{m};

	% set the transformation values and input names + reset the measure scores
	% this is so that the measures have access to getSamples, getValues, etc.
	model = setModelInfo(s,model,-1);

	% evaluate measures for each output
	[s, measureScores, score] = evaluateMeasures(s, model);

	% set the same stuff, except this time also the measure scores are properly filled in
	model = setModelInfo(s,model,score);
	
	% do some logging of the model scores
	s.logger.fine(sprintf('+ Model score (%s, id=%d): %d (best=%d)', class(model), getId(model), score, getBestModelScore(s)));
    
    mdata = model.getMeasureScores();
    mScores = mdata.measureInfo;
    for o = 1 : length(s.outputNames)
        s.logger.fine(sprintf('  - Model scores for output %s:', s.outputNames{o}));
    
        for i=1:length(mScores{o})
            measureStruct = mScores{o}{i};
            s.logger.fine(sprintf( '    * Score on measure %s (%s) : %d%s' , measureStruct.type, measureStruct.errorFcn, measureStruct.score, iff(measureStruct.enabled, '', ' (not used)' ) ));
        end
    end
    
	% add the new model to the best model set
	s.bestModels{end+1} = model;
	
	% add model data to return values
	scores(m,1) = score;
	allMeasureScores = [allMeasureScores ; measureScores];
	
	% the models have been changed (the score data has been set), make sure the caller
	% gets back the updated models
	models{m} = model;
end


% order all models (old and newly added) according to their scores and pareto dominance
[s, isNewBestModel] = orderBestModels(s);
