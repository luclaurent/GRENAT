classdef NonCollapsingGridCandidateGenerator < CandidateGenerator

% NonCollapsingGridCandidateGenerator (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	NonCollapsingGridCandidateGenerator(config)
%
% Description:

	
	properties
		alpha;
		minDistance;
	end
	
	methods
		
		function s = NonCollapsingGridCandidateGenerator(config)
			
			% config this object
			s = s@CandidateGenerator(config);
			s.alpha = config.self.getDoubleOption('alpha', 0.5);
			s.minDistance = config.self.getDoubleOption('minDistance', Inf);
			
		end
		
		function [s, state, candidates] = generateCandidates(s, state)

		% RandomCandidateGenerator (SUMO)
		%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
		%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
		%     Copyright: IBBT - IBCN - UGent
		% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
		% Revision: $Rev$
		%
		% Signature:
		%	[state, candidates] = RandomCandidateGenerator(state)
		%
		% Description:
		%	Generate candidates on the optimal non-collapsing grid.
		
			% compute the grid points in all dimensions
			% this is the average between two consecutive values - so the
			% middle between all the intervals defined by the points
			sortedSamples = sort(state.samples, 1);
			averages = (sortedSamples(2:end,:) + sortedSamples(1:end-1,:)) ./ 2;
			intervals = (sortedSamples(2:end,:) - sortedSamples(1:end-1,:));
			
			% calculate the minimum size of an interval
			% this is defined as dmin, the minimum allowed distance of new
			% candidates from the dataset
			dMin = min((2.0 / size(state.samples, 1)) * s.alpha, s.minDistance);
			
			% filter out those intervals that are too small - can't fit a
			% good non-collapsing point in there anyway
			largeEnough = intervals > dMin*2;
			
			% convert to cell array
			averagesGrid = cell(size(state.samples, 2), 1);
			intervalsGrid = cell(size(state.samples, 2), 1);
			for i = 1 : length(averagesGrid)
				
				% only add the intervals that are large enough
				averagesGrid{i} = averages(largeEnough(:,i),i);
				
				% the allowed interval is defined by dMin
				% so the real interval size is reduced by 2dMin
				intervalsGrid{i} = intervals(largeEnough(:,i),i) - 2 * dMin;
			end
			
			% now generate the entire grid using makeEvalGrid
			candidates = makeEvalGrid(averagesGrid);
			
			% for this grid, define the range that the optimizer is allowed to optimize in
			state.intervals = makeEvalGrid(intervalsGrid);
			
		end
	end
end
