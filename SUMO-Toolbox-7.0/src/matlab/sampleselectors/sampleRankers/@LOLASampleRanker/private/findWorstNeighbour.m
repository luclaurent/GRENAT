function [newScore, worst] = findWorstNeighbour(s, samples, A, P)

% findWorstNeighbour (SUMO)
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
%	[newScore, worst] = findWorstNeighbour(s, samples, A, P)
%
% Description:
%	Find out if we can replace a neighbour in the current neighbourhood
%	of A by the new candidate and get a better neighbourhood. Returns 0
%	if the current neighbourhood is best.

% get the current score & neighbourhood
oldScore = s.neighbourhoodScores(A);

% get the data from the samples array
neighbourhood = samples(s.neighbourhoods{A},:);
candidate = samples(P,:);
A = samples(A,:);

% attempt to replace each current neighbour by the new candidate &
% calculate new scores
newScores = zeros(size(neighbourhood,1),1);
for j = 1 : size(neighbourhood)
	newScore = calculateNeighbourhoodScore(s, A, [neighbourhood(1:size(neighbourhood,1) ~= j,:) ; candidate]);
	newScores(j) = newScore;
end

% no new neighbourhood is better than the last one, abort
if (oldScore >= max(newScores))
	worst = 0;
	newScore = oldScore;
	return;
end

% return the neighbour that should be replaced
[newScore, worst] = max(newScores);
