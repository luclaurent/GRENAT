function [s, bestModel] = runLoop(s, passedSamples, passedValues)

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
%	[s, bestModel] = runLoop(s, passedSamples, passedValues)
%
% Description:
%	The core loop of the toolbox resides in this file (adaptive modeling loop + adaptive sampling loop).
%	After an SUMO object is created, control is transfered to this method to handle the metamodeling proces.

import import ibbt.sumo.profiler.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the initial samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Detect is samples/values were passed and do some sanity checking
if exist('passedSamples', 'var') == 0 || exist('passedValues', 'var') == 0
	passedSamples = [];
	passedValues = [];
end

[passedSamples passedValues samplesPassed] = handlePassedSamples(s,passedSamples,passedValues);

% Start the timer
s.startTime = clock;

if samplesPassed
	% A fixed set of samples were passed on the command line, use this set for adaptive modeling only
	s.logger.info('Samples were passed on the commandline');
	s.logger.warning('The passed samples will have their values filtered according to the output selection configuration in the config file');

	% add to samples list
	[s.sampleManager] = add(s.sampleManager, passedSamples, passedValues);
end

% Is adaptive sampling switched on?
% An empty sampleSelector means we are only doing adaptive modeling
adaptiveSampling = ~isempty(s.sampleSelector);
if adaptiveSampling
		% Running in adaptive sampling mode
		s.logger.info('A SampleSelector is specified, adaptive sampling enabled');
		
		% Generate and evaluate the initial set of samples
		[s] = handleInitialSamples(s);
else
	% Running in adaptive modeling mode
	s.logger.warning('No SampleSelector specified, running in Adaptive Modeling mode (sampling is switched off), max samples set to infinity');
	s.maximumTotalSamples = Inf;

	% only fetch the entire dataset IF we haven't passed on any samples through the command line
	if isa(s.sampleEvaluator, 'ibbt.sumo.sampleevaluators.datasets.DatasetSampleEvaluator') ...
			&& ~samplesPassed ...
			&& ~s.adaptiveModelingInitialDesignOnly
		
		% Adaptive modeling with data set, extract the full dataset
		[samples,values] = extractRawDataset(s.sampleEvaluator.getData());

		% add to samples manager
		[s.sampleManager] = add(s.sampleManager, samples, values);

		% get the number of samples
		[smp val] = getInModelSpace(s.sampleManager);
		s.numSamples = size(smp,1);
	else
		
		% Adaptive modeling with a simulator
		% Generate and evaluate the initial set of samples
		[s] = handleInitialSamples(s);
	end
end

if (size(getInModelSpace(s.sampleManager),1) < 2)
	msg = sprintf('After filtering less than 2 samples remain. However, the toolbox needs at least 2 to continue...aborting..');
	s.logger.severe(msg);
	error(msg);
end

% save initial samples to samples.txt
saveToDisk(s.sampleManager, s.outputDirectory);

