function [index, dominance, distance] = nonDominatedSort(objectives)

% nonDominatedSort (SUMO)
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
%	[index, dominance, distance] = nonDominatedSort(objectives)
%
% Description:
%	This function sorts a population in pareto fronts according to their
%	dominance of the objectives.
%	 It returns the sorted objectives as indices to the initial
%	 objectives (as such, it doesn't need the population).
%	 Optionally the use dominance and distance

% first, scale the objectives so that they are strictly positive
% this must be done to ensure a fair sorting by distance from origin
objectives = bsxfun(@minus, objectives, min(0, min(objectives,[],1)));
nObjectives = size(objectives, 1);

% calculate dominance score for each model in the best model set
dominance = zeros(nObjectives,1);
parfor cur = 1 : nObjectives
	
	% now visit all other models, and count how many dominate this one
	for other = 1 : nObjectives		
		% convert cell array of measures (for each output a cell) to flat array
		if all(objectives(other,:) <= objectives(cur,:)) && any(objectives(other,:) < objectives(cur,:))
			dominance(cur) = dominance(cur) + 1;
		end
	end
    
end

% calculate maximin distance (criterium to keep pareto front diverse)
distance = repmat( +Inf, nObjectives, 1);
dom = unique(dominance);
for i=1:size(dom,1)
	% when a measure is better then the target, the distance is set to 0
	idx = find( dominance == dom(i) );
	dat = objectives(idx,:);
	
	dist = buildDistanceMatrix( dat );
	dist = dist + diag( repmat( +Inf, size(dist,1), 1));
	dist = min( dist, [], 2 );

	distance(idx) = dist;
end

% calculate as a final, third criterion the distance from zero for the
% objectives (only used if dominance and inter-distance is identical)
% TODO this was added to make sure models which violate MinMax are not
% chosen as best models
distanceFromZero = sum(objectives .^ 2, 2);

% sort the array, first on dominance, then on distance
[dummy, index] = sortrows([dominance distance distanceFromZero], [1 -2 3]);

% now re-sort the first pareto front to make sure that the first model is
% the one with the best score
firstParetoFrontSize = sum(min(dominance) == dominance);
[dummy, newIndex] = sortrows([dominance distanceFromZero distance], [1 2 -3]);
index(1:firstParetoFrontSize) = newIndex(1:firstParetoFrontSize);
