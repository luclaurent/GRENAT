classdef RBFNNModel < Model

% RBFNNModel (SUMO)
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
%	RBFNNModel(varargin)
%
% Description:
%	Constructs a new Radial Basis Function Neural Network (RBFNN)

  properties(Access = private)
    config = struct(...
	'goal',			0,...
	'spread',		1,...
	'maxNeurons',		250,...
	'numNeurons',		0,...
	'trainingProgress',	Inf...
    );
    network;
  end

  methods

    function this = RBFNNModel(varargin)
      if(nargin == 0)
	      %use defaults
      elseif(nargin == 3)
	      this.config.goal = varargin{1};
	      this.config.spread = varargin{2};
	      this.config.maxNeurons = varargin{3};
      else
	      error('Invalid number of parameters given');
      end

      this.network = [];
    end

    function res = getGoal(this)
      res = this.config.goal;
    end

    function res = getMaxNeurons(this)
      res = this.config.maxNeurons;
    end

    function res = getSpread(this)
      res = this.config.spread;
    end

    function res = getNetwork(this)
      res = this.network;
    end

    this = constructInModelSpace(this, samples, values);
    [values] = evaluateInModelSpace(this, points);
    desc = getDescription(this);
    res = complexity(this);

  end
end
