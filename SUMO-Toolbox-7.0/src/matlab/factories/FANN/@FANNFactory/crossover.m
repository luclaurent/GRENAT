function xoverKids = crossover(s,parents, options, nvars, FitnessFcn, unused,thisPopulation)

% crossover (SUMO)
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
%	xoverKids = crossover(s,parents, options, nvars, FitnessFcn, unused,thisPopulation)
%
% Description:
%	A Simple crossover operator
%	The arguments to the function are
%	 * parents — Row vector of parents chosen by the selection function
%	 * options — options structure
%	 * nvars — Number of variables
%	 * FitnessFcn — Fitness function
%	 * unused — Placeholder not used
%	 * thisPopulation — Matrix representing the current population.
%	The number of rows of the matrix is Population size and the number of columns is Number of variables.

% How many children to produce?
nKids = length(parents)/2;

%Pre-allocate childern array
xoverKids = cell(nKids,nvars);

[smp val] = getSamples(s);

index = 1;
for i=1:nKids
	% get parents
	parent1 = thisPopulation{parents(index),:};
	index = index + 1;
	parent2 = thisPopulation{parents(index),:};
	index = index + 1;

	dim1 = getHiddenLayerDim(parent1);
	dim2 = getHiddenLayerDim(parent2);
	
	%Do a simple 1point crossover of the hidden layers
	%randomly choose one of the two possible children
	if(dim1 == dim2)
		%If the dims are equal do a single point crossover on the weights
		if(rand < 0.6)
			w1 = getInitialWeights(parent1);
			w2 = getInitialWeights(parent2);
		else
			w1 = getNetworkWeights(parent1);
			w2 = getNetworkWeights(parent2);
		end

		[c1 c2] = onePointCrossover(w1,w2,1);
	
		if(rand < 0.5)
			w = c1;
		else
			w = c2;
		end

		child = s.createModel(dim1);
		child = setInitialWeights(child,w);
		
		% Add some jitter
		child = jitterInitialWeights(child);
	else
		if(rand < 0.5)
			newDim = [dim1(1) dim2(2)];
		else
			newDim = [dim2(1) dim1(2)];
		end
	
		%Now create the actual child
		child = s.createModel(newDim);
	
		%Initialize the weights with one of the parents
		if(rand <= 0.5)
			w = getNetworkWeights(parent1);
		else
			w = getNetworkWeights(parent2);
		end

		child = setInitialWeights(child,w);
		child = jitterInitialWeights(child);
	end

	xoverKids{i,:} = child;
end

% Make sure all are trained
xoverKids = constructModels(xoverKids,smp,val,s.getParallelMode());

s.logger.fine(sprintf('Produced %d of %d FANN crossover children',nKids,length(thisPopulation)));
