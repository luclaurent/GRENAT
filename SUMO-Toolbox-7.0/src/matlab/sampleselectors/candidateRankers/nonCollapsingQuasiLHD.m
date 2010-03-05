classdef nonCollapsingQuasiLHD < CandidateRanker

% nonCollapsingQuasiLHD (SUMO)
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
%	nonCollapsingQuasiLHD(varargin)
%
% Description:

	properties
		alpha = 0.5;
		minDistance = 0;
	end
	
	methods (Access = public)
		
		function this = nonCollapsingQuasiLHD(varargin)
			this = this@CandidateRanker(varargin{:});
			if nargin == 0
				return;
			end
			config = varargin{1};
			this.alpha = config.self.getDoubleOption('alpha', 0.5);
			this.minDistance = config.self.getDoubleOption('minDistance', 0);
		end
		
		
		function ranking = scoreCandidates(this, points, state)
			% Description:
			%	Calculate the non-collapsing factor of the candidates.
			%	From: Chen (2009)
			
			% samples
			samples = state.samples;
			
			% get dimension/n samples
			inDim = size(samples,2);
			nSamples = size(samples, 1);
			
			% calculate min distance from each other point - based on the
			% alpha value
			dMin = max((2.0 / nSamples) * this.alpha, this.minDistance);
			
			% by default, no penalty
			ranking = zeros(size(points,1),1);
			
			% calculate for each point the non collapsing distance matrix
			% for each dimension separately
			for i = 1 : inDim
				
				% take only one dimension
				filteredSamples = samples(:,i);
				filteredPoints = points(:,i);
				
				% calculate the non collapsing distance matrix
				distances = buildNonCollapsingDistanceMatrix(filteredPoints, filteredSamples);
				minDistances = min(distances, [], 2);
				
				% penalize all points that lie too close
				% make sure that more severe penalties from previous
				% dimensions are not overwritten by this dimension
				%ranking(minDistances < dMin) = min(ranking(minDistances < dMin), -dMin + minDistances(minDistances < dMin));
				ranking(minDistances < dMin) = min(ranking(minDistances < dMin), -10^3 + minDistances(minDistances < dMin));
				
			end
		end
		
	end
	
end
