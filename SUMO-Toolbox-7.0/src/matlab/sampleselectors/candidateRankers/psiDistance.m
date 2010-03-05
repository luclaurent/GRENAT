classdef psiDistance < CandidateRanker

% psiDistance (SUMO)
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
%	psiDistance(varargin)
%
% Description:
%	Selects the candidates with the highest psi distance to existing
%	points.

	
	properties
		alpha = 0.4;
		scaleToZeroOne = false;
	end
	
	methods (Access = public)
		
		function this = psiDistance(varargin)
			this = this@CandidateRanker(varargin{:});
			if nargin == 0
				return;
			end
			config = varargin{1};
			this.alpha = config.self.getDoubleAttrValue('alpha', '0.4');
			this.scaleToZeroOne = config.self.getBooleanOption('scaleToZeroOne', false);
		end

		function ranking = scoreCandidates(this, points, state)
			
			% calculate the distance matrix of the current points
			oldDistances = buildDistanceMatrix(state.samples, state.samples, true);
			
			% only get the unique intersite distances (this corresponds to the upper
			% triangular matrix without the diagonal)
			nSamples = size(state.samples,1);
			oldDistances = oldDistances((mod(1:nSamples^2,nSamples) <= floor([1:nSamples^2]./nSamples)) & (mod(1:nSamples^2,nSamples) ~= 0));
			
			% generate the weight sequence
			weights = 1 .* this.alpha .^(0 : (length(oldDistances)-1));
			
			% pre-sort the distances
			oldDistances = sort(oldDistances);
			
			% keep only the distances relevant to the outcome
			oldDistances(weights <= eps) = [];
			weights(weights <= eps) = [];
			nWeights = length(weights);

			% get the distances from the new candidates
			newDistances = buildDistanceMatrix(points, state.samples, true);
			
			% walk ove rall candidates, and calculate it
			ranking = zeros(size(points,1),1);
			for i = 1 : size(points,1)
				
				% calculate the distance of the new point from all the
				% existing points
				distances = [oldDistances newDistances(i,:)];
				
				% sort the remaining distances
				[distances] = sort(distances);

				% return the average of the nDistances smallest distances
				ranking(i) = sum(distances(1:nWeights) .* weights) / sum(weights);
			end
			
			% scale based on dimension & n samples, so that it lies between [0,1]
			if this.scaleToZeroOne
				maxMaximin = 2 / ((size(state.samples,1)+1) .^ (1/size(state.samples,2)) - 1);
				ranking = ranking ./ maxMaximin;
			end
			
		end
        
	end
	
end
