function [reliability] = calculateReliability( samples, LB, UB )

% calculateReliability (SUMO)
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
%	[reliability] = calculateReliability( samples, LB, UB )
%
% Description:
%	Given a set of samples calculate the reliability of a model parameter optimization trace
%	which was run with this set of samples

if(~exist('LB','var') || ~exist('UB','var'))
	LB = [];
	UB = [];
end

% how dense are the samples
[approxVoronoi largestVoronoiPerc] = approximateVoronoi( samples, LB, UB );

% based on the size of the largest voronoi cell, calculate the reliability of the trace
% E.g., Models built with few samples are unreliable, the optimal model parameter combination
% is more likely to change in the future.  Thus they should receive a lower score.

% Use a generalized bell curve fuzzy membership function
reliability = gBellCurve( largestVoronoiPerc/100 );
