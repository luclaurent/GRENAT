function score = calculateNeighbourhoodScore(s, A, neighbourhood)

% calculateNeighbourhoodScore (SUMO)
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
%	score = calculateNeighbourhoodScore(s, A, neighbourhood)
%
% Description:
%	Calculates the score of this neighbourhood for point A. Two algorithms
%	are used.
%	neighbourhoodSize = 2 * dim: an optimal neighbourhood is a
%	cross-polytope of minimal radius.
%	other neighbourhoodSize: an optimal neighbour is minimal in average
%	distance from A.

% if neighbourhood size is not 2 * dim -> use simple measure
if (size(neighbourhood, 1) / size(neighbourhood,2) ~= 2) || s.fastNeighbourhoodCalculation

	% calculate average distance of neighbours from A
	cohesion = sum(mag(bsxfun(@minus, neighbourhood, A))) / size(neighbourhood,1);
	
	% score is inverse related to the cohesion -> points closer to A are better
	score = -cohesion;
	
	return;
end

% we use the complicated measure that only works for 2 * dim


% calculate for each point in the neighbourhood the minimal distance from
% all other samples in the neighbourhood
%{
distances = zeros(size(neighbourhood,1),1);
for i = 1 : size(neighbourhood,1)
	distance = bsxfun(@minus, neighbourhood(1:end ~= i,:), neighbourhood(i,:));
	distances(i) = sqrt(min(dot(distance, distance, 2)));
end
%}

% new, more optimal method
distanceArray = neighbourhood(s.neighbourhoodSubLeftSide,:) - neighbourhood(s.neighbourhoodSubRightSide,:);
distanceArray = dot(distanceArray, distanceArray, 2);
distances = sqrt(min(distanceArray(s.neighbourhoodSubIndexArray), [], 2));

% adhesion score is the average of the minimum distances
% adhesion = min(r_i - r_j) for all i, j with i != j
% the optimal configuration for points with equal distance from A is a cross-polytope
adhesion = sum(distances) / length(distances);

% calculate cohesion measure
% the initial version: cohesion = sum(mag(neighbourhood - repmat(A, size(neighbourhood,1),1))) / size(neighbourhood,1)
% improved version:
%	tmp = bsxfun(@minus, neighbourhood, A);
%	cohesion = sum(sqrt(dot(tmp,tmp,2))) / size(neighbourhood,1);
% second improved version:
cohesion = sum(sqrt(sum((neighbourhood - A(ones(size(neighbourhood,1),1),:)) .^ 2, 2))) / size(neighbourhood,1);


% adhesion co�fficient
% set to 0.7, as 0.7 is slighty below the minimum value for which there is
% constant straight convergence to 0 from a cross-polytope
Ac = 0.7;

% calculate final score
score = Ac * adhesion / sqrt(2)  - cohesion;

