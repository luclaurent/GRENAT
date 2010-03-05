classdef DelaunayCandidateGenerator < CandidateGenerator

% DelaunayCandidateGenerator (SUMO)
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
%	DelaunayCandidateGenerator(config)
%
% Description:

	
	properties
		midPoints;
	end
	
	methods
		
		function this = DelaunayCandidateGenerator(config)
			this = this@CandidateGenerator(config);
			this.midPoints = config.self.getBooleanOption('midPoints', true);
		end

		function [this, state, candidates] = generateCandidates(this, state)

			% DelaunayCandidateGenerator (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6376 $
			%
			% Signature:
			%	[state, candidates] = DelaunayCandidateGenerator(state)
			%
			% Description:
			%	Generates a set of candidate samples at the centroids and halfway
			%	points of all the triangles of the delaunay triangulation of the
			%	samples. Also adds the mapping of candidates to samples to the state.

			% compute the delaunay triangulation
			[T centers volumes] = state.triangulation.getTriangulation();
			
			% return only the centers
			if ~this.midPoints

				% only the centers
				candidates = centers;
				state.candidatesToTriangles = 1:size(centers,1);
				return;
			end
			
			% produce the centers and all the midpoints
			pointList = state.triangulation.generateTestPoints();

			% add the mapping of points -> triangles to the state
			% this can be used later by sample scorers to identify the triangle that
			% each sample belongs to
			nTriangles = length(pointList);
			nPointsPerTriangle = length(pointList{1});

			% fancy code to generate the mapping
			candidates = zeros(nTriangles * nPointsPerTriangle, size(state.samples,2));
			candidatesToTriangles = 1:nTriangles;
			candidatesToTriangles = candidatesToTriangles(repmat(1, nPointsPerTriangle, 1), :);
			state.candidatesToTriangles = candidatesToTriangles(:);

			% put all the candidates in one list instead of cell array per triangle
			for i = 0 : nTriangles-1
				candidates(i*nPointsPerTriangle+1:(i+1)*nPointsPerTriangle,:) = pointList{i+1};
			end

		end
	end
end
