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
%	Performs crossover between different model types, possibly producing ensembles
%	The arguments to the function are
%	 * parents — Row vector of parents chosen by the selection function
%	 * options — options structure
%	 * nvars — Number of variables
%	 * FitnessFcn — Fitness function
%	 * unused — Placeholder not used
%	 * thisPopulation — Matrix representing the current population.
%	The number of rows of the matrix is Population size and the number of columns is Number of variables.

if(length(parents) < 1)
	xoverKids = [];
	return
end

%Divde the population in a number of groups of equal model type
groupedParents = groupModels(s,parents, thisPopulation);

% How many children to produce? NB: the way the gads toolbox works, length(parents) will always be even
nKids = length(parents)/2;
xoverKids = cell(nKids,1);

outsiders = [];

k = 1;
%For each group of same type models
for j=1:length(groupedParents)
	group = groupedParents{j};
	
	%If we have an uneven number of models, pinch off the last one
	%and add it to the list of outsiders
	if(mod(length(group),2) ~= 0)
		outsiders = [outsiders group(end)];
		group = group(1:end-1);
	end

	%Even number of group members, call the crossover function of the
	%corresponding modelinterface

	%Find the matching modelinterface
	for p=1:length(s.modelInterfaces)
		mi = s.modelInterfaces{p};

		if((length(group)>0) && (strcmp(getModelType(mi), class(thisPopulation{group(1)}))))
			xoFcn = getCrossoverFcn(mi);

			%Call the model specific crossover function
			pop = xoFcn(group,options,nvars,FitnessFcn,unused,thisPopulation);

			xoverKids(k:k+length(pop)-1,1) = pop;	
			k = k+length(pop);

			break;
		end
	end
end

%outsiders contains a list of ugly ducklings, an odd number of model types
%eg: 1 poly, 1 ann, 1 ensemble, 1 svm
len = length(outsiders);
if(len > 0)
	s.logger.fine(sprintf('Produced %d of %d normal crossover children, %d outsiders remain',nKids,length(thisPopulation),length(outsiders)));
	
	%Pass all outsiders to the ensemble genetic interface crossover function
	%It will combine the different models appropriately
	for j=1:length(s.modelInterfaces)
		mi = s.modelInterfaces{j};
		if(strcmp(getModelType(mi), 'EnsembleModel'))
			xoFcn = getCrossoverFcn(mi);

			%Call the model specific crossover function
			pop = xoFcn(outsiders,options,nvars,FitnessFcn,unused,thisPopulation);

			xoverKids(k:k+length(pop)-1,1) = pop;	
			k = k+length(pop);

			break;
		end
	end
else
end

if(length(xoverKids) ~= nKids)
	msg = sprintf('Not enough crossover children created, %d created while %d are required',length(mutationChildren),nKids);
	logger.severe(msg);
	error(msg);
else
	s.logger.fine(sprintf('Produced %d of %d heterogenous crossover children (%d required)',length(xoverKids),length(thisPopulation),nKids));
end
