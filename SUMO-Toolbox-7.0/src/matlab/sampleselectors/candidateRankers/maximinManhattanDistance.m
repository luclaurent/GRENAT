classdef maximinManhattanDistance < CandidateRanker

% maximinManhattanDistance (SUMO)
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
%	maximinManhattanDistance(config)
%
% Description:
%	Selects the candidates with the highest maximin distance to existing
%	points.

	
	properties
	end
	
	methods (Access = public)
		
		function this = maximinManhattanDistance(config)
			this = this@CandidateRanker(config);
		end

		function ranking = scoreCandidates(this, points, state)
			
            % calculate the distance matrix
            distances = buildManhattanDistanceMatrix(points, state.samples);
			
            % minimum distance from all other points
            ranking = min(distances, [], 2);
			
        end
        
	end
	
end
