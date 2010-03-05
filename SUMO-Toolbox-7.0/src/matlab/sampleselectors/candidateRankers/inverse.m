classdef inverse < CandidateRanker

% inverse (SUMO)
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
%	inverse(config)
%
% Description:

	
	properties
		isc_opts;
	end
	
	methods (Access = public)
		
		function this = inverse(config)
			this = this@CandidateRanker(config);
			this.isc_opts = str2num(char(config.self.getOption('criterion_parameter', '[]')));
		end

		function out = scoreCandidates(this, points, state)

			% inverse (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6376 $
			%
			% Description:

			model = state.lastModels{1}{1};

			y = evaluateInModelSpace( model, points );
			mse = evaluateMSEInModelSpace( model, points );

			s = sqrt( abs( mse ) );

			T1 = this.isc_opts(1); % lower
			T2 = this.isc_opts(2); % upper

			z1  = (T1-y)./s;
			z2  = (T2-y)./s;
			out = normcdfWrapper(z2) - normcdfWrapper(z1);
		end

		
	end
	
end
