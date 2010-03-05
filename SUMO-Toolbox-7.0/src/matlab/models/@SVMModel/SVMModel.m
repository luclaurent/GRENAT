classdef SVMModel < Model

% SVMModel (SUMO)
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
%	SVMModel( varargin )
%
% Description:
%	Constructs a new Support Vector Machine (SVM) model using the given configuration

  properties(Access = private)
    config = struct(...
	    'backend',			'libSVM',...
	    'type',			'epsilon-SVR', ...
	    'kernel',			'rbf', ...
	    'kernelParams',		2, ...
	    'regularizationParam',	1, ...
	    'nu',			0.01, ...
	    'epsilon',			1e-4, ...
	    'stoppingTolerance',	1e-5, ...
	    'crossvalidationFolds',	0, ...
	    'extraParams',		'' ...
    );
    svm;
  end

  methods
    function this = SVMModel( varargin )
      if(nargin == 0)
	% use defaults
      elseif(nargin == 1)
	this.config = varargin{1};
      elseif(nargin == 5)
	this.config.backend = varargin{1};
	this.config.type = varargin{2};
	this.config.kernel = varargin{3};
	this.config.kernelParams = varargin{4};
	this.config.regularizationParam = varargin{5};
      else
	error('Invalid number of parameters');
      end
      svm.svm = [];
    end

    function res = getConfig(this)
      res = this.config;
    end

    function res = getKernelParam(this)
      res = this.config.kernelParams;
    end

    function res = getRegParam(this)
      res = this.config.regularizationParam;
    end

    this = constructInModelSpace(this, samples, values);
    [values] = evaluateInModelSpace(this, points);
    desc = getDescription(this);
    res = complexity(this);
    
    % evaluateMSEInModelSpace (SUMO)
    % Description:
    %     Evaluation of prediction variance at a set of points
    mse = evaluateMSEInModelSpace(this, points)

  end

  methods(Access = private)
    this = constructlibSVM(this,samples,values);
    this = constructLSSVM(this,samples,values);
    this = constructSVMlight(this,samples,values);
    res = evaluatelibSVM(this,samples);
    res = evaluateLSSVM(this,samples);
    res = evaluateSVMlight(this,samples);
  end

end

