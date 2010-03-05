classdef PolynomialModel < Model

% PolynomialModel (SUMO)
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
%	PolynomialModel(varargin)
%
% Description:
%	Construct a `PolynomialModel' object. (doh)
%	Simply fits a polynomial of degree 'degree' using (generalized) least squares

	properties (Access = private)
		degrees;
		baseFunctions;
		beta;
		covariance_matrix;
	end


% method definitions
methods
		
	function this = PolynomialModel(varargin)

		this.degrees = [0 0;0 1;0 2;1 0;1 1;1 2;2 0;2 1;2 2];
		this.baseFunctions = {@chebyshevBase};
		this.beta = {{}};
		this.covariance_matrix = {{}};

		if(nargin == 0)
			%use defaults
		elseif(nargin == 1)
			this.degrees = varargin{1};
		elseif(nargin == 2)
			this.degrees = varargin{1};
			this.baseFunctions = varargin{2};
		else
			error('Invalid number of parameters given');
		end
	end

	% complexity (SUMO)
	% Description:
	%     Returns the number of free variables in the model. This is the
	%     number of coefficients
	function res = complexity(this)
		res = size( this.degrees, 1 );
	end

	% constructInModelSpace (SUMO)
	% Description:
	%     Just sets all members to new samples and values
	this = constructInModelSpace(this, samples, values);

	% evaluateInModelSpace (SUMO)
	% Description:
	%     Evaluate the model at the given points
	values = evaluateInModelSpace(this, points);


	% evaluateMSEInModelSpace (SUMO)
	% Description:
	%     Evaluation at a set of points
	mse = evaluateMSEInModelSpace(this, points);

	% getDescription (SUMO)
	% Description:
	%     Return a user friendly model description
	desc = getDescription(this);

	% getExpressionInModelSpace (SUMO)
	% Description:
	%     Returns the closed, symbolic expression (as a string) of the model
	%     for the given output number
	desc = getExpressionInModelSpace(this, outputIndex);


	% getOrder (SUMO)
	% Description:
	%     Getter
	theta = getOrder(this);

end % methods
end % classdef
