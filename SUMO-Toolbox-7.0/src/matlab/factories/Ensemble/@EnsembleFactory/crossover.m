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

%NB: The parents can be ensemble models or plain models

[smp val] = getSamples(s);
xoverKids = cell(nKids,1);

index = 1;
for i=1:nKids
	% get parents
	parent1 = thisPopulation{parents(index),:};
	index = index + 1;
	parent2 = thisPopulation{parents(index),:};
	index = index + 1;

%    	disp('parent1')
%    	getDescription(parent1)
%    
%    	disp('parent2')
%    	getDescription(parent2)

	if(isa(parent1,'EnsembleModel'))
		if(isa(parent2,'EnsembleModel'))
			%Ensemble - Ensemble
			%Do a single-point crossover between the model lists
			models1 = getModels(parent1);
			models2 = getModels(parent2);

			[child1 child2] = onePointCrossover(models1,models2,true);
			if(rand > 0.5)
				child = child1;
			else
				child = child2;
			end

			%Create a new ensemble
			child = EnsembleModel(child,getEqualityThreshold(s));
			child = removeDuplicates(child);

			%Small chance that removing duplicates leaves us with one model
			if(getSize(child) == 1)
				m = getModels(child);
				child = m{1};
			end
		else
			%Ensemble - Model
			if(getSize(parent1) >=  s.maxSize)
				%Maximum ensemble size reached, dont add new models
				%randomly one ensemble member switches places with the model
				[child replaced] = randReplace(parent1,parent2);
			else
				if(rand > 0.8)
					%model becomes member of the ensemble
					child = addToEnsemble(parent1,parent2);
				else
					%randomly one ensemble member switches places with the model
					[child replaced] = randReplace(parent1,parent2);
				end
			end
		end	

	else
		if(isa(parent2,'EnsembleModel'))
			%Model - Ensemble
			if(getSize(parent2) >=  s.maxSize)
				%Maximum ensemble size reached, dont add new models
				%randomly one ensemble member switches places with the model
				[child replaced] = randReplace(getNestedModel(parent2),parent1);
			else
				if(rand > 0.8)
					%model becomes member of the ensemble
					child = addToEnsemble(parent2,parent1);
				else
					%randomly one ensemble member switches places with the model
					[child replaced] = randReplace(parent2,parent1);
				end
			end
		else
		  %Model - Model
		  %Create a new ensemble
		  child = EnsembleModel({parent1,parent2},getEqualityThreshold(s));
		end	

	end

	%Wrap it so it can be stored amongst the other models
	xoverKids{i,:} = child;
end

%for i=1:length(xoverKids)
%  getDescription(xoverKids{i})
%end

% Make sure all are trained
xoverKids = constructModels(xoverKids,smp,val,s.getParallelMode());

s.logger.fine(sprintf('Produced %d of %d ensemble crossover children',nKids,length(thisPopulation)));

%Some helper functions that do equality checking to prevent creating ensembles with duplicate models
%Note the equality operator used is based on comparing 2 evaluations on a dense grid. The comparison
%is very strict, the evaluations must match exactly in order to be considered identical models.
%So this will still allow very similar models to co-exist but not identical ones.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [child replaced] = randReplace(ensemble, model)
	if(~contains(ensemble,model))
		[child replaced] = randomReplace(ensemble, model);
	else
		%TODO do something else, like optimize the weights?
		child = ensemble;
	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [child] = addToEnsemble(ensemble, model)
	if(~contains(ensemble,model))
		child = addModel(ensemble,model);
	else
		%TODO do something else, like optimize the weights?
		child = ensemble;
	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

