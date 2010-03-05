classdef wb1 < CandidateRanker

% wb1 (SUMO)
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
%	wb1(config)
%
% Description:
%	Calculates the threshold-bounded extreme
%	 NOTE: this is just a special case of the Generalized Expected
%	 Improvement (g=0) and Kushner's criterion (epsilon=0)

	methods (Access = public)
		
		function this = wb1(config)
			this = this@CandidateRanker(config);
		end

		function out = scoreCandidates(this, points, state)

            model = state.lastModels{1}{1};

            y = evaluateInModelSpace( model, points );
            mse = evaluateMSEInModelSpace( model, points );

            var = sqrt( abs( mse ) );
            fmin = min( getValues(model) );

            if var == 0
                out = zeros( size(points,1), 1 );
            else
                z  = (fmin-y)./var;
                out = normcdfWrapper(z);
            end
        end
    end
end
