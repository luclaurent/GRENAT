classdef InitialDesign

% InitialDesign (SUMO)
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
%	InitialDesign(varargin)
%
% Description:
%	Base class for all initial design generators

  properties (Access = private)
    importanceParameters;
    inputDim;
    outputDim;
  end

  % method definitions
  methods

    function this = InitialDesign(varargin)
      import ibbt.sumo.config.*;

      if(nargin == 0)
	this.importanceParameters = [];
	this.inputDim = -1;
	this.outputDim = -1;
      elseif(nargin == 1)
	config = varargin{1};
	ip = config.self.getOption('importanceParameters','');
	this.importanceParameters = str2num(ip);
	this.inputDim = config.input.getInputDimension();
	this.outputDim = config.output.getOutputDimension();
      elseif(nargin == 2)
	this.inputDim = varargin{1};
	this.outputDim = varargin{2};
      else
	error('Invalid number of input parameters');
      end
    end

    function ip = getImportanceParameters(this)
      ip = this.importanceParameters;
    end

    function this = setImportanceParameters(this,ip)
      this.importanceParameters = ip;
    end

    function [inDim outDim] = getDimensions(this)
      inDim = this.inputDim;
      outDim = this.outputDim;
    end

  end

  methods (Abstract = true)
    % generate a set of initial samples, some (or all) of which may already be evaluated
    % ie, output are provided as well
    [initialsamples, evaluatedsamples] = generate( this );
  end

end
