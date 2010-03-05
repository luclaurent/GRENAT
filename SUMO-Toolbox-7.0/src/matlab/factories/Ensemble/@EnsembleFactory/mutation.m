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
%	Simple mutation operator that wraps mutateANN
%	 The arguments to the function are
%	 * parents — Row vector of parents chosen by the selection function
%	 * options — Options structure
%	 * nvars — Number of variables
%	 * FitnessFcn — Fitness function
%	 * state — Structure containing information about the current generation.
%	 * thisScore — Vector of scores of the current population
%	 * thisPopulation — Matrix of individuals in the current population
%
%	The function returns mutationChildren — the mutated offspring — as a matrix whose rows correspond to the children.
%	The number of columns of the matrix is Number of variables.

[smp val] = getSamples(s);
mutationChildren = cell(size(parents,1),1);

for i=1:length(parents)
	parent = thisPopulation{parents(i),:};
	%Mutate the ensemble
	%Randomly delete one ensemble member, if the remaining ensemble size is 1, replace the ensemble
	%object by the nested object (this requires we wrap all models, else they cannot be stored together).

	models = getModels(parent);
	index = randomInt(1,length(models));
	if(index == 1)
		models = models(2:end);
	elseif(index == length(models))
		models = models(1:end-1);
	else
		models = [models(1:index-1) ; models(index+1:end)];
	end

	if(length(models) == 1)
		m = models{1};
	else
		m = EnsembleModel(models,getEqualityThreshold(s));
	end
	
	mutationChildren{i,1} = m;
end

% Make sure all are trained
mutationChildren = constructModels(mutationChildren,smp,val,s.getParallelMode());

s.logger.fine(sprintf('Produced %d of %d ensemble mutation children',length(parents),length(thisPopulation)));
