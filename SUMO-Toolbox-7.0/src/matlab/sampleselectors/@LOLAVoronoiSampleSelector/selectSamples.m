function [s, newSamples, priorities] = selectSamples(s, state)

% selectSamples (SUMO)
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
%	[s, newSamples, priorities] = selectSamples(s, state)
%
% Description:
%

s.logger.fine('Starting LOLA-Voronoi sample selection...');


% get samples, failed samples and values
samples = state.samples;
samplesFailed = state.samplesFailed;
values = state.values;

% convert samples into sliced versions with one set of outputs per slice
if ~isempty(s.frequency)
    
    % first check if the # frequencies is realistic
    if mod(size(samples,1), s.frequencies) ~= 0
        msg = sprintf('Number of frequencies per sample provided to LOLA (%d) does not match the number of samples returned by the simulator (%d)', s.frequencies, size(samples,1));
        s.logger.severe(msg);
        error(msg);
    end
	
	nSamples = size(samples,1) / s.frequencies;
	
	sliceIndices = repmat(s.frequencySlices, [nSamples 1]);
	sliceIndices = sliceIndices + repmat([0:(nSamples-1)]' .* s.frequencies, [1 length(s.frequencySlices)]);
	
	% now get the appropriate values
	sliceValues = values(sliceIndices', :);
	
	% now reshape them, so that the slices are grouped in one row as if
	% they are different outputs
	% look out for the fact that matrices are extracted and constructed
	% column-wise, while we work row-wise, hence the transpose operators
	values = reshape(sliceValues', length(s.frequencySlices) * size(values,2), nSamples)';
	
	% transform samples
	samples = samples((1:nSamples) .* s.frequencies,:);
	samples(:,s.frequency) = [];
    samplesFailed(:,s.frequency) = [];
end

% fix state so that frequency is converted to output slices
state.samples = samples;
state.samplesFailed = samplesFailed;
state.values = values;

% calculate both errors
[s.LOLA, errorLOLA, errorLOLAFailed] = s.LOLA.calculateError(state);
[s.Voronoi, errorVoronoi, errorVoronoiFailed] = s.Voronoi.calculateError(state);

% aggregate into one score, for both succesful and failed samples
averageErrors = ([errorLOLA;errorLOLAFailed] + 1) .* ([errorVoronoi;errorVoronoiFailed] + 1);

% get amount of samples
[dummy, indices] = sort(averageErrors, 'descend');
bestSamples = indices(1:min(length(indices), state.numNewSamples));

% get samples, also throw in the failed samples
samples = [state.samples ; state.samplesFailed];

if(length(indices) < state.numNewSamples)
	s.logger.warning(sprintf('The maximum number of samples that LOLA-Voronoi can return is bounded by the number of samples currently available (%d) which is less than the number requested (%d)',length(indices),state.numNewSamples));
end


s.logger.fine(sprintf('Samples %s picked because their combined density/error measure was distorted size %s.', arr2str(samples(bestSamples,:)), arr2str(averageErrors(bestSamples,:))));


% for each best sample, pick the best candidate point in the voronoi cell
newSamples = [];
priorities = [];
for i = 1 : length(bestSamples)
	
	% best sample = A
	A = bestSamples(i);

	% get candidate new samples from voronoi tesselation
	% generate an additional set of samples near the best sample
	
	% if the sample is a failed sample, we generate it with our own method
	if A > size(state.samples,1)
		% failed sample, so we just generate samples in a hypercube
		candidates = [s.Voronoi.getVoronoiPoints(A) ; s.Voronoi.getAdditionalCandidates(state, A)];
	else
		% use the method of the derived class
		candidates = [s.Voronoi.getVoronoiPoints(A) ; s.LOLA.getAdditionalCandidates(state, A)];
	end
	
	% get total number of candidates
	s.logger.finer(sprintf('%d candidates for sample %s', size(candidates,1), arr2str(samples(A,:))));
	nNewSamples = size(candidates,1);
	
	% still no candidate samples around this one, skip it!
	if nNewSamples == 0
		s.logger.fine(sprintf('Sample %s with error %d skipped because there were no candidate samples around it...', arr2str(samples(bestSamples(i),:)), averageErrors(bestSamples(i))));
		continue;
	end

	% find candidate that is farthest away from any existing sample
	maxMinDistance = 0;
	bestCandidate = 0;
	for j = 1 : nNewSamples

		% find min distorted distance from all other samples
		distances = buildDistanceMatrixPoint([samples;newSamples], candidates(j,:), false);
		minDistance = min(distances);

		% see if this is the maximal minimum distance from all other samples
		if minDistance >= maxMinDistance
			maxMinDistance = minDistance;
			bestCandidate = j;
		end

	end
	
	% add the best candidate to the list of new samples
	newSamples = [newSamples ; candidates(bestCandidate,:)];
    
    % add the priority to the list
    priorities = [priorities ; averageErrors(A)];
	
    % output
	s.logger.fine(sprintf('Best candidate around sample %s was chosen to be %s, with minDistance %d', arr2str(samples(bestSamples(i),:)), arr2str(candidates(bestCandidate,:)), maxMinDistance));
end


% re-introduce the frequency dir
if ~isempty(s.frequency)
    newSamples(:,s.frequency+1:end+1) = newSamples(:,s.frequency:end);
    newSamples(:,s.frequency) = 0;
end

s.logger.fine('LOLA-Voronoi sample selection finished.');

