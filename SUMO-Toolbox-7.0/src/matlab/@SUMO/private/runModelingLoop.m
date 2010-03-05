function [s, lastModels, doneBuilding] = runModelingLoop(s, numLoop, nNewSamples)

% runModelingLoop (SUMO)
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
%	[s, lastModels, doneBuilding] = runModelingLoop(s, numLoop, nNewSamples)
%
% Description:
%	Perform the adaptive modelling loop.

s.logger.info( sprintf( '') );
s.logger.info( sprintf( '*** Starting new adaptive modeling iteration') );
s.logger.info( sprintf( '') );
	
% start the modelling loop stopwatch
startModellingLoop = clock;

% Now let each model builder run on the available data (adaptive modeling loop)
s.logger.fine(sprintf('Running all model builders on %d samples...',s.numSamples));

% get samples & values from list
[samples, values] = getInModelSpace(s.sampleManager);

% initialize best models & done building cells
lastModels = cell(s.outputDimension, 1);
doneBuilding = false(s.outputDimension, 1);

for i = 1 : length(s.adaptiveModelBuilder.objects)

	%Calculate the elapsed time in seconds and break if it is exceeded
	elapsedTime = etime(clock,s.startTime); 
	if(elapsedTime/60 > s.maximumTime)
		s.logger.warning(sprintf('Maximum time of %d minutes has been exceeded, breaking out of loop, %d out of %d model builder objects were allowed to run',s.maximumTime,i,length(s.adaptiveModelBuilder.objects)));
		return;
	end

	% Get the builder
	builder = s.adaptiveModelBuilder.objects{i};

	% What outputs does the builder cater for
	outputCoverage = s.adaptiveModelBuilder.outputCoverage{i};

	% Only select the outputs that are covered by this builder
	filteredValues = values(:,outputCoverage);

	% build the state to be passed to the model builder
	state = struct;
	state.samples = samples;
	state.values = filteredValues;
	state.triangulation = getTriangulationObj(s.sampleManager);

	% Pass samples and values on to the model builder
	builder = setData(builder, state);

	% Does the data contain any new samples (compared to the previous iteration)?
	if(nNewSamples > 0)
		% Tell the builder to rebuild the best model trace	
		s.logger.fine(sprintf('New data has arrived since the previous iteration, rebuilding the best model trace for %s',class(builder)));
		builder = rebuildBestModel(builder, s.keepOldModels);
		
        % Note: it is possible that the rebuild has generated a model which
		% reaches the targets, or alternatively, that the targets were
		% reached but after the rebuild they are no longer reached

        s.logger.fine(sprintf('Rebuilding best model trace for %s done..',class(builder)));
	end

	% Let the builder converge to the currently best model (if it hasnt already reached the targets)
	% TODO this check really belongs in the AMB objects themselves
	if(~done(builder))
		s.logger.finer(sprintf('Starting the runloop for %s (nr %d)',class(builder),i));
		builder = runLoop(builder);
	end

	% Update last models for each output processed by this builder
	% Update for each processed output wether we are done or not
	for j = 1 : length(outputCoverage)
		
		% get best models
		output = outputCoverage(j);
		lastModels{output} = getBestModels(builder, +Inf);
		
		% place output filters around the models
		for k = 1 : length(lastModels{output})
			lastModels{output}{k} = OutputFilterWrapper(lastModels{output}{k}, j);
		end
		
		% done or not?
		doneBuilding(output) = done(builder);
	end

	% save changes to model builder
	s.adaptiveModelBuilder.objects{i} = builder;
end

% update the average modelling loop time
%s.averageModellingTime = (s.averageModellingTime * (numLoop-1) + round(etime(clock,startModellingLoop) * 1000)) / numLoop;

%only use the time of the current iteration
s.averageModellingTime = etime(clock,startModellingLoop);


