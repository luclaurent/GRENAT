classdef ModelInterface

% ModelInterface (SUMO)
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
%
% Description:
%	The model interface provides the set of abstract functions that must be
%	supported by any model, be it real or wrapper.

	properties (Access = private)
	end

	% methods
	methods (Abstract = true)
		
		[fighandle] = plotModel(varargin);

		[res] = complexity(model);
		[in, out] = getDimensions(s);
		[exp] = getExpression(s,outputIndex);
		[desc] = getExpressionInModelSpace(s, outputIndex);
		
		[id] = getId(m);
		[samples, values] = getGrid(m);

		[res] = equals(s, m, threshold);
		[values] = evaluate(s, points);
		[values] = evaluateInModelSpace(s, points);
	
		[values] = evaluateDerivative(s, points, outputIndex);
		[values] = evaluateDerivativeInModelSpace(s, points, outputIndex);

		[inFunc outFunc] = getTransformationFunctions(m);
		[scores] = getMeasureScores(this);

		[samples] = getSamples(m);
		[samples] = getSamplesInModelSpace(m);
		[values] = getValues(m);
		[LB UB] = getBounds(s);

		[score] = getScore(s);
		[names] = getInputNames(m);
		[names] = getOutputNames(m);
		
		[values] = evaluateMSE(s, points);
		[values] = evaluateMSEInModelSpace(s, points);
		[s] = constructInModelSpace(s, samples, values);
		
		[desc] = getDescription(s);
	end
	
end 
