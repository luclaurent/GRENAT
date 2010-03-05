function bestModelMeasures = getBestModelMeasures(s)

% getBestModelMeasures (SUMO)
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
%	bestModelMeasures = getBestModelMeasures(s)
%
% Description:
%	Return a matrix of the scores for each ENABLED measure (ordered by measure) of each model in the best model trace.

bestModelMeasures = [];
for i = 1 : length(s.bestModels)
	
	% get the model
	model = s.bestModels{i};
	
	% walk over all measures and append the score
	[scoreData] = getMeasureScores(model);
	
	% concatenate all rows (remember: one row per measure, one column per
	% output)
	measureValues = reshape(scoreData.scoreMatrixEnabled',1,numel(scoreData.scoreMatrixEnabled));
    
    % remove any NaNs (NaNs are present at location (i,j) of the
    % scoreMatrix if measure i does not apply to output j
    measureValues(isnan(measureValues)) = [];
    
	% add to full array
	bestModelMeasures = [bestModelMeasures ; measureValues];
end
