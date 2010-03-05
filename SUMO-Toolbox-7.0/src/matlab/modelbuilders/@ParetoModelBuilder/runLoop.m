function [s] = runLoop(s)

% runLoop (SUMO)
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
%	[s] = runLoop(s)
%
% Description:
%	The main loop. Runs a full NSGA-II run before returning.

import java.util.*;
import ibbt.sumo.profiler.*;
import java.util.logging.*;

% get samples and values
[samples,values] = getData(s);

% inform the interface of the samples available
mi = getModelFactory(s);
mi = setSamples(mi,samples,values);
s = setModelFactory(s,mi);

%Get lower and uppber bounds on the model parameters (may be [])
[LB UB] = getBounds(getModelFactory(s));

%Ensure we respect the global maximum time limit set by the user
elTime = etime(clock,getStartTime(s)); 	 %How many seconds have passed since the toolbox was started
maxTime = getMaximumTime(s)*60; 	 %How many seconds is the toolbox allowed to run in total
remainingTime = max(1,maxTime - elTime); %How many seconds do we have left

s.options.TimeLimit = remainingTime;
s.logger.fine(sprintf('GA time limit set to %d minutes',remainingTime/60));

popSize = s.options.PopulationSize;

[initPop s] = generateNewModels(s, popSize, 0, s.population);
s.population = initPop;

if(strcmp(getRestartStrategy(s),'continue') && ~isSamplingEnabled(s))
	% scores can be seeded
else
	s.scores = [];
end

% set the initial population and scores
s.options.InitialPopulation = s.population;
s.options.InitialScores = s.scores;

%Set the output function (called after every generation) for progress monitoring
s.options.OutputFcn = @outputFunction;

%The initial population range should respect the given parameter bounds (if no creation function was specified)
if(~isempty(LB) && ~isempty(UB))
	s.options.PopInitRange = [LB;UB];
end

% keep a copy of the model objects
scoredModels = {};

	% Nested function that computes the objective function
	function popScores = fitnessFunction(pop)
		[popScores s mods] = defaultFitnessFunction(s,pop);
		scoredModels = [scoredModels ; mods];
	end
	
	function model = modelFixFunction( populationEntry )
		% Make it a model	
		model = createModel(getModelFactory(s), populationEntry);
	end

	
	% Nested output function to do some profiling after each generation
	function outputFunction(options, population, scores, generation)
		
		% TODO hack to save the pareto front to disk at the end of the run
		if ( ((generation == options.Generations) || (mod(options.Generations,s.paretoSaveInterval) == 0))  && ~isempty(scoredModels))
			d=fullfile(s.getOutputDirectory(),'paretoFronts');
			if (~isdir(d))
				mkdir(d);
			end
			fileName = fullfile(d,sprintf('paretoFront_%04d.mat',s.generationCounter));
			pf = scoredModels;
			save( fileName, 'pf' );
		else
	
		end
	
		scoredModels = {};

		% Do profiling
		data = struct( 'population', population, 'scores', scores, 'callback', @modelFixFunction );
		s = observe( s, 'gen', s.generationCounter, data );		

	        s.logger.fine(sprintf('Finished generation %d of %d', generation,options.Generations));
		s.generationCounter = s.generationCounter+1;
	end


%Actually run the GA
problem = struct( 'fitnessfcn', @fitnessFunction, ...
				  'nvars', getIndividualSize(getModelFactory(s)), ...
				  'nobjectives', getNumObjectives(s), ...
				  'options', s.options );
			  
[s.population s.scores reason] = nsga2( problem );

if(length(reason) > 0)
	s.logger.fine(['GA termination reason: ' reason]);
end

% Do some more profiling
data = struct( 'population', s.population, 'scores', s.scores, 'callback', @modelFixFunction );

if(isSamplingEnabled(s))
  s = observe( s, 'run', size(samples,1), data );
else
  s = observe( s, 'run', s.generationCounter, data );
end

end
