function [state, candidates] = MPSRandomCandidateGenerator(state)

% MPSRandomCandidateGenerator (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	[state, candidates] = MPSRandomCandidateGenerator(state)
%
% Description:
%	Generate a set of random candidate points, based on the dimension.

% get # samples
nDim = size(state.samples,2);
nPoints = nDim.*10.^4;

%% generate random set of points
% TODO: complicated, can't we just do a rand(n,k) and scale to -1,1 ? or
% factorial design or ...

% Draw from uniform distribution on [a,b]
%candidates = -1 + rand(n,1) .* (1--1);
x1 = -1 + 2.*rand(nPoints.*nDim,1);

candidates = zeros(nPoints, nDim);
for j=1:nPoints
    index = (j-1).*nDim + 1;
    candidates(j,:) = x1(index:(index+nDim-1), :)';
end

end
