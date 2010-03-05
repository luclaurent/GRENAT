classdef crowdedness < CandidateRanker

% crowdedness (SUMO)
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
%	crowdedness(config)
%
% Description:
%	Calculates the crowdedness at a given design x
%	 or in this case, for all designs in 'points')

	methods (Access = public)
		
		function this = crowdedness(config)
			this = this@CandidateRanker(config);
		end

		function out = scoreCandidates(this, points, state)

            model = state.lastModels{1}{1};

            samples = getSamplesInModelSpace( model );

            % calculate crowdedness at points for a given set of samples
            out = crowdedness( points, samples );
        end
    end
end
