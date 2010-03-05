function m = calculateValidationSet(m, samples)

% calculateValidationSet (SUMO)
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
%	m = calculateValidationSet(m, samples)
%
% Description:
%	This function takes care of the selection of the validation samples
%	out of the complete sample set

% get current validation set
validationSet = m.validationSamples;

% calculate amount of additional samples we need to identify
targetSize = floor(size(samples,1) / 100 * (m.percentUsed));
missing = targetSize - length(validationSet);

%select 'missing' new number of validation samples

% switch to random when sample set is too large
if size(samples,1) >= m.randomThreshold
	m.set = 'random';
end

%disp(sprintf('%d new validationsamples added',missing))

%add new validation samples
validationSet = selectTestSet(samples, validationSet, missing, m.set);

% set validation samples
m.validationSamples = validationSet;
