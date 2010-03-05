classdef ExpressionModel < Model

% ExpressionModel (SUMO)
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
%	ExpressionModel(expression, inDim, outDim, inRange, samples, values)
%
% Description:
%	Wraps any matlab expression in a SUMO Model object

	
	properties(Access = private)
		inDim;
		outDim;
		expression;
	end
	
	methods(Access = public)
		
		
		function s = ExpressionModel(expression, inDim, outDim, inRange, samples, values)
			% ExpressionModel (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			%
			% Description:
			%     Wrapper class that wraps a matlab function handle so that it can be
			%     used as a SUMO toolbox model. It can then be analyzed using the plot
			%     functionality of the toolbox.

			% calculate scale/trans values
			min = inRange(:,1)';
			max = inRange(:,2)';
			translate = (max+min) ./ 2.0;
			scale = (max-min) ./2.0;

			[inFunc, outFunc] = calculateTransformationFunctions([translate ; scale]);

			if ~exist( 'samples', 'var' )
				samples = zeros(1,inDim);
			else
				% transform points to model space
				samples = inFunc(samples);
			end
			if ~exist( 'values', 'var' )
				values = zeros(1,outDim);
			end

			% superclass constructor
			s = s@Model(inDim, outDim, samples, values);
			
			s.inDim = inDim;
			s.outDim = outDim;
			s.expression = expression;
			
			% set the transformation values
			s = setTransformationValues(s, [translate ; scale]);
		end
	end
	
end

