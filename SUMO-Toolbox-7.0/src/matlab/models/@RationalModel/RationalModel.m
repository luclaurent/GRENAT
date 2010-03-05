classdef RationalModel < Model

% RationalModel (SUMO)
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
%	RationalModel(varargin)
%
% Description:
%	Construct a `RationalModel' object. (doh)
%	A rational object can be used to interpolate sample/value
%	pairs. It is created using a `degrees' object and a percentage
%	that states the ratio of degrees of freedom in the interpolation
%	system over the number of samples. So 100% means interpolation,
%	anything smaller will lead to least-squares approximation.
%	A copy constructor and a constructor from a structure created
%	by the `makestorestruct' method are also available.

	properties(Access = private)
		percent;
		weights;
		flags;
		frequencyVariable;
		baseFunctions;
		degrees;
		weighted;
		numerator;
		denominator;
		freedom;
		covarianceMatrix;
	end
	
	methods
		
		function this = RationalModel(varargin)

			if nargin == 6
				this.percent = varargin{1};
				this.weights = varargin{2};
				this.flags =  varargin{3};
				this.frequencyVariable =  varargin{4};
				this.baseFunctions =  varargin{5};
				this.degrees =  Degrees( this.weights, this.flags);
				this.weighted =  varargin{6};
			elseif nargin == 0
				% do nothing, keep empty
			else
				error('RationalModel requires 6 arguments for the constructor.'); % very nice exception
			end
		end
		
		values = evaluateMSEInModelSpace(s, points);
		s = constructInModelSpace(s, samples, values);
		[values] = evaluateInModelSpace(s, points);
		desc = getDescription(s);
		desc = getExpressionInModelSpace(s, outputIndex);
	end
end
