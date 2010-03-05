classdef maximinDistance < CandidateRanker

% maximinDistance (SUMO)
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
%	maximinDistance(varargin)
%
% Description:
%	Selects the candidates with the highest maximin distance to existing
%	points.

	
	properties
		doSqrt = true;
		scaleToZeroOne = false;
	end
	
	methods (Access = public)
		
		function this = maximinDistance(varargin)
			this = this@CandidateRanker(varargin{:});
			if nargin == 0
				return;
			end
			config = varargin{1};
			this.doSqrt = config.self.getBooleanAttrValue('sqrt', 'true');
			this.scaleToZeroOne = config.self.getBooleanOption('scaleToZeroOne', false);
		end

		function ranking = scoreCandidates(this, points, state)
			
            % calculate the distance matrix
            distances = buildDistanceMatrix(points, state.samples, this.doSqrt);
            % minimum distance from all other points
            ranking = min(distances, [], 2);
			
			
			% scale based on dimension & n samples, so that it lies between [0,1]
			if this.scaleToZeroOne
				maxMaximin = 2 / ((size(state.samples,1)+1) .^ (1/size(state.samples,2)) - 1);
				ranking = ranking ./ maxMaximin;
			end
			%disp (sprintf('Maximin distance for %s: %d', arr2str(points), ranking));
        end
        
	end
	
end
