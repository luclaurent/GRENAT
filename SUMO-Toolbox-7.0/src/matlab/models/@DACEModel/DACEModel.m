classdef DACEModel < Model

% DACEModel (SUMO)
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
%	DACEModel( varargin )
%
% Description:
%	A design and analysis of computer experiments (DACE) model, also
%	known as a deterministic Kriging model. The configuration fields are:
%	  config.trend : The degree of the polynomial trend function used
%	  config.kernelFunction : The kernel function to be used, one for each dimension
%	  config.theta : The shape parameters for each kernel function

  properties(Access = private)
    config = 0;
    trendDegrees = 0;
    trendCoeff = 0;
    kernelCoeff = 0;
	trendMatrix = [];
	kernelMatrix = [];
  end
	
  methods(Access = public)

    function this = DACEModel( varargin )
      if nargin == 0
	this.config = 0;
      elseif(nargin == 1)
	this.config = varargin{1};
      else
	error('Invalid number of input arguments given');
      end
    end

    function c = getConfig(this)
	c = this.config;
    end

    this = constructInModelSpace(this, samples, values);
    [values] = evaluateInModelSpace(this, points);
    desc = getDescription(this);

  end

  methods(Access = private)
    kernelmatrix = buildKernelMatrix( this, points, samples, kernels );
  end

end
