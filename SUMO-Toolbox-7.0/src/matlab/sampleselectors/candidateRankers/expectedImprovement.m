classdef expectedImprovement < CandidateRanker

% expectedImprovement (SUMO)
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
%	expectedImprovement(config)
%
% Description:
%	Calculates the expected improvement as follows:
%	Let y be the predicted value (the surrogate), mse the mean square
%	root and fmin the minimum of the evaluated samples. Then:

	methods (Access = public)
		
		function this = expectedImprovement(config)
			this = this@CandidateRanker(config);
		end

		function ei = scoreCandidates(this, points, state)
            %EI Expected Improvement
            %   Of a kriging model

            model = state.lastModels{1}{1};

            y = evaluateInModelSpace( model, points );
            mse = evaluateMSEInModelSpace( model, points );

            var = sqrt( abs( mse ) );
            fmin = min( getValues(model) );

            if var == 0
                ei = zeros( size(points,1), 1 );
            else
                z  = (fmin-y)./var;
                ei = (fmin-y) .* normcdfWrapper(z) + var .* normpdfWrapper(z);
            end
        end
    end
end
