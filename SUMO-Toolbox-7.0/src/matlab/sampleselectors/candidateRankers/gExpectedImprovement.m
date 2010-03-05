classdef gExpectedImprovement < CandidateRanker

% gExpectedImprovement (SUMO)
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
%	gExpectedImprovement(config)
%
% Description:

	
	properties
		isc_opts;
	end
	
	methods (Access = public)
		
		function this = gExpectedImprovement(config)
			this = this@CandidateRanker(config);
			this.isc_opts = str2num(char(config.self.getOption('criterion_parameter', '[]')));
		end

		function ei = scoreCandidates(this, points, state)

		% gExpectedImprovement (SUMO)
		%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
		%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
		%     Copyright: IBBT - IBCN - UGent
		% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
		% Revision: $Rev: 6376 $
		%
		% Description:
		%     Calculates the Generalized Expected Improvement

		model = state.lastModels{1}{1};
		g = this.isc_opts;

		y = evaluateInModelSpace( model, points );
		mse = evaluateMSEInModelSpace( model, points );

		var = sqrt( abs( mse ) );
		fmin = min( getValues(model) );

		% FIXME: what about vectorization ?
		if var == 0
			ei = zeros( size(points,1), 1 );
		else
			z  = (fmin-y)./var;

			T = normcdfWrapper(z); % actually T(0)
			T = [T, -normpdfWrapper(z)]; % ... T(1)

			ei = (z .^g) .* T(:,1);
			for k=1:g
				gk = g-k;
				ei = ei + ( (-1).^k .* z.^gk .* T(:,k+1) .* (factorial(g) ./ (factorial(k) .* factorial(gk))) );

				T = [T, (-normpdfWrapper(z) .* z.^k + k .* T(:,k))]; % next T(l) = ... .* T(l-2)
			end

			ei = var.^g .* ei;
		end
		end
		
	end
	
end
