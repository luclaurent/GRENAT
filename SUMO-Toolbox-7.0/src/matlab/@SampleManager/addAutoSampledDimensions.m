function [newSamples] = addAutoSampledDimensions(s, samples)

% addAutoSampledDimensions (SUMO)
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
%	[newSamples] = addAutoSampledDimensions(s, samples)
%
% Description:
%	Add auto-sampled dimensions to a sample set which was sampled without
%	being aware of the existing of these auto-sampled dimensions.

% empty samples
if size(samples,1) == 0
	newSamples = [];
	return;
end

% create new samples
newSamples = zeros(size(samples,1), s.dimension);

% assign the non auto-samples dimensions
newSamples(:,~s.autoSampledDimensions) = samples;
