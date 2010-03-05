function [s] = handleInitialSamples(s)

% handleInitialSamples (SUMO)
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
%	[s] = handleInitialSamples(s)
%
% Description:
%	Take care of generating and evaluating the initial samples

% Generate the Initial Samples
initialSamples = [];
evaluatedInitialSamples = [];
for initialdesign = s.initialDesign.objects
	[is, eis] = generate(initialdesign{1});
	
	initialSamples = [initialSamples ; is];
	evaluatedInitialSamples = [evaluatedInitialSamples ; eis];
end

if size(evaluatedInitialSamples,1) > 0
	% add evaluated initial samples to samples list
	[s.sampleManager] = add(s.sampleManager, evaluatedInitialSamples(:,1:s.simulatorDimension), evaluatedInitialSamples(:,s.simulatorDimension+1:end));
end

% inital sample size = samples from initialdesigns + samples passed on commandline
initialSampleSize = size(initialSamples,1) + getNrSamples(s.sampleManager);
switch s.minimumInitialSamplesType
	case 'count'
		s.minimumInitialSamples = truncate(fix(s.minimumInitialSamples), 1, initialSampleSize);
	case 'percentage'
		s.minimumInitialSamples = truncate( ...
			fix( s.minimumInitialSamples * initialSampleSize ), 1, initialSampleSize );
	otherwise
		msg = sprintf('Unknown value for `minimumSampleType'': [%s]', s.minimumInitialSamplesType);
		s.logger.severe(msg);
		error(char(msg));
end

% Queue the initial samples
if (initialSampleSize ) < 2
	msg = 'Number of initial samples must be at least 2!';
	s.logger.severe(msg);
	error(msg);
elseif (initialSampleSize > s.maximumTotalSamples)
	msg = sprintf('The number of initial samples (%d), exceeds the maximum total number of samples (%d), please adjust either accordingly.',initialSampleSize,s.maximumTotalSamples);
	s.logger.severe(msg);
	error(msg);
end

s.logger.info(sprintf('Going to add %d initial samples to the queue', size(initialSamples,1)));
initialSamples = addAutoSampledDimensions(s.sampleManager, initialSamples);

s = queueSamples(s, initialSamples, zeros(size(initialSamples,1), 1));

% Wait for a specified minimum of samples
s.numSamples = getNrSamples(s.sampleManager);
timer = clock;

s.logger.info(sprintf('Waiting for at least %d points to arrive', s.minimumInitialSamples));

lastQueueSize = 1;
while (s.numSamples < s.minimumInitialSamples)
	
	% get new samples and add to list
	[s, newSamples, newValues, newIds] = fetchEvaluatedPoints(s);
	
	% add them to the samples list
	[s.sampleManager, numAdded] = add(s.sampleManager, newSamples, newValues, newIds);
	
	%So new samples were added, and duplicate points removed, what is the net outcome?
	if (numAdded > 0)
		% New data has arrived
		s.numSamples = getNrSamples(s.sampleManager);
	else
		% No new samples, wait...
		pause(1);
	end
	
	% Post progress messages each minute...
	if etime(clock,timer) > 60 
		s.logger.info(sprintf('Currently, %d points are available, need at least %d, still waiting...', s.numSamples, s.minimumInitialSamples));
		timer = clock;
	end
	
	% sample evaluator crashed
	sampleEvaluatorStatus = s.sampleEvaluator.getStatus();
	if ~sampleEvaluatorStatus.isActive()
		s.logger.severe('The sample evaluator has stopped due to an error, not waiting for any more initial samples.');
		break;
	end
	
	if s.sampleEvaluator.getNumPendingSamples() == 0 && lastQueueSize == 0
		%Only break if we have at least 2 samples
		%TODO this should be replaced by a minimimSampleSize option
		if(s.numSamples >= 2)
			break;
		
		% not even 2 samples and no more pending - produce error
		else
			msg = sprintf('Minimum of 2 points needed to start modelling NOT reached, aborting toolbox');
			s.logger.severe(msg);
			error(char(msg));
		end
	end
	lastQueueSize = s.sampleEvaluator.getNumPendingSamples();
end

s.numSamples = getNrSamples(s.sampleManager);

if(s.numSamples >= s.minimumInitialSamples)
	s.logger.info(sprintf('%d points are ready, minimum of %d reached, continuing', s.numSamples, s.minimumInitialSamples));
else
	s.logger.warning(sprintf('%d points are ready, %d remain in the queue, but the minimum of %d points is NOT reached. Some points might have failed', s.numSamples, s.sampleEvaluator.getNumPendingSamples(), s.minimumInitialSamples));
end
