function [numNewSamples] = calculateNumNewSamples(s)

% calculateNumNewSamples (SUMO)
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
%	[numNewSamples] = calculateNumNewSamples(s)
%
% Description:
%	Calculate the number of new samples needed, based on current queue
%	size, resource data from the sample evaluator and configuration of the user.

% get the modeling time of the last iteration (in seconds)
modelingTime = s.averageModellingTime;

% average duration of one simulation (in seconds)
samplingTime = s.sampleEvaluator.getAverageEvaluationTime()/1000;

% get sample evaluator resource information
status = s.sampleEvaluator.getStatus();

% How many points have been fetched from the input queue but are sitting in a middleware queue
numWaiting = status.getNumInternalPending();

% how many points are currently pending evaluation
numPending = s.sampleEvaluator.getNumPendingSamples();

% how many are currently running
numRunning = status.getNumRunning();

% total number of nodes
totalNodes = status.getTotalNodes();

% How many sample points can we evaluate concurrently
availableNodes = status.getAvailableNodes();

% how many do we need just to cover the next modeling iteration
samplesPerLoop = 0;

%how many we eventually want
samplesNeeded = 0;

if(samplingTime == 0)
	%we dont yet know what the expected evaluation time is
	%I doubt this will ever happen, but its best to be safe
	% assume the total number of nodes
	samplesPerLoop = totalNodes;
else
	samplesPerLoop = ceil(modelingTime / samplingTime);
	% We also want to make full use of our number of nodes, we dont want nodes sitting around idly
	% Therefore multiply by the number of AVAILABLE nodes (may be 0).
	samplesPerLoop = samplesPerLoop * availableNodes;
end

if(samplesPerLoop == 0)
	% if there are no available nodes ensure we keep the queue filled when nodes might become free during the next modeling iteration
	samplesPerLoop = max(0, numRunning - numWaiting);
else
	% No need to spam the the middleware queue with new points if there are already enough points waiting
	samplesNeeded = max(0,samplesPerLoop - numWaiting);
end

%log
msg = {'Calculating the number of new samples needed...', ...
		['   - average modelling time: ' num2str(modelingTime/60) ' min' ],...
		['   - average sample evaluation time: ' num2str(samplingTime/60) ' min'],...
		['   - number of available compute nodes: ' num2str(status.getAvailableNodes()) ' (out of ' num2str(status.getTotalNodes())  ')'],...
		['   - number of pending samples: ' num2str(numPending)],...
		['   - number of internally pending samples: ' num2str(numWaiting)],...
		['   - number of running samples: ' num2str(numRunning)],...
		[' => will need an extra of ' num2str(samplesNeeded) ' new samples to keep the sample evaluator busy during the next modeling iteration']};

s.logger.fine(sprintf(stringJoin(msg,'\n')));
				
% More than enough samples are already pending in the queue, no need to add any more
if samplesNeeded < 1
	s.logger.fine(sprintf('There are %d pending samples in the queue which is more than enough to cover the next modeling iteration, not selecting any new samples', numPending));
	numNewSamples = 0;
else
	% Now make sure we abide by the maximum limit set by the user
	numNewSamples = min(samplesNeeded, s.maximumSamples);
	
	s.logger.info(sprintf('Requesting %d extra new samples in addition to the %d pending ones...', numNewSamples,numPending));
end
