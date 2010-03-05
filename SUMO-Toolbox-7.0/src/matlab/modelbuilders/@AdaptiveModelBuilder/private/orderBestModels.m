function [s, isNewBestModel] = orderBestModels(s)

% orderBestModels (SUMO)
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
%	[s, isNewBestModel] = orderBestModels(s)
%
% Description:
%	This function orders the list of best models according to pareto
%	dominance. It returns true if a new best model was found among the
%	candidates.

%% order the models in the list according to their measure scores

% get final targets into one vector
finalTargets = s.measureData.finalTargets;

% get a matrix with the enabled measure scores for each model in the best model trace
% one row per model
bestModelMeasures = getBestModelMeasures(s);

% how many measures are there
nMeasures = size(bestModelMeasures,2);

% get the id's of the models which have the minimum score on each measure
[dummy minIndices] = min(bestModelMeasures,[],1);
% remove duplicates
minIndices = unique(minIndices);

minIds = [];
for i=minIndices
  minIds = [minIds s.bestModels{i}.getId()];
end

% get the matching models
minModels = s.bestModels(minIndices);

% Translate measures so that finalTargets is the origin
objectives = bestModelMeasures - repmat( finalTargets, size(bestModelMeasures, 1), 1 );

% Perform a non-dominated sorting to obtain a pareto front of the best models
[order, dominance, distance] = nonDominatedSort( objectives );

s.logger.finer(sprintf('Measure scores for the best models: %s', arr2str(bestModelMeasures)));
s.logger.finer(sprintf('Dominance scores for the best models: %s', arr2str(dominance)));
s.logger.finer(sprintf('Distance between models in the same pareto front: %s', arr2str(distance)));

% truncate to the maximum size of the best models array
order = order(1:min(length(s.bestModels), s.nBestModels));

% change the order of the best models
s.bestModels = s.bestModels(order);

s.logger.fine(sprintf('Order for the best models: %s', arr2str(order)));
s.logger.fine(sprintf('New ordered measure scores for the best models: %s', arr2str(bestModelMeasures(order,:))));

% now we also want to make sure that bestModels also contains the models which have
% the minimum score on each measure independently
ids = [];
for m = s.bestModels
  ids = [ids m{1}.getId()];
end

% are there any models with a minimum measure score that are not in already the bestmodel trace
% we want to make sure we aloways have them
[toAdd idx] = setdiff(minIds,ids);

% replace the worst (=last) models of the best model trace by these models
if(~isempty(toAdd))
  s.bestModels(end-length(toAdd)+1:end) = minModels(idx);

  s.logger.fine(sprintf('Replaced the last %d best models with the best model for each measure',length(toAdd)));
end

%% see if the best model score was changed

% get new best model score
oldBestModelId = s.bestModelId;
newBestModelId = getId(getBestModel(s));

% signal a new best model iff..
%	1) the the id of the best model has changed

isNewBestModel = false;

if ( oldBestModelId ~= newBestModelId )
	
	% flag that there is a new best model
	isNewBestModel = true;
	
	% update the best model id
	s.bestModelId = newBestModelId;
	
	% if this model is the new best model, we process it as such
	s.logger.fine('Re-ordering resulted in a new best model');
	s = processBestModel(s);
end
