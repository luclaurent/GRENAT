function [badIndices numDups] = removeDuplicateSamples(newSamples, prevSamples)

% removeDuplicateSamples (SUMO)
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
%	[badIndices numDups] = removeDuplicateSamples(newSamples, prevSamples)
%
% Description:
%	Given a set of samples, remove exact duplicates.

%% make sure there are no duplicates among the new sample candidates

% get unique samples, always get first match
[dummy, index, dummy] = unique(newSamples, 'rows', 'first');

% re-sort the indices according to original location, to preserve order
realindex = sort(index);

% filter out duplicates if there are any
badIndices = setdiff(1:size(newSamples,1), realindex);


%% now compare the remaining new (unique) samples to the old samples, and remove duplicates
% see if the new samples are already in the old set
dups = ismember(newSamples, prevSamples, 'rows')';
badIndices = [badIndices find(dups)];


%% make sure no indices are counted twice
badIndices = unique(badIndices);
numDups = length(badIndices);

