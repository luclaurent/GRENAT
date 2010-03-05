function population = createInitialPopulation(s,GenomeLength, FitnessFcn, options)

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
%	population = createInitialPopulation(s,GenomeLength, FitnessFcn, options)
%
% Description:
%	A function that creates an initial population
%
%	The input arguments to the function are
%	     Genomelength — Number of independent variables for the fitness function
%	     FitnessFcn — Fitness function
%	     options — Options structure
%	The function returns Population, the initial population for the genetic algorithm.

if(length(options.PopulationSize) ~= (length(s.modelInterfaces)-1))
  	msg = 'The number of subpopulations does not match the number of specified model interfaces (after having ignored the Ensemble interface';
	s.logger.severe(msg);
	error(msg);
end

tmpOptions = options;

population = cell(sum(options.PopulationSize),1);

k = 1;
p = 1;
for i=1:length(s.modelInterfaces)
	mi = s.modelInterfaces{i};

	%Ensembles are only used as a product of crossover
	%between two different model types, they do not form part of the
	%initial population
	if(strcmp(class(mi),'EnsembleFactory') == 0)
		tmpOptions.PopulationSize = options.PopulationSize(p);
		p = p + 1;
	
		crFun = getCreationFcn(mi);
		pop = crFun(GenomeLength, FitnessFcn, tmpOptions);	

		population(k:k+length(pop)-1,1) = pop;
		k = k+length(pop);

		s.logger.fine(sprintf('Created %d individuals of type %s',length(pop),class(population{k-1,1})));
	end
end

if(length(population) ~= sum(options.PopulationSize))
	msg = sprintf('Not enough individuals created, %d created while %d are required',length(population),sum(options.PopulationSize));
	logger.severe(msg);
	error(msg);
else
	s.logger.fine(sprintf('Created initial heterogenous population of size %d, %d required',length(population),sum(options.PopulationSize)));
end
