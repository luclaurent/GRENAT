function [s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues] = removeSamplesByIndex(s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues, index, reason, addToFailed)

% removeSamplesByIndex (SUMO)
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
%	[s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues] = removeSamplesByIndex(s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues, index, reason, addToFailed)
%
% Description:
%	Removes all samples in index from the list.

if length(index) == 0
	return;
end

% if add to failed is not available, do so by default
if ~exist('addToFailed', 'var')
	addToFailed = true;
end

% print all filtered samples, but only if it is a small amount of samples that were removed
if length(index) < 100
	for m = 1 : length(index)
		i = index(m);
		%s.logger.fine(sprintf('Removed sample %s (model space: %s)', arr2str([newSamplesUnfiltered(i,:) newValuesUnfiltered(i,:)], 8), arr2str([newSamples(i,:) newValues(i,:)], 8)));
		s.logger.fine(sprintf('Removed sample %s', arr2str([newSamplesUnfiltered(i,:) newValuesUnfiltered(i,:)], 8)));
	end
else
	s.logger.fine(sprintf('Removed %d samples', length(index)));
end

% first add them to the failed samples list
if addToFailed
	s.failedSamplesUnfiltered = [s.failedSamplesUnfiltered ; newSamplesUnfiltered(index,:)];
	s.failedValuesUnfiltered = [s.failedValuesUnfiltered ; newValuesUnfiltered(index,:)];
	s.failedSamples = [s.failedSamples ; newSamples(index,:)];
	s.failedValues = [s.failedValues ; newValues(index,:)];
	s.failedReasons = [s.failedReasons ; repmat({reason}, length(index), 1)];
end

% remove them from the succesful samples list
newSamplesUnfiltered(index,:) = [];
newValuesUnfiltered(index,:) = [];
newSamples(index,:) = [];
newValues(index,:) = [];
