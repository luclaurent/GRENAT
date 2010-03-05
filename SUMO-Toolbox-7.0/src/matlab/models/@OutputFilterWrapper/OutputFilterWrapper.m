classdef OutputFilterWrapper < WrappedModel

% OutputFilterWrapper (SUMO)
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
%	OutputFilterWrapper(model, outputs)
%
% Description:
%	This class wraps another model, hiding one or more outputs

	properties(Access = private)
		filter;
	end
	
	methods

		function s = OutputFilterWrapper(model, outputs)
			s = s@WrappedModel(model);
			s.filter = outputs;
		end
		
		function filter = getFilters(this)
			filter = this.filter;
		end
		
		values = evaluate(s, points);
		[values] = evaluateInModelSpace(s, points);
		values = evaluateMSE(s, points);
		[ni no] = getDimensions(s);
		desc = getExpression(s,outputIndex);
		desc = getExpressionInModelSpace(s, outputIndex);
		[samples, values] = getGrid(m);
		names = getOutputNames(m);
		values = getValues(m);
		
	end
end
