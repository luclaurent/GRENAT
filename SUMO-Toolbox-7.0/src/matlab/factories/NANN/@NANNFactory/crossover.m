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
[ni no] = getDimensions(s);

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
		[w11 w12] = getInitialWeights(parent1);
		[w21 w22] = getInitialWeights(parent2);

		k = randomInt([1 size(w11,1)-1]);
		l = randomInt([1 size(w12,2)-1]);
		if(rand < 0.5)
			ws.W1 = [w11(1:k,:); w21(k+1:end,:)];
			ws.W2 = [w12(:,1:l), w22(:,l+1:end)];
		else
			ws.W1 = [w21(1:k,:); w11(k+1:end,:)];
			ws.W2 = [w22(:,1:l), w12(:,l+1:end)];
		end

		child = s.createModel(dim1);
		child = setInitialWeights(child,ws.W1,ws.W2);
		
		% Add some jitter
		child = jitterInitialWeights(child);
	else
		%size of hidden layer is different, take the average
		newDim = ceil( (dim1 + dim2) / 2 );

		child = s.createModel(newDim);
	end

	xoverKids{i,:} = child;
end

% Make sure all are trained
xoverKids = constructModels(xoverKids,smp,val,s.getParallelMode());

s.logger.fine(sprintf('Produced %d of %d NANN crossover children',nKids,length(thisPopulation)));
