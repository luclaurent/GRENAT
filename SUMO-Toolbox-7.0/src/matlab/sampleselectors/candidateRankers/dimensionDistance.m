classdef dimensionDistance < CandidateRanker

% dimensionDistance (SUMO)
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
%	dimensionDistance(varargin)
%
% Description:

	properties
		dimension = 0;
		scaleToZeroOne = false;
		transformationFunction = @(x)(x);
	end
	
	methods (Access = public)
		
		function this = dimensionDistance(varargin)
			this = this@CandidateRanker(varargin{:});
			if nargin == 0
				return;
			end
			config = varargin{1};
			this.dimension = config.self.getIntAttrValue('dimension', '0');
			this.transformationFunction = str2func(char(config.self.getAttrValue('transformationFunction', '@(x)(x)')));
			this.scaleToZeroOne = config.self.getBooleanOption('scaleToZeroOne', false);
		end
		
		
		function ranking = scoreCandidates(this, points, state)
			% Description:
			%	Calculate the non-collapsing factor of the candidates.
			
			% samples
			samples = state.samples;
			
			% dimension specified - only return for exactly one dimension
			if this.dimension ~= 0
				samples = samples(:,this.dimension);
				points = points(:,this.dimension);
			end
			
            % calculate the distance matrix
            distances = buildNonCollapsingDistanceMatrix(points, samples);
			
			% don't count distance from yourself
			%distances = distances + diag(repmat(Inf, size(distances,1), 1));
			
            % minimum distance from all other points
            ranking = min(distances, [], 2);
			
			% too close - return big penalty so that this point is never chosen
			%ranking(ranking < eps) = -Inf;
			%ranking(ranking > eps) = 0;
			
			% scale to [0,1] if asked
			if this.scaleToZeroOne
				maxDimensionDistace = 2 / (size(state.samples,1)+1);
				ranking = ranking ./ maxDimensionDistace;
			end
			
			% use transformation function
			ranking = this.transformationFunction(ranking);
			
		end
		
	end
	
end
