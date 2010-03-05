function [s, nNew] = runSamplingLoop(s, doneBuilding, lastModels, numModelingLoops)

% runSamplingLoop (SUMO)
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
%	[s, nNew] = runSamplingLoop(s, doneBuilding, lastModels, numModelingLoops)
%
% Description:
%	Run the adaptive sampling loop.

% Check if any points are ready and fetch them if they are.
% This allows us to respect the maximum number of samples more closely.
% For example: if we just need 20 more to reach the maximum, dont submit 20 new ones
% if 30 ready samples are sitting in the output queue, waiting to be fetched.
[s nNew] = getEvaluatedSamples(s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select & submit new sample locations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update the elapsed time
elapsedTime = etime(clock,s.startTime);

% get samples & values from sample manager
[samples, values] = getInModelSpace(s.sampleManager);

% get failed samples & values from sample manager
[samplesFailed, valuesFailed] = getFailedInModelSpace(s.sampleManager);

s.logger.fine('Checking wether to select new samples');

% Now this is the key strategic decision
% We add new samples to the queue when...
%
%     a) maxSamples and maxTime have not been exceeded
%       AND
%     b) the sample evaluator has not been disabled
%		AND
%
%     		c) at least one model builder has not yet reached his targets
%               OR
%     		d) the minimum required number of samples has not yet been reached

if (elapsedTime/60 <= s.maximumTime) && (s.sampleEvaluator.getStatus.isActive()) && (s.numSamples <= s.maximumTotalSamples) && (numModelingLoops < s.maxModelingIterations)
    
    s.logger.finer('One of the following two conditions should be true in order to add new samples:');
    addSamples = false;
    
    if ~all(doneBuilding)
        s.logger.finer('   - Some targets have not been reached...yes');
        addSamples = true;
    else
        s.logger.finer('   - Some targets have not been reached...no');
    end
    
    if s.numSamples < s.minimumTotalSamples
        s.logger.finer('   - The minimum total samples has not been reached...yes');
        addSamples = true;
    else
        s.logger.finer('   - The minimum total samples has not been reached...no');
    end
    
    if(addSamples)
        s.logger.finer(sprintf('At least one condition true, selecting new samples'));
        
        s.logger.info( sprintf( '') );
        s.logger.info( sprintf( '*** Starting new adaptive sampling iteration') );
        s.logger.info( sprintf( '') );
        s.logger.info( sprintf( 'Currently %d samples are already available while %d are pending', s.numSamples, s.sampleEvaluator.getNumPendingSamples() ) );
        s.logger.finest(sprintf('Looping over %d sample selector objects',length(s.sampleSelector.objects)));
        
        % calculate how many new samples we need
        numNewSamples = calculateNumNewSamples(s);
        
        %TODO: this is somewhat of a hack but its the cleanest option I saw
        %it could be that all targets have been reached but that the minimum number of samples
        %has not.  In this case no new samples will be added  Check for this case
        if ( all(doneBuilding) && (s.numSamples < s.minimumTotalSamples) )
            %Manually force selection for new samples by pretending that the first
            %model builder really hasnt converged
            doneBuilding(1) = 0;
        end
        
        % get the total number of outputs (both done and not done)
        numOutputs = length(doneBuilding);
        
        % go over all sample selectors and check which outputs should
        % 'receive' new samples
        giveSamples = true(numOutputs,1);
        for i = 1 : length(s.sampleSelector.objects)
            
            % empty sample selectors should not receive samples
            if isa(s.sampleSelector.objects{i}, 'EmptySampleSelector')
                giveSamples(s.sampleSelector.outputCoverage{i}) = false;
            end
        end
        
        % outputs which were done building, should not receive samples
        giveSamples(doneBuilding) = false;
        
        % no sample selectors which are to receive samples at this point
        if ~any(giveSamples)
            numNewSamples = 0;
        end
        
        % get number of outputs that actually do receive new samples
        numEnabledOutputs = sum(giveSamples);
        
        % distribute evenly over outputs
        % if samples remain, distribute randomly over selectors
        % TODO: this can be done more intelligently, based on closeness to
        % targets?
        samplesPerSelector = zeros(numOutputs,1);
        samplesPerSelector(giveSamples) = repmat(floor(numNewSamples / numEnabledOutputs), numEnabledOutputs, 1);
        
        samplesLeft = numNewSamples - sum(samplesPerSelector);
        order = randperm(numEnabledOutputs);
        order = order(1:samplesLeft);
        candidates = find(giveSamples);
        order = candidates(order);
        
        samplesPerSelector(order) = samplesPerSelector(order) + 1;
        
        
        % rename for further use
        samplesPerOutput = samplesPerSelector;
        
        % go over all sample selectors
        numSelectedSamples = 0;
        for i = 1 : length(s.sampleSelector.objects)
            outputCoverage = s.sampleSelector.outputCoverage{i};
            outname = arr2str(s.outputNames(outputCoverage));
            
            % construct the state based on the output mapping
            state = struct;
            state.samples = samples;
            state.values = values(:,outputCoverage);
            state.samplesFailed = samplesFailed;
            
            if(size(valuesFailed,1) > 0)
                state.valuesFailed = valuesFailed(:, outputCoverage);
            else
                state.valuesFailed = [];
            end
            
            state.triangulation = getTriangulationObj(s.sampleManager);
            state.lastModels = lastModels(outputCoverage);
            
            % add number of samples to be evaluated
            state.numNewSamples = sum(samplesPerOutput(outputCoverage));
            
            if(state.numNewSamples == 0)
                s.logger.fine(sprintf('Skipping sample selector %d for output %s',i, outname));
                continue;
            end
            
            % Select new samples
            % if all of the builders related to this selector are done,
            % we stop selecting samples unless we have not reached minSamples yet
            %TODO: this could be made more intelligent
            if (~all(doneBuilding(outputCoverage)) || (s.numSamples < s.minimumTotalSamples))
                
                s.logger.fine(sprintf('Requesting %d points from sample selector %d for output %s', state.numNewSamples, i, outname));
                
                % select samples
                [s.sampleSelector.objects{i}, newSamplePoints, newPriorities] = ...
                    selectSamples( s.sampleSelector.objects{i}, state );
                
                s.logger.fine(sprintf('Enqueueing %d newly selected points for output %s', size(newSamplePoints,1), outname));
                
                %log to profiler
                s.sampleBatchProfiler.addEntry(size(newSamplePoints,1));
                
                % Enqueue new samples
                [s, nSuccesfullyQueued] = queueSamples(s, newSamplePoints, newPriorities);
                numSelectedSamples = numSelectedSamples + size(newSamplePoints,1);
                s.logger.info(sprintf('%d new points queued for output %s', nSuccesfullyQueued, outname));
            else
                s.logger.fine(sprintf('All model builders related to sample selector %d have converged, not selecting new samples',i));
            end
        end
        
        pendingSamples = s.sampleEvaluator.getNumPendingSamples();
        evaluatedSamples = s.sampleEvaluator.getNumEvaluatedSamples();
	if(numNewSamples > 0)
        	s.logger.info(sprintf('%d new samples have been submitted, a total of %d samples are pending, %d are ready', numNewSamples, pendingSamples,evaluatedSamples));
	end
        
        % now we keep polling for samples until the minimum has been reached
        minimumSamples = numSelectedSamples * s.minimumAdaptiveSamples / 100;
        
        % we also calculate the number of max pending samples we allow
        maxPending = numSelectedSamples - minimumSamples;
        
        % give a short time to evaluate samples and do at least one initial update
        % Give other threads a second to return results
        pause(1);
        [s tmp] = getEvaluatedSamples(s);
        nNew = nNew + tmp;
        
        pendingSamples = s.sampleEvaluator.getNumPendingSamples();
        evaluatedSamples = s.sampleEvaluator.getNumEvaluatedSamples();
        
        % now keep doing additional checks until we have reached our minimum
        % the second codition is important since it prevents an infinite loop if sample points have failed
        while nNew < minimumSamples && (pendingSamples + evaluatedSamples) > maxPending
            pause(1);
            [s tmp] = getEvaluatedSamples(s);
            nNew = nNew + tmp;
            
            % make sure the sample evaluator is still ok
            if(~s.sampleEvaluator.getStatus.isActive())
                s.logger.warning(sprintf('The sample evaluator is no longer active, waiting for the %d pending points doesnt make sense anymore',pendingSamples));
                break;
            end
            
            pendingSamples = s.sampleEvaluator.getNumPendingSamples();
            evaluatedSamples = s.sampleEvaluator.getNumEvaluatedSamples();
        end
        
    else
        s.logger.finer(sprintf('All conditions false, not selecting new samples'));
    end
