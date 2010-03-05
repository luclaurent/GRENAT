function [s, changed] = addSampleToNeighbourhood(s, samples, B, P)

% addSampleToNeighbourhood (SUMO)
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
%	[s, changed] = addSampleToNeighbourhood(s, samples, B, P)
%
% Description:
%	Try to add point P to the neighbourhood of B.

% nothing changed to the neighbourhood so far
changed = false;

% never add a point to its own neighbourhood
if B == P
	%s.logger.finest('P = B, returning...');
	return;	
end

% never add a point that's already in the neighbourhood
if any(s.neighbourhoods{B} == P)
	%s.logger.finest('P already in N(B), returning...');
	return;
end


% max size not reached yet, just add it
if length(s.neighbourhoods{B}) < s.neighbourhoodSize
	s.neighbourhoods{B} = [s.neighbourhoods{B} P];
	changed = true;
	%s.neighbourhoodScores(B) = calculateNeighbourhoodScore(samples(B,:), samples(s.neighbourhoods{B},:));
	s.logger.finest(sprintf('Added sample %d to neighbourhood of %d because it wasn''t full yet (new size: %d)', P, B, length(s.neighbourhoods{B})));
	return;
end

% max distance not set yet
if s.neighbourhoodMaxDistance(B) == +Inf
	
	% calculate new neighbourhood score
	s.neighbourhoodScores(B) = calculateNeighbourhoodScore(s, samples(B,:), samples(s.neighbourhoods{B},:));
	
	% calculate new max distance from P within neighbourhood
	sB = samples(B,:);
	distances = samples(s.neighbourhoods{B},:) - sB(ones(length(s.neighbourhoods{B}),1),:);
	s.neighbourhoodMaxDistance(B) = sqrt(max(dot(distances, distances, 2)));
end

% if the distance of B from P is 1.5 times the distance of the farthest
% neighbour, we discard it right away (= 'too far' heuristic)
pDistance = mag(samples(P) - samples(B));
% 3.5 is not a magic number (see tech report)
if pDistance > 3.5 * s.neighbourhoodMaxDistance(B)
	%s.logger.finest(sprintf('Skipped checking sample %d for the neighbourhood of %d because it was too far away (%d) compared to the current neighbourhood (%d)...', P, B, pDistance, s.neighbourhoodMaxDistance(B)));
	return;
end



% neighbourhood is full, see if we can replace an inferior neighbour

% find the worst neighbour in the set [current neighbourhood, candidate]
[newScore, worst] = findWorstNeighbour(s, samples, B, P);

% one of the current neighbours is worse than the new candidate - replace it
if worst > 0
	
	% set new neighbourhood
	s.neighbourhoods{B}(worst) = P;
	
	% set new neighbourhood score
	s.neighbourhoodScores(B) = newScore;
	
	% calculate new max distance from P within neighbourhood
	sB = samples(B,:);
	distances = samples(s.neighbourhoods{B},:) - sB(ones(length(s.neighbourhoods{B}),1),:);
	s.neighbourhoodMaxDistance(B) = sqrt(max(dot(distances, distances, 2)));
	
	% the neighbourhood was changed, signal this to calling function
	changed = true;
	s.logger.finest(sprintf('Added sample %d to neighbourhood of %d because it was a better neighbour than current neighbour %d (new score: %d).', P, B, worst, newScore));
end
