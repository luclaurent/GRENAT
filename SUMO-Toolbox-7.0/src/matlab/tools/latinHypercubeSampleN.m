function [sample, gridsize] = latinHypercubeSampleN(weights, n)

% latinHypercubeSampleN (SUMO)
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
%	[sample, gridsize] = latinHypercubeSampleN(weights, n)
%
% Description:
%	Generate a random LH design in the cube [-1,1]^dimension consisting
%	of n points. use weights to stretch out the hypercube in a certain direction

% Create Gridsize
gridsize = createGridParameters(weights, n);

% Construct Integers
sample = zeros(n,0);
for i=1:size(gridsize,2)
	newsamples = zeros(n,1);
	for j = 0:n-1
		newsamples(j+1) = mod(j,gridsize(i)) + 1;
	end
	% randomly permutate 
	perm = randperm(n)';
	newsamples2 = newsamples;
	for j = 1:n
		newsamples2(j) = newsamples(perm(j));
	end
	sample = [sample newsamples2];
end
