classdef rationalPoleSupression < CandidateRanker

% rationalPoleSupression (SUMO)
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
%	rationalPoleSupression(config)
%
% Description:
%	Promotes points that makes the denominator zero, thus finding poles

	methods (Access = public)
		
		function this = rationalPoleSupression(config)
			this = this@CandidateRanker(config);
            this = this.setOrder('min');
		end

		function denom = scoreCandidates(this, points, state)
            
            % We need to get access to evaluateDenominator, which is not inherited in
            % WrappedModel. It also does not honor the outputs...
            model = state.lastModels{1}{1};
            outputs = model.getFilters();
            model = model.getNestedModel();

            if isa( model, 'RationalModel' )
                denom = abs( evaluateDenominator( model, points ) );
                denom = denom(:,outputs);
            else
                error('The rationalPoleSupression criterion only works with rational models');
            end
        end
    end
end
