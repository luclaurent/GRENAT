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
%	The main loop. Runs a full GA before returning.

import java.util.*;
import ibbt.sumo.profiler.*;
import java.util.logging.*;

% get samples and values
[samples,values] = getData(s);

%---- A rather ugly hack thanks to Matlabs wonderful OO implementation :s
% inform the interface of the number of samples available
mi = getModelFactory(s);
mi = setSamples(mi,samples,values);

% Since we changed the model interface we need to re-wrap the the functions
% because the model interface object stored as part of the function handle has not
% been changed.
%[mi] = wrapFunctions(mi); % now called in setSamples

s = setModelFactory(s,mi);

% Remember to update the options with the updated function handles
s.options = gaoptimset(s.options, 'CreationFcn',	getCreationFcn(mi));
s.options = gaoptimset(s.options, 'CrossoverFcn',	getCrossoverFcn(mi));
s.options = gaoptimset(s.options, 'MutationFcn',	getMutationFcn(mi));
%-----

% are we evolving models (custom population type) or parameter vectors (doubleVector type)
customPopType = strcmp(gaoptimget(s.options,'PopulationType'),'custom');

%Get lower and uppber bounds on the model parameters (may be [])
if(customPopType)
    LB = [];
    UB = [];
else
    [LB UB] = getBounds(getModelFactory(s));
end

% Are we evolving different model types? (heterogenetic mode)
heteroMode = isa(getModelFactory(s),'HeterogeneousFactory');

% Are we in multi-objective mode?
paretoMode = getParetoMode(s);

%Ensure we respect the global maximum time limit set by the user
elTime = etime(clock,getStartTime(s)); 	 %How many seconds have passed since the toolbox was started
maxTime = getMaximumTime(s)*60; 	 %How many seconds is the toolbox allowed to run in total
remainingTime = max(1,maxTime - elTime); %How many seconds do we have left

s.options = gaoptimset(s.options,'TimeLimit',remainingTime);
s.logger.fine(sprintf('GA time limit set to %d minutes',remainingTime/60));

%Get the constraint function (may be [])
constraintFcn = getConstraintFcn(getModelFactory(s));

% If this is the very first run the population is still empty and the creation function will be used
% Else seed the population based on the previous run

if(isempty(s.population))
    % do nothing
else
    popSize = size(s.population,1);
    popChanged = false;
    
    % Are we dealing with a population of models or a population of parameter vectors (doubles)
    if(customPopType)
        
        if(strcmp(getRestartStrategy(s),'model'))
            % clear the population, this will cause the creation function to be run again
            s.population = {};
            popChanged = true;
        else
            % only continue (will be forced if necessary)
            [initPop s] = generateNewModels(s, popSize, 1, s.population);
            s.population = initPop;
            
            % since we are continuing we have to check if new samples
            % arrived since the previous iteration.  If this is the case
            % the population needs to be updated with the new data
            
            if(isSamplingEnabled(s))
                % yup, sampling is enabled, update all models
                
                s.logger.fine(sprintf('New samples may have arrived since the last iteration, updating all %d models first',length(s.population)));
                
                s.population = constructModels(s.population,samples,values,getParallelMode(s));
                popChanged = true;
            else
                popChanged = false;
            end
        end
        
        % set the population
        s.options = gaoptimset(s.options,'InitialPopulation',s.population);
        
    else
        [initPop s] = generateNewModels(s, popSize, 0, s.population);
        s.population = initPop;
        
        % set the population
        s.options = gaoptimset(s.options,'InitialPopulation',s.population);
        
        % did the population change
        if(strcmp(getRestartStrategy(s),'continue'))
            popChanged = false;
        else
            popChanged = true;
        end
        
    end
    
    % If sampling is switched off and the population is not changed we can also seed the previous
    % scores (since they are still valid, no sampling) then we dont have to calculate the fitness
    % function on every individual in the first generation
    if(~popChanged && ~isSamplingEnabled(s))
        s.options = gaoptimset(s.options,'InitialScores',s.scores);
        s.logger.fine('Seeding scores from previous GA run');
    else
        s.logger.fine('NOT seeding scores from previous GA run, since the samples have changed');
    end
    
end

%Set the output function (called after every generation) for progress monitoring
s.options = gaoptimset(s.options,'OutputFcn', @outputFunction);

%The initial population range should respect the given parameter bounds (if no creation function was specified)
if(~isempty(LB) && ~isempty(UB))
    s.options = gaoptimset(s.options,'PopInitRange',[LB;UB]);
end

% scoreModel changes the modes, but this can not be reflected in the population
% keep a copy of the changed models so we can save them in the output function
scoredModels = {};
modelScores = [];
% we also need to keep those of the previous generation to support the island model
prevScoredModels = {};
prevModelScores = [];
prevScoredModels2 = {};

% Nested function that computes the objective function
    function popScores = fitnessFunction(pop)
        [scores s mods] = defaultFitnessFunction(s,pop,~customPopType);
        popScores = scores;
        
        scoredModels = [scoredModels ; mods];
        modelScores = [modelScores ; scores];
    end

    function model = modelFixFunction( populationEntry )
        if(iscell(populationEntry))
            populationEntry = populationEntry{1};
        end
        
        if(isa(populationEntry,'Model'))
            % It's already a fitted model
            model = populationEntry;
        else
            % Make it a model
            model = createModel(getModelFactory(s), populationEntry);
        end
    end