else
    if(elapsedTime/60 > s.maximumTime)
        s.logger.finer(sprintf('Not selecting new samples since the maximum time of %d minutes has been exceeded',s.maximumTime));
    end
    
    if(s.numSamples > s.maximumTotalSamples)
        s.logger.finer(sprintf('Not selecting new samples since the maximum total number of samples %d  has been exceeded',s.maximumTotalSamples));
    end
    
    if(numModelingLoops >= s.maxModelingIterations)
        s.logger.finer(sprintf('Not selecting new samples since the maximum number of modeling iterations %d  has been exceeded',s.maxModelingIterations));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve evaluated samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [s nNew] = getEvaluatedSamples(s)

% Fetch all evaluated points from the sample evaluator
[s,newSamples,newValues] = fetchEvaluatedPoints(s);

% add them
[s.sampleManager, nNewSamples] = add(s.sampleManager, newSamples, newValues);
[smp val] = getInModelSpace(s.sampleManager);
s.numSamples = size(smp,1);

% How many samples are currently pending evaluation
pendingSamples = s.sampleEvaluator.getNumPendingSamples();

if(nNewSamples > 0)
    
    s.logger.info(sprintf('Fetched %d newly evaluated samples, %d samples still pending...', nNewSamples, pendingSamples));
    
    % update samples.txt
    saveToDisk(s.sampleManager, s.outputDirectory);
    
    %So new samples were added, and duplicate points removed, what is the net outcome?
    nNew = nNewSamples;
    
    if nNew > 0
        s.logger.fine(sprintf('Processed %d new samples, %d still pending, a total of %d samples are finished.', nNewSamples, pendingSamples, s.numSamples));
    else
        s.logger.info(sprintf('All the new samples turned out to be duplicates, ignored...'));
    end
else
    nNew = 0;
    s.logger.fine(sprintf('No newly evaluated samples available, %d still pending....',pendingSamples));
end
