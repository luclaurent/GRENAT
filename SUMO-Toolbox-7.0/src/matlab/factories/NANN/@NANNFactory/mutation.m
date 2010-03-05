function mutationChildren = mutation(s, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)

% mutation (SUMO)
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
%	mutationChildren = mutation(s, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)
%
% Description:
%	Simple mutation operator that wraps mutateNANN
%	 The arguments to the function are
%	 * parents — Row vector of parents chosen by the selection function
%	 * options — Options structure
%	 * nvars — Number of variables
%	 * FitnessFcn — Fitness function
%	 * state — Structure containing information about the current generation.
%	 * thisScore — Vector of scores of the current population
%	 * thisPopulation — Matrix of individuals in the current population
%	The function returns mutationChildren — the mutated offspring — as a matrix whose rows correspond to the children.
%	The number of columns of the matrix is Number of variables.

[smp val] = getSamples(s);
mutationChildren = cell(size(parents,1),nvars);

for i=1:length(parents)
	parent = thisPopulation{parents(i),:};

	if(rand < 0.6)
		%Simply mutate the weights
		if(rand <= 0.6)
			%Randomly initialize
			child = randomInit(parent, getInitWeightRange(s));
		else
			%Set the trained weights as the network weights
			[w1 w2] = getNetworkWeights(parent);
			child = setInitialWeights(parent,w1,w2);

			%jitter the weights
			child = jitterInitialWeights(child);
		end
	  else
		%Mutate the hidden layer structure
		hidLayerDim = getHiddenLayerDim(parent);
		
		%Mutate the hidden layers
		hidLayerDim(1) = hidLayerDim(1) + randomInt(getHiddenUnitDelta(s));

		%Construct the child
		child = s.createModel(hidLayerDim);
	  end

	if (rand < 0.4)
		child = setPruneTechnique(child, randomChoose(getAllowedPruneTechniques(s)));
	end

	mutationChildren{i,1} = child;
end

% Make sure all are trained
mutationChildren = constructModels(mutationChildren,smp,val,s.getParallelMode());

s.logger.fine(sprintf('Produced %d of %d NANN mutation children',length(parents),length(thisPopulation)));
