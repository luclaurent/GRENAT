function s = rebuildBestModel(s, keepOldModels)

% rebuildBestModel (SUMO)
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
%	s = rebuildBestModel(s, keepOldModels)
%
% Description:
%	Each time new samples are added, the last x best models are
%	re-evaluated against all measures, to ensure accidently
%	lucky models to drop out. The best of these is set as the new best model

% default value for keepOldModels
if ~exist('keepOldModels', 'var')
	keepOldModels = false;
end

% no models to rebuild - abort
if length(s.bestModels) == 0
	return;
end

% get previous score
oldBestModelScore = getBestModelScore(s);

% re-score all models in the best model list and re-add them in order
s.logger.info(sprintf('%s: rebuilding the %d best models to accomodate the new samples',class(s),length(s.bestModels)));

% re-build the x best models
n = length(s.bestModels);
newModels = cell(length(s.bestModels), 1);

% reconstruct models using the new samples
newModels = constructModels(s.bestModels,s.state.samples,s.state.values,s.parallelMode);

% if we don't keep the old models, we first erase the best model list
if ~keepOldModels
	
	% delete all old models
	s.bestModels = {};
end

% score all the newly constructed models
[s scores measureScores] = scoreModels(s, newModels);

% get new best model score
newBestModelScore = getBestModelScore(s);

% remember if we made improvement or not
if(isempty(s.rebuildBestModelEffect))
    s.rebuildBestModelEffect = newBestModelScore;
else
    scoreDiff = (oldBestModelScore - newBestModelScore);
    s.rebuildBestModelEffect = [s.rebuildBestModelEffect scoreDiff];
    s.rebuildBestModelProfiler.addEntry([size(s.state.samples,1) scoreDiff]); 
end

% if our new best model actually has a worse score than our previous best
% model, we let the user know
s.logger.info('');
if oldBestModelScore < newBestModelScore
	s.logger.info(sprintf('%s: Rebuilding done, the best model score for %s was raised from %d to %d after training with %d samples.',class(s), arr2str(s.outputNames), oldBestModelScore, newBestModelScore, size(s.state.samples,1)));
elseif oldBestModelScore > newBestModelScore
	s.logger.info(sprintf('%s: Rebuilding done, the best model score for %s was lowered from %d to %d after training with %d samples.',class(s), arr2str(s.outputNames), oldBestModelScore, newBestModelScore, size(s.state.samples,1)));
else
	s.logger.info(sprintf('%s: Rebuilding done, the best model score for %s remained unchanged at %d after training with %d samples.',class(s), arr2str(s.outputNames), newBestModelScore, size(s.state.samples,1)));
end

% It could be that before the rebuild the targets were reached but after
% the rebuild this is no longer the case.  In this case we must inform the
% model builder that he is no longer done

% Remember that if you mess with this you must also update processBestModel
% and evaluateMeasures
if(s.finalTargetsReached && newBestModelScore > sum(s.measureData.weights .* s.measureData.finalTargets))
   s.logger.info('The rebuild caused the final targets to no longer be reached, continuing,...');
   s.finalTargetsReached = false;
end
