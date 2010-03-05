function [inputOutOfRangeIndices, outputOutOfRangeIndices, numOutOfRange] = removeOutOfRangeSamples(s, newSamples, newValues)

% removeOutOfRangeSamples (SUMO)
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
%	[inputOutOfRangeIndices, outputOutOfRangeIndices, numOutOfRange] = removeOutOfRangeSamples(s, newSamples, newValues)
%
% Description:
%	Given a set of samples, remove samples that are not in the [-1,1]
%	range. Also check output range.

%% filter input range
inputOutOfRangeIndices = find( any( abs(newSamples) > 1 + 100 * eps, 2 ) );



%% filter output range

% walk over all values and check the corresponding min/max range
minima = zeros(1, length(s.outputs));
maxima = zeros(1, length(s.outputs));
complex = false(1,length(s.outputs));
for i = 1 : length(s.outputs)
	minima(i) = s.outputs(i).getMinimum();
	maxima(i) = s.outputs(i).getMaximum();
	complex(i) = strcmp(char(s.outputs(i).getType()), 'complex');
end


% replicate for every new sample
minima = repmat(minima, size(newValues,1),1);
maxima = repmat(maxima, size(newValues,1),1);

% get the abs of complex numbers
checkValues = newValues;
checkValues(:,complex) = abs(newValues(:,complex));


% see if the minimum is passed for any output
outputOutOfRangeIndices = [];
if any(any(checkValues < minima - 100 * eps))
	outputOutOfRangeIndices = find(any(checkValues < minima - 100 * eps, 2));
end

% see if the maximum is passed for any output
if any(any(checkValues > maxima + 100 * eps))
	outputOutOfRangeIndices = [outputOutOfRangeIndices ; find(any(checkValues > maxima + 100 * eps, 2))];
end

% count number of samples out of range
numOutOfRange = length(outputOutOfRangeIndices) + length(inputOutOfRangeIndices);
