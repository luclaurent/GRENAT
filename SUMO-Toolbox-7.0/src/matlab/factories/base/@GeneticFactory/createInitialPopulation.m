function population = createInitialPopulation(this, GenomeLength, FitnessFcn, options)

% createInitialPopulation (SUMO)
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
%	population = createInitialPopulation(this, GenomeLength, FitnessFcn, options)
%
% Description:
%	A function that creates an initial population
%
%	The input arguments to the function are
%	     Genomelength : Number of independent variables for the fitness function
%	     FitnessFcn : Fitness function
%	     options : Options structure
%	The function returns Population, the initial population for the genetic algorithm.

[smp val] = getSamples(this);

% sum all islands together
popSize = sum(options.PopulationSize);

if(strcmp(options.PopulationType,'custom'))
	% Create models
	pop = createInitialModels(this, popSize, 1);
  
	% Make sure all are trained
	pop = constructModels(pop,smp,val,this.getParallelMode());

	% convert to a cell
	population = cell(popSize,1);	
	for i=1:popSize
	  population{i} = pop(i);
	end

elseif(strcmp(options.PopulationType,'doubleVector'))
	% Create model parameter vectors
	population = createInitialModels(this, popSize, 0);
else
	error('Invalid population type used, valid values are custom and doubleVector');
end
