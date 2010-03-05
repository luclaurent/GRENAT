classdef phiDistance < CandidateRanker

% phiDistance (SUMO)
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
%	phiDistance(varargin)
%
% Description:
%	Selects the candidates with the highest maximin distance to existing
%	points.

	
	properties
		p;
		doSqrt;
	end
	
	methods (Access = public)
		
		function this = phiDistance(varargin)
			this = this@CandidateRanker(varargin{:});
			if nargin == 0
				return;
			end
			config = varargin{1};
			this = this.setOrder('min');
			this.doSqrt = config.self.getBooleanAttrValue('sqrt', 'false');
			this.p = config.self.getDoubleAttrValue('p', '50');
		end

		function ranking = scoreCandidates(this, points, state)
			
			% calculate the distance matrix of the current points
			oldDistances = buildDistanceMatrix(state.samples, state.samples, true);
			
			% only get the unique intersite distances (this corresponds to the upper
			% triangular matrix without the diagonal)
			nSamples = size(state.samples,1);
			oldDistances = oldDistances((mod(1:nSamples^2,nSamples) <= floor([1:nSamples^2]./nSamples)) & (mod(1:nSamples^2,nSamples) ~= 0));
			
			% get the distances from the new candidates
			newDistances = buildDistanceMatrix(points, state.samples, true);
			
			% walk ove rall candidates, and calculate it
			ranking = zeros(size(points,1),1);
			for i = 1 : size(points,1)
				
				% calculate the distance of the new point from all the
				% existing points
				distances = [oldDistances newDistances(i,:)];
				
				% sum all the distances
				ranking(i) = sum(sum(distances.^(-this.p)))^(1/this.p);
			end
       end
        
	end
	
end
