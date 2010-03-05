classdef NANNModel < Model

% NANNModel (SUMO)
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
%	NANNModel( varargin )
%
% Description:
%	Constructs a new prunable neural network backed by the NNSYSID library

  properties(Access = private)
    config = struct(...
		    'initialWeights',struct('W1',[],'W2',[]),...
		    'networkDim', [2 5 1],...
		    'epochs', 1000,...
		    'decayValue', [1e-3 1e-3],... 
		    'pruneTechnique', 1, ...
		    'threshold', 0.2,...
		    'retrain', 50,...
		    'trainingGoal', 0,...
		    'percentage', [0]...
    );
    network;
  end

  methods
    function this = NANNModel( varargin )

      if(nargin == 0)
	% use defaults
      elseif(nargin == 1)
	this.config = varargin{1};
      elseif(nargin == 3)
	this.config.networkDim = varargin{1};
	this.config.epochs = varargin{2};
	this.config.trainingGoal = varargin{3};
      elseif(nargin == 4)
	this.config.networkDim = varargin{1};
	this.config.epochs = varargin{2};
	this.config.trainingGoal = varargin{3};
	this.config.initialWeights = varargin{4};
      else
	      error('Invalid number of parameters given');
      end

      network = struct(...
	      'NetDef', [],...
	      'W1', [],...
	      'W2', [] ...
      );

      if(nargin ~= 4)
	% initialize the weights
	this = randomInit(this,[-1,1]);
      end

    end

    function res = getNetworkDim(this)
      res = this.config.networkDim;
    end

    function [w1 w2] = getNetworkWeights(this)
      w1 = this.network.W1;
      w2 = this.network.W2;
    end

    function [w1 w2] = getInitialWeights(this)
      w1 = this.config.initialWeights.W1;
      w2 = this.config.initialWeights.W2;
    end

    function this = setInitialWeights(this,w1,w2)
      this.config.initialWeights.W1 = w1;
      this.config.initialWeights.W2 = w2;
    end

    function this = setPruneTechnique(this,p)
      this.config.pruneTechnique = p;
    end

    this = randomInit(this,range);
    res = getHiddenLayerDim(this);
    this = jitterInitialWeights(this);
    this = pruneNetwork(this,samples,values);
    this = constructInModelSpace(this, samples, values);
    [values] = evaluateInModelSpace(this, points);
    desc = getDescription(this);
    res = complexity(this);

  end
end
