classdef VoronoiSampleRanker < SampleSelector & SampleRanker

% VoronoiSampleRanker (SUMO)
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
%	VoronoiSampleRanker(varargin)
%
% Description:

	
	
	properties
		logger;
		dimension;
		outputDimension;
		voronoi;
		voronoiPoints;
		sampleSize = 0;
	end
	
	
	methods (Access = public)
		
		function s = VoronoiSampleRanker(varargin)
            
            if nargin == 1
                config = varargin{1};
                inDim = config.input.getInputDimension();
                outDim = config.output.getOutputDimension();
            else
                inDim = varargin{1};
                outDim = varargin{2};
            end

			import java.util.logging.*
			logger = Logger.getLogger('Matlab.VoronoiSampleRanker');
            
            % frequency dims are not sampling dims
            s.dimension = inDim;
			s.outputDimension = outDim;
			s.voronoi = [];
			s.voronoiPoints = {};
			s.logger = logger;
		end
		
		
		function [s, error, failedError] = calculateError(s, state)
			
			s.logger.fine('Starting Voronoi sample ranking...');

			% Get all previous samples
			samples = state.samples;

			% get the constraint manager
			constraints = Singleton('ConstraintManager');

			% also get the failed samples
			samplesFailed = state.samplesFailed;
            
			% add them to the list
			samples = [samples ; samplesFailed];

			% approximate a voronoi tesselation if new samples have arrived
			% do this on both the failed and succesful samples!
			if size(samples,1) > s.sampleSize
				[v] = approximateVoronoi(samples, [], [], constraints);
				s.voronoi = v.areas;
				s.voronoiPoints = v.closestPoints;
				s.sampleSize = size(samples,1);
            end
			error = s.voronoi(1 : size(samples,1));
			failedError = s.voronoi((size(samples,1)+1) : end);
			
		end
		
		function [voronoiPoints] = getVoronoiPoints(s, A)
			voronoiPoints = s.voronoiPoints{A};
		end

		function [candidates] = getAdditionalCandidates(s, state, A)
			% getAdditionalCandidates (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6376 $
			%
			% Description:
			%     Perform some kind of heuristic to generate additional points near point
			%     A so that a better candidate can be selected.
			
			samples = [state.samples;state.samplesFailed];

			% calculate total volume of the design space (the hypercube [-1,1])
			totalVolume = 2 ^ s.dimension;

			% calculate estimated true voronoi cell size
			voronoiVolume = s.voronoi(A) * totalVolume;

			% calculate cube radius that matches this volume
			boxRadius = voronoiVolume * (1 / s.dimension) / 2;

			% generate points in the box, and find those in the voronoi cell of A
			nPoints = 20 * s.dimension;

			% generate random points in [-1,1]
			points = rand(nPoints, s.dimension) .* 2 - 1;

			% scale & translate to [A - boxRadius, A + boxRadius]
			points = points .* boxRadius + repmat(samples(A,:), size(points,1),1);
			points = points(~any(abs(points) > 1,2),:);

			% now filter the points so that only those that satisfy the constraints are considered
			constraints = Singleton('ConstraintManager');
			indices = constraints.satisfySamples(points);
			points = points(indices,:);

			% get final number of points
			nPoints = size(points,1);


			candidates = zeros(0,s.dimension);
			for j = 1 : nPoints

				% calculate the minimum distance
				distances = buildDistanceMatrixPoint(samples, points(j,:), false);
				[minDistance, closestSample] = min(distances);

				% A is closest sample, add to candidates
				if closestSample == A
					candidates = [candidates ; points(j,:)];
				end
			end
		end
		
		function [s, newSamples, priorities] = selectSamples(s, state)
			
			s.logger.fine('Starting Voronoi-based sample selection...');

			% calculate error
			[s, errorVoronoi, errorVoronoiFailed] = s.calculateError(state);

			% aggregate into one score, for both succesful and failed samples
			averageErrors = [errorVoronoi;errorVoronoiFailed] + 1;
            
            % aggregate of samples and failed samples
            samples = [state.samples ; state.samplesFailed];
            
            
			% get amount of samples
			[dummy, indices] = sort(averageErrors, 'descend');
			bestSamples = indices(1:min(length(indices), state.numNewSamples));

			if(length(indices) < state.numNewSamples)
				s.logger.warning(sprintf('The maximum number of samples that Voronoi can return is bounded by the number of samples currently available (%d) which is less than the number requested (%d)',length(indices),state.numNewSamples));
			end


			s.logger.fine(sprintf('Samples %s picked because their Voronoi cell size was %s.', arr2str(samples(bestSamples,:)), arr2str(averageErrors(bestSamples,:))));


			% for each best sample, pick the best candidate point in the voronoi cell
			newSamples = [];
            priorities = [];
			for i = 1 : length(bestSamples)

				% best sample = A
				A = bestSamples(i);

				% get candidate new samples from voronoi tesselation
				candidates = [s.getVoronoiPoints(A) ; s.getAdditionalCandidates(state, A)];

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
                priorities = [priorities ; averageErrors(A)];
				s.logger.fine(sprintf('Best candidate around sample %s was chosen to be %s, with minDistance %d', arr2str(samples(bestSamples(i),:)), arr2str(candidates(bestCandidate,:)), maxMinDistance));
            end

			s.logger.fine('LOLA-Voronoi sample selection finished.');

		end
		
		
	end		
	
end
