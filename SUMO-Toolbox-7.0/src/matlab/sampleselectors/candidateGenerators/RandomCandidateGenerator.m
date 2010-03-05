classdef RandomCandidateGenerator < CandidateGenerator

% RandomCandidateGenerator (SUMO)
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
%	RandomCandidateGenerator(config)
%
% Description:

	
	properties
		candidatesPerSample;
		nCandidates;
	end
	
	methods
		
		function this = RandomCandidateGenerator(config)
			this = this@CandidateGenerator(config);
			this.candidatesPerSample = config.self.getIntOption('candidatesPerSample', 100);
			this.nCandidates = config.self.getIntOption('nCandidates', +Inf);
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

			% generate random set of points
			candidates = rand(nSamples*this.candidatesPerSample, size(state.samples,2)) .* 2 - 1;

			% don't return them all - return only the x best ones
			if this.nCandidates ~= Inf
				
				% calculate the distance matrix
				distances = buildDistanceMatrix(candidates, state.samples, true);
				
				% minimum distance from all other points
				[distances] = min(distances, [], 2);
				
				% return the best ones
				[dummy, indices] = sort(distances, 'descend');
				
				% return the best ones
				nCandidates = min(nSamples, this.nCandidates);
				candidates = candidates(indices(1:nCandidates),:);
				
				% set the volume in the state, to be re-used later
				state.maximinDistance = distances(indices(1:nCandidates));
				
			end

		end
	end
end
