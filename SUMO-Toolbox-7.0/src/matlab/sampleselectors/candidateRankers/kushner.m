classdef kushner < CandidateRanker

% kushner (SUMO)
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
%	kushner(config)
%
% Description:

	
	properties
		isc_opts;
	end
	
	methods (Access = public)
		
		function this = kushner(config)
			this = this@CandidateRanker(config);
			this.isc_opts = str2num(char(config.self.getOption('criterion_parameter', '[]')));
		end

		function out = scoreCandidates(this, points, state)

			% kushner (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6376 $
			%
			% Description:
			%     Calculates the kushner criterion.
			%     Let y be the predicted value (the surrogate), mse the mean square
			%     root and fmin the minimum of the evaluated samples. Then:

			model = state.lastModels{1}{1};
			epsilon = this.isc_opts;

			y = evaluateInModelSpace( model, points );
			mse = evaluateMSEInModelSpace( model, points );

			var = abs( mse );
			fmin = min( model.values );

			epsilon = epsilon * fmin; % 0.1% of fmin

			if var == 0
				k = zeros( size(points,1), 1 );
			else
				k = normcdfWrapper( ((fmin-epsilon) - y) ./ var );
			end
		end
		
	end
	
end
