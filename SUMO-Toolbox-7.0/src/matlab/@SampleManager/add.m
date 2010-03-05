function [s, numAdded, numDuplicate, numInvalid, numOutOfRange] = add(s, newSamplesUnfiltered, newValuesUnfiltered, newSampleIds)

% add (SUMO)
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
%	[s, numAdded, numDuplicate, numInvalid, numOutOfRange] = add(s, newSamplesUnfiltered, newValuesUnfiltered, newSampleIds)
%
% Description:
%	Adds newly evaluated samples to the list. These samples must be passed
%	in unfiltered form (ie: they must be in simulator space).

% no samples to add, just return
if size(newSamplesUnfiltered,1) == 0
	numAdded = 0; numDuplicate = 0; numInvalid = 0; numOutOfRange = 0;
	return;
end

% if no id's were configured, we generate invalid ones, so that random
% dummy values are generated
if ~exist('newSampleIds', 'var')
	newSampleIds = repmat(-1, size(newSamplesUnfiltered,1),1);
end

% TODO: Dummy values don't work at the moment:
%	- samples -> prepareForEvaluation -> might give duplicates that are
%	evaluated twice. If we remove dups before evaluation we should keep
%	track of the removed ones... too much work
%	- add: removeDups should be done on M3 space samples, as simulator space samples are
%	thrown away which are in fact unique samples (with their dummy values).
%	too much work
%   conclusion: dummy values don't work


% filter the new samples from simulator space to model space
[newSamples] = filterInputs(s, newSamplesUnfiltered);
[s, newValues] = filterOutputs(s, newValuesUnfiltered);
s.logger.finer(sprintf('New samples have been filtered from (%d x %d) |-> (%d x %d) to (%d x %d) |-> (%d x %d)',size(newSamplesUnfiltered,1),size(newSamplesUnfiltered,2),size(newValuesUnfiltered,1),size(newValuesUnfiltered,2),size(newSamples,1),size(newSamples,2),size(newValues,1),size(newValues,2)));

% remove duplicate samples
[duplicateIndices, numDuplicate] = removeDuplicateSamples(newSamples, s.samples);
[s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues] = removeSamplesByIndex(s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues, duplicateIndices, 'duplicate sample');
if numDuplicate > 0
	s.logger.warning(sprintf('Removed %d duplicate samples from list', numDuplicate));
end

% remove invalid samples (Inf or NaN)
[invalidIndices, numInvalid] = removeInvalidValues(s, newSamples, newValues);
[s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues] = removeSamplesByIndex(s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues, invalidIndices, 'invalid output');
if numInvalid > 0
	s.logger.warning(sprintf('Removed %d invalid (Inf or NaN) samples from list', numInvalid));
end

% remove samples out of the [-1,1] range and out of output range
[inputOutOfRangeIndices, outputOutOfRangeIndices, numOutOfRange] = removeOutOfRangeSamples(s, newSamples, newValues);

% samples out of input range are removed entirely - they are also not added to failedSamples
[s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues] = removeSamplesByIndex(s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues, inputOutOfRangeIndices, 'input out of range', false);

if ~isempty(inputOutOfRangeIndices)
	s.logger.warning(sprintf('Removed %d samples that violated the input range', length(inputOutOfRangeIndices)));
end

% samples out of output range are moved to failedSamples
[s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues] = removeSamplesByIndex(s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues, outputOutOfRangeIndices, 'output out of range');

if ~isempty(outputOutOfRangeIndices)
	s.logger.warning(sprintf('Removed %d samples that violated the output range', length(outputOutOfRangeIndices)));
end


% finally store the samples that have passed all filters
numAdded = size(newSamples,1);
s.samplesUnfiltered = [s.samplesUnfiltered ; newSamplesUnfiltered];
s.valuesUnfiltered = [s.valuesUnfiltered ; newValuesUnfiltered];
s.samples = [s.samples ; newSamples];
s.values = [s.values ; newValues];

% update the triangulation object
s.triangulationObj.setPoints( s.samples, s.failedSamples );
