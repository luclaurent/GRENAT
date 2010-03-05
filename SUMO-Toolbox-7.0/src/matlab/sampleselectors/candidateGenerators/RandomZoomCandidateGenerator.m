classdef RandomZoomCandidateGenerator < CandidateGenerator

% RandomZoomCandidateGenerator (SUMO)
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
%	RandomZoomCandidateGenerator(config)
%
% Description:

	
	properties
		candidatesPerSample;
	end
	
	methods
		
		function this = RandomZoomCandidateGenerator(config)
			this = this@CandidateGenerator(config);
			this.candidatesPerSample = config.self.getIntOption('candidatesPerSample', 100);
		end
		
		function [this, state, candidates] = generateCandidates(this, state)

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
			%	Generate a set of random candidate points, based on the number of
			%	samples.

			% get # samples
			nSamples = size(state.samples,1);

			% input dimension
			inDim = size(state.samples,2);

			% generate random set of points
			candidates = rand(nSamples*this.candidatesPerSample, size(state.samples,2)) .* 2 - 1;

			% take the best 3 maximin samples, and generate additional samples
			% nearby
			distances = min(buildDistanceMatrix(candidates, state.samples, false), [], 2);
			[dummy, bestCandidates] = sort(distances, 'descend');
			
			nPoints = 100 * inDim;
			for i = 1 : 3

				% generate candidates around this candidate
				candidate = candidates(bestCandidates(i), :);

				% distance
				distance = sqrt(distances(bestCandidates(i)));

				% points
				points = rand(nPoints, inDim);
				
				% scale to distance
				points = points / distance - (distance / 2);
				
				% translate
				points = bsxfun(@plus, candidate, points);
				
				% filter out if range out
				points(any(abs(points) > 1,2),:) = [];

				% translate to candidate
				candidates = [candidates ; points];

			end
			
			% plot all candidates
			%{
			plot(candidates(:,1), candidates(:,2), 'or');
			hold on;
			plot(state.samples(:,1), state.samples(:,2), 'ob');
			%}
		end
	end
end
