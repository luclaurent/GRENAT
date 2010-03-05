classdef wExpectedImprovement < CandidateRanker

% wExpectedImprovement (SUMO)
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
%	wExpectedImprovement(config)
%
% Description:

	properties
		isc_opts;
	end
	
	methods (Access = public)
		
		function this = wExpectedImprovement(config)
			this = this@CandidateRanker(config);
			this.isc_opts = str2num(char(config.self.getOption('criterion_parameter', '[]')));
		end

		function ei = scoreCandidates(this, points, state)

			% wExpectedImprovement (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6376 $
			%
			% Description:
			%     Calculates the weighted expected improvement as follows:
			%     Let y be the predicted value (the surrogate), mse the mean square
			%     root and fmin the minimum of the evaluated samples. Then:

			%EI Expected Improvement
			%   Of a kriging model

			w = this.isc_opts;
			model = state.lastModels{1}{1};

			y = evaluateInModelSpace( model, points );
			mse = evaluateMSEInModelSpace( model, points );

			var = sqrt( abs( mse ) );
			fmin = min( getValues( model ) );

			% Use adaptive weighting according to model score ?
			if w < 0
				% TODO: use measures separately instead of sum (TestMinimum should be
				% separate). Actually fault of measure being also a stopping criterion 
				w = getScore( model );
				%w = normcdf( w, 0.5, 0.5 )
				w = gBellCurve( w );
			end

			if var == 0
				ei = repmat( 0, size(points,1), 1 );
			else
				z  = (fmin-y)./var;
				ei = w .* (fmin-y) .* normcdfWrapper(z) + (1-w) .* var .* normpdfWrapper(z);
			end
		end
		
	end
	
end
