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
%	Mutates different model types
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

if(isempty(parents))
	mutationChildren = {};
	return
end

mutationChildren = cell(length(parents),1);

groupedParents = groupModels(s,parents, thisPopulation);

k = 1;
for i=1:length(groupedParents)
	group = groupedParents{i};
	%Find the modelinterface that matches this group and call its mutation function
	for j=1:length(s.modelInterfaces)
		mi = s.modelInterfaces{j};
		if(strcmp(getModelType(mi), class(thisPopulation{group(1)})))
			mutFcn = getMutationFcn(mi);
			
			%Call the model specific mutation function
			pop = mutFcn(group,options,nvars,FitnessFcn,state,thisScore,thisPopulation);
    
			mutationChildren(k:k+length(pop)-1,1) = pop;	
			k = k+length(pop);

			break;
		end
	end
end

if(length(mutationChildren) ~= length(parents))
	msg = sprintf('Not enough mutation children created, %d created while %d are required',length(mutationChildren),length(parents));
	logger.severe(msg);
	error(msg);
else
	s.logger.fine(sprintf('Produced %d of %d heterogenous mutation children (%d required)',length(mutationChildren),length(thisPopulation),length(parents)));
end
