function [testSet lastAdded] = selectTestSet(samples, testSet, n, type, invalidCandidates)

% selectTestSet (SUMO)
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
%	[testSet lastAdded] = selectTestSet(samples, testSet, n, type, invalidCandidates)
%
% Description:
%	Add n test samples from a given sample set to an existing test set
%	(may be empty). testSet is a vector of indices in the array samples
%	resembling the samples that are already in the set.
%	Type is one of 'random' or 'distance/uniform'.
%	invalidCandidates is an optional parameter which contains the indices
%	that resemble invalid candidates for adding in the list. These samples
%	are ignored as possible candidates for adding. Defaults to the empty
%	vector (all samples are allowed as candidates except for the ones
%	already in the test set).

lastAdded = [];

if(n < 1)
	return;
end

% validCandidates defaults to all samples
if ~exist('invalidCandidates', 'var')
	invalidCandidates = [];
end


numAvailable = size(samples,1) - size(union(testSet, invalidCandidates),1);
if(numAvailable > n)
	%everything ok
elseif(numAvailable < n)
	%not enough free datapoints available
	error(sprintf('Cannot return %d new test samples since only %d samples are available and %d are already used',n,size(samples,1),length(testSet)));
else
	%the number of existing test samples + the number of newly requested test samples
	%equals the number of available samples
	%simply return all samples
	lastAdded = setdiff(1:size(samples,1),testSet);
	testSet = [testSet lastAdded];
end


% choose most distant samples for the test set
if strcmp(type, 'distance') || strcmp(type, 'uniform')
	
	%If there are no existing test samples add a first sample as a starting point
	if(length(testSet) < 1)
		testSet = setdiff(1:size(samples,1), invalidCandidates);
		testSet = circshift(testSet, [1 floor(rand * length(testSet))]);
		testSet = testSet(1);
		lastAdded = testSet;
		n = n - 1;
	end
	
	for k=1:n
		% separate samples in test set from normal samples
		testSamples = samples(testSet,:);
		tmp = samples;
		
		% don't pick any sample twice
		tmp(testSet,:) = NaN;
		
		% only consider the candidates
		tmp(invalidCandidates,:) = NaN;
		
		%Get the distance from every sample to every testsample
		dist = buildDistanceMatrix(tmp, testSamples, 0);
	
		%Get the minimum distance from every sample to a test sample
		[ymin Imin] = min(dist,[],2);

		%Take the sample where the minimum distance is maximal
		[ymax Imax] = max(ymin);

		testSet = [testSet Imax(1,1)];
		lastAdded = [lastAdded Imax(1,1)];
	end

% choose random samples for the test set
elseif strcmp(type, 'random')
	% create random permutation
	perm = randperm( size(samples,1) );

	% calculate root mean square distance from testset for every sample
	for i = 1 : length(perm)
		
		% stop when enough samples were added
		if n == 0
			break;
		end
		
		% only consider samples not selected yet and not in the invalid candidate list
		if isempty(intersect(perm(i), union(testSet, invalidCandidates)))
			
			% add new sample to test set
			testSet = [testSet perm(i)];
			lastAdded = [lastAdded perm(i)];			

			% one test sample added
			n = n - 1;
		end
	end
else
	error('Type must be one of distance (alternative: uniform) or random');
end
