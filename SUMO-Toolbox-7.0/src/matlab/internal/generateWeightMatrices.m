function [IW LW b] = generateWeightMatrices(nnDim,min,max);

% generateWeightMatrices (SUMO)
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
%	[IW LW b] = generateWeightMatrices(nnDim,min,max);
%
% Description:
%	Generate a set of weight matrices (with random values in [min max])
%	for the neural network of dimensions nnDim.

hidlayers = length(nnDim) - 2;

if(hidlayers < 0)
	error('At least one layer of units needed');
end

IW = cell(length(nnDim)-1,1);
LW = cell(length(nnDim)-1,length(nnDim)-1);

%"1st layer - input" connections
IW{1,1} = boundedRand(min,max,nnDim(2),nnDim(1));

%hidden layer and output connections
for(i=3:length(nnDim))
	LW{i-1,i-2} = boundedRand(min,max,nnDim(i),nnDim(i-1));
end

%biases
b = cell(length(nnDim)-1,1);
for i=1:length(nnDim)-1
	b{i} = boundedRand(min,max,nnDim(i+1),1);
end
