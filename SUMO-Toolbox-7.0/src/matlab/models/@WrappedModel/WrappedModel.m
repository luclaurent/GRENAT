classdef WrappedModel < ModelInterface

% WrappedModel (SUMO)
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
%	WrappedModel( varargin )
%
% Description:
%	This model is a wrapper around another model. It does not offer any
%	additional functionality, but it allows the user to combine models of
%	different types in the same matrix/array.

	
	properties(Access = private)
		nestedModel;
		filter;
	end
	
	methods
		
		%% implementations
		
		% constructor
		function this = WrappedModel( varargin )

			if(nargin < 1)
				nestedModel = [];
				% if the filter isn't defined, we don't filter anything at all
				
				filter = struct(...
					'filterToModel', @(x)(x), ...
					'filterFromModel', @(x)(x), ...
					'filterSamplesFromModel', @(x)(1:size(x,1)) ...
				);

			elseif(nargin == 1)
				nestedModel = varargin{1};
				
				filter = struct(...
					'filterToModel', @(x)(x), ...
					'filterFromModel', @(x)(x), ...
					'filterSamplesFromModel', @(x)(1:size(x,1)) ...
				);

			elseif(nargin == 2)
				nestedModel = varargin{1};
				filter = varargin{2};
			else
				error('Invalid number of arguments');
			end

			if(nargin > 0)
			  if(~isa(nestedModel,'ModelInterface'))
			    error(sprintf('Cannot wrap non-model type %s',class(nestedModel)));
			  %{
			  elseif(isa(nestedModel,'WrappedModel'))
			    this = nestedModel;
			    return;
				%}
			  end
			end

			% set the members
			this.nestedModel = nestedModel;
			this.filter = filter;
		end
		
		% get the nested model
		function model = getNestedModel(this)
			% Description:
			%	This function returns the wrapped model.
			model = this.nestedModel;
		end
		
		
		%% implemented in separate files
		
		[fighandle] = plotModel(varargin);

		res = complexity(this);
		[nin nout] = getDimensions(this);
		exp = getExpression(this,outputIndex);
		desc = getExpressionInModelSpace(this, outputIndex);
		
		id = getId(this);
		[samples, values] = getGrid(this);

		res = equals(this, m, threshold);
		values = evaluate(this, points);
		[values] = evaluateInModelSpace(this, points);
		[values] = evaluateDerivative(s, points, outputIndex);
		[values] = evaluateDerivativeInModelSpace(s, points, outputIndex);

		[inFunc outFunc] = getTransformationFunctions(m);
		[scores] = getMeasureScores(this);

		function [transf] = getTransformationValues(m)
		    transf = getTransformationValues(m.nestedModel);
		end

		samples = getSamples(this);
		samples = getSamplesInModelSpace(this);
		values = getValues(this);

		function [LB UB] = getBounds(m)
		  [LB UB] = getBounds(m.nestedModel);
		end

		[score] = getScore(this);
		names = getInputNames(this);
		names = getOutputNames(this);
		
		values = evaluateMSEInModelSpace(this, points);
		values = evaluateMSE(this, points);
		this = constructInModelSpace(this, samples, values);

		t = getType(this);
		res = saveobj(this);

		desc = getDescription(this);
        
        function this = updateInModelSpace(this, samples, values)
            this = updateInModelSpace(this.nestedModel,samples, values);
        end
        
        function this = update(this, samples, values)
            this = update(this.nestedModel,samples, values);
        end
	end
end