s.logger.fine('Processing of initial samples finished, getting ready for main loop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main toolbox loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Do some initialization
elapsedTime = 0;
nNew = 0;

% get model grid manager singleton
modelGridManager = Singleton('ModelGridManager');

% stop criteria
allFinished = false;

% data for estimating the average time for one modeling iteration
numModelingLoops = 0;

% set startTime
for i = 1 : length(s.adaptiveModelBuilder.objects)
	builder = s.adaptiveModelBuilder.objects{i};
	builder = setStartTime(builder,s.startTime,s.maximumTime);
	s.adaptiveModelBuilder.objects{i} = builder;
end

s.logger.fine('Starting the main toolbox loop');

% Continue running the toolbox if...
% ...there remain some evaluated, but not yet processed, samples
%		OR
% ...(the maximal number of samples has not been reached AND
% ...the maximal runtime has not been reached AND
% ...the maximal number of modeling iterations has not been reached AND
% ...    (targets have not yet been reached 
%	          OR 
% ...    the minimum number of samples has not yet been reached)
%....)
while ( (nNew > 0) || ...
	    ((s.numSamples <= s.maximumTotalSamples) && ...
	    (elapsedTime/60 <= s.maximumTime) && ...
	    (numModelingLoops < s.maxModelingIterations) && ...
	    ((~allFinished) || s.numSamples < s.minimumTotalSamples))...
      )

	s.logger.finer( ...
		[sprintf('New toolbox iteration\n') ...
		 sprintf('     - Sample size = %d\n', s.numSamples) ...
		 sprintf('     - Samples pending evaluation = %d\n', s.sampleEvaluator.getNumPendingSamples()) ...
		 sprintf('     - Waiting evaluated samples = %d', s.sampleEvaluator.getNumEvaluatedSamples()) ] ...
	);

	% reset the model grid manager
	modelGridManager = modelGridManager.resetGrid();
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Adaptive modeling loop
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% next modeling loop
	numModelingLoops = numModelingLoops + 1;
	
	% run the modeling loop
	[s, lastModels, doneBuilding] = runModelingLoop(s, numModelingLoops, nNew);
	allFinished = all(doneBuilding);
	
	s.logger.finer('Adaptive modeling loop completed');
	
	% Update the elapsed time
	elapsedTime = etime(clock,s.startTime); 
	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Adaptive sampling loop
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
	% get status of sample evaluator
	sampleEvaluatorStatus = s.sampleEvaluator.getStatus();
	
	% sample evaluator was permanently disabled for some reason
	if adaptiveSampling && (~sampleEvaluatorStatus.isActive())
		if(s.stopOnError)
			% stop the main loop
			s.logger.severe(sprintf('Sample evaluator disabled, breaking out of loop. Reason for disabling: %s', char(sampleEvaluatorStatus.getErrorMessage())));
			break;
		else
			% switch to adaptive modeling mode
			s.logger.severe(sprintf('Sample evaluator disabled, switched to adaptive modeling mode. Reason for disabling: %s', char(sampleEvaluatorStatus.getErrorMessage())));
			adaptiveSampling = false;
		end
	end
	
	% Is adaptive sampling switched on?
	if (adaptiveSampling)
		[s, nNew] = runSamplingLoop(s, doneBuilding, lastModels, numModelingLoops);
	else
		% no sampling since sampling is explicitly switched off
	end
	
	%Calculate the elapsed time in seconds
	elapsedTime = etime(clock,s.startTime);
	
% end of main loop
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cleanup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s.logger.fine('Main loop has finished, cleaning up...');

numMB = length(s.adaptiveModelBuilder.objects);

bestModel = cell(numMB,1);

if(numMB > 1)
	%Since different model builders can be used in parallel, the final best models
	%may have different types, therefore we have to place them in a cell array
	for i=1:numMB
		builder = s.adaptiveModelBuilder.objects{i};
		% TODO when can it be empty?
		if(~isempty(getBestModel(builder)))
			bestModel{i} = getBestModel(builder);
		end
	end
else
	builder = s.adaptiveModelBuilder.objects{1};
	bestModel{1} = getBestModel(builder);
end

% Give the sample evaluators time to cleanup
s.sampleEvaluator.cleanup();

if(s.numSamples > s.maximumTotalSamples)
	s.logger.warning( sprintf('Main loop terminated prematurely, maximum number of samples (%d) exceeded, last model(s) built with %d samples',s.maximumTotalSamples,s.numSamples) )
end

if (elapsedTime/60 > s.maximumTime)
	s.logger.warning( sprintf('Main loop terminated prematurely, time limit (%d min) exceeded, last model(s) built with %d samples',s.maximumTime,s.numSamples) )
end

if (numModelingLoops >= s.maxModelingIterations)
	s.logger.warning( sprintf('Main loop terminated prematurely, maximum number of modeling iterations (%d) exceeded, last model(s) built with %d samples',s.maxModelingIterations,s.numSamples) )
end

% Print out a summary of the modeling results
curTime = clock;
s.logger.info('');
s.logger.info(sprintf('---------------------------------------------------------------------'));
s.logger.info(sprintf('SUMO Toolbox summary:'));
s.logger.info(sprintf(''));
s.logger.info(sprintf('Number of samples evaluated: %d', s.numSamples));
s.logger.info(sprintf('Terminated on %s %d:%d:%d', date,curTime(4),curTime(5),round(curTime(6))));
if (elapsedTime < 120)
	s.logger.info(sprintf('Elapsed time: %u seconds', round(elapsedTime)));
elseif (elapsedTime < 120*60)
	s.logger.info(sprintf('Elapsed time: %u minutes', round(elapsedTime/60)));
else
	s.logger.info(sprintf('Elapsed time: %u hours', round(elapsedTime/3600)));	
end
s.logger.info(sprintf('Outputs:'));
for i = 1 : length(s.adaptiveModelBuilder.objects)
	printBestResults(s.adaptiveModelBuilder.objects{i});
end
s.logger.info(sprintf('---------------------------------------------------------------------'));

%If configured, create a movie of the model plots
if(s.createMovie)
    builders = s.adaptiveModelBuilder.objects;
	for i=1:length(builders);
		builder = builders{i};
		createMovie(builder);
	end
end
