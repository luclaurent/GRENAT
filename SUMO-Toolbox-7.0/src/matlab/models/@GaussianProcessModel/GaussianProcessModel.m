classdef GaussianProcessModel < Model

% GaussianProcessModel (SUMO)
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
%	GaussianProcessModel(varargin)
%
% Description:
%	Constructs a new Gaussian Process model

properties (Access = private)
	regrFunc;
	covFunc;
	theta;
	boundsTheta;
end

% method definitions
methods

	function this = GaussianProcessModel(varargin)
	
		this.regrFunc = 'regpoly1';
		this.covFunc = 'covSEiso';
		this.theta = 1;
		this.boundsTheta = [];

		if(nargin == 0)
			%use defaults
		elseif(nargin == 1)
			this.theta = varargin{1};
		elseif(nargin == 3)
			this.theta = varargin{1};
			this.regrFunc = varargin{2};
			this.covFunc = varargin{3};
		elseif(nargin == 4)
			this.theta = varargin{1};
			this.regrFunc = varargin{2};
			this.covFunc = varargin{3};
			this.boundsTheta = varargin{4};
		else
			error('Invalid number of parameters given');
		end
	end % ctor
	
	% construct (SUMO)
	% Description:
	%     Just sets all members to new samples and values
	this = constructInModelSpace(this, samples, values);

	% evaluateInModelSpace (SUMO)
	% Description:
	%     Evaluate the model at the given points
	values = evaluateInModelSpace(this, points);

	% evaluateMSE (SUMO)
	% Description:
	%     Evaluation at a set of points
	mse = evaluateMSEInModelSpace(this, points);

	% getTheta (SUMO)
	% Description:
	%     Getter
	theta = getTheta(this);
	
	% getCovFunction (SUMO)
	% Description:
	%     Getter
	covfunc = getCovFunction(this);

	% getDescription (SUMO)
	% Description:
	%     Return a user friendly model description
	desc = getDescription(this);
	
end % methods
end % classdef
