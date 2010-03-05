function [s, samples] = prepareForEvaluation(s, filteredSamples, priorities)

% prepareForEvaluation (SUMO)
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
%	[s, samples] = prepareForEvaluation(s, filteredSamples, priorities)
%
% Description:
%	Prepare newly selected sample points for evaluation.

%% no samples to prepare, just return nothing
if size(filteredSamples,1) == 0
	samples = [];
	return;
end

%% Step 1: change the order
sampleSize = size(filteredSamples,1);

% no priorities exist - don't change anything
if ~exist('priorities', 'var')
    priorities = [];
    
% priorities exist, but difference is too small to be meaningful - randomize
elseif abs(max(priorities) - min(priorities)) < eps
	randomization = randperm(sampleSize);
	filteredSamples = filteredSamples(randomization,:);
    priorities = priorities(randomization);
    
% sort by priority
else
    [dummy, indices] = sort(priorities, 'descend');
	filteredSamples = filteredSamples(indices,:);
    priorities = priorities(indices);
end


%% Step 2: Create Java SamplePoints from the samples
[s, samples] = toSamplePoints(s, filteredSamples, priorities);

