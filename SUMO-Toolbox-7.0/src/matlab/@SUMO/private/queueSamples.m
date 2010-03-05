function [s, nSuccesfullyQueued] = queueSamples(s, samples, priorities)

% queueSamples (SUMO)
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
%	[s, nSuccesfullyQueued] = queueSamples(s, samples, priorities)
%
% Description:
%	Adds samples to the queue

% no samples to add - return
if size(samples,1) == 0
    nSuccesfullyQueued = 0;
	return;
end


% check samples against constraints
if s.newSamplesMustSatisfyConstraints
	c = Singleton('ConstraintManager');
	indices = c.satisfySamples(samples);
	nLost = size(samples,1) - size(indices,1);
	samples = samples(indices,:);
	if nLost > 0
		s.logger.info(sprintf('%d samples were rejected because they did not satisfy the constraints', nLost));
	end
end

% prepare samples for evaluation
[s.sampleManager, samplePoints] = prepareForEvaluation(s.sampleManager, samples, priorities);

% get the number of samples that will be queued after constraint checking
nSuccesfullyQueued = size(samples,1);

% queue the samples
if length(samplePoints) == 0
	return;
else
	s.sampleEvaluator.submitSamplesForEvaluation(samplePoints);
end