% Nested output function to save the state after each generation
    function [state, options,optchanged] = outputFunction(options,state,flag,interval)
        
        if(strcmp(flag,'init'))
            % this means the initial population has been scored, but the GA
            % has not started yet
            
            prevScoredModels = state.Population;
            prevModelScores = state.Score;
            
            %disp(sprintf('** The population of the PREVIOUS ITERATION BEFORE extinction prevention at generation %d:',state.Generation));
            %printHeteroPop(options.PopulationSize,prevScoredModels,prevModelScores);
            
            % save the very first pareto front
            if(paretoMode)
                prevScoredModels2 = scoredModels;
                saveParetoFront(prevScoredModels2,s);
            end
            
        elseif(strcmp(flag,'iter') || strcmp(flag,'done'))
            
            %Do extinction prevention (only useful in a heterogeneous context)
            if(s.extPrev && heteroMode)
                % Note that we dont use scoredModels here, since if we did we would lose all migration effects
                % this means however, that the models in state.Population do not have their inputNames/transformationValues/..
                % set since this is set in scoreModels....
                curModels = state.Population;
                curScores = state.Score;
                
                %disp(sprintf('** The previous population, BEFORE extinction prevention at generation %d:',state.Generation));
                %printHeteroPop(options.PopulationSize,prevScoredModels,prevModelScores);
                
                %disp(sprintf('** The current population, BEFORE extinction prevention at generation %d:',state.Generation));
                %printHeteroPop(options.PopulationSize,state.Population,state.Score);
                
                % do the extinction prevention
                [newPop newScores] = extinctionPrevention(s,options.PopulationSize,prevScoredModels,prevModelScores,curModels,curScores, s.minTypeCount);
                
                % set the new  population
                state.Population = newPop;
                state.Score = newScores;
                
                %disp(sprintf('** The current population, AFTER extinction prevention at the end of the generation %d:',state.Generation));
                %printHeteroPop(options.PopulationSize,state.Population,state.Score);
                
                % save for the next iteration
                prevScoredModels = newPop;
                prevModelScores = newScores;
            end
            
            if(strcmp(flag,'iter'))
                % if pareto mode is enabled, we want to save the pareto front
                % (=final population) at the end of the GA (when flag == done).
                % However, this means we have to keep a copy of the last scored
                % population (scoreModels changes the population remember)
                if(paretoMode)
                    % TODO Note that we dont care what extinctionPrevention does
                    % This means that if the very last generation extinctionPrevention changes the population
                    % (ie, it resurrects a few model types) then this will NOT be reflected in the final pareto front
                    % saved to disk for that generation!  Note that if we did save the population changed by extprev
                    % we would be saving incomplete models (ie, transformation values, inputnames, ... not set).
                    % I really dont like all of this, but as long as the fitness function changes the population there is no way around it
                    prevScoredModels2 = scoredModels;
                end
                
                % save the pareto front to disk every xx generations
                if(paretoMode && (mod(state.Generation,s.paretoSaveInterval) == 0))
                    saveParetoFront(prevScoredModels2,s);
                end
                
            else
                % The GA has finished, cleanup
                % TODO I dont like this hack but its the cleanest solution for now
                % save the pareto front to disk at the end of each ga run (if we are in multi objective mode that is)
                if(paretoMode)
                    saveParetoFront(prevScoredModels2,s);
                end
            end
        else
            error('Invalid flag state');
        end
        
        % Ok, we can now safely discard models/scores of this
        % generation
        scoredModels = {};
        modelScores = [];
        
        % Continue with the normal stuff..
        
        % Do profiling
        data = struct( 'population', {state.Population}, 'scores', state.Score, 'callback', @modelFixFunction );
        s = observe( s, 'gen', s.generationCounter, data );
        s.varianceProfiler.addEntry([s.generationCounter var(state.Score)]);
        
        if(~customPopType)
            s.distanceProfiler.addEntry([s.generationCounter avgDistance(state.Population)]);
        end
        
        s.state = state;
        optchanged = 0;
        s.generationCounter = s.generationCounter+1;
        
        s.logger.fine(sprintf('Finished generation %d of %d',state.Generation,options.Generations));
    end

%Actually run the GA
if paretoMode
    [result fitness exitflag output] = gamultiobj(@fitnessFunction,getIndividualSize(getModelFactory(s)),[],[],[],[],LB,UB,s.options);
    reason = output.message;
else
    [result fitness exitflag output] = ga(@fitnessFunction,getIndividualSize(getModelFactory(s)),[],[],[],[],LB,UB,constraintFcn,s.options);
    reason = output.message;
end

if(~isempty(reason))
    s.logger.fine(['GA termination reason: ' reason]);
end

%Save the final population + scores for following runs
s.population = s.state.Population;
s.scores = s.state.Score;

% Do some more profiling
data = struct( 'population', {s.population}, 'scores', s.scores, 'callback', @modelFixFunction );

if(isSamplingEnabled(s))
    s = observe( s, 'run', size(samples,1), data );
else
    s = observe( s, 'run', s.generationCounter, data );
end



end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Utility functions

function saveParetoFront(models,this);
if (~isempty(models))
    d=fullfile(this.getOutputDirectory(),'paretoFronts');
    
    if (~isdir(d))
        mkdir(d);
    end
    
    fileName = fullfile(d,sprintf('paretoFront_%04d.mat',this.generationCounter));
    pf = models;
    save( fileName, 'pf' );
else
    this.logger.severe('Not saving pareto front to disk as it is empty!');
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
