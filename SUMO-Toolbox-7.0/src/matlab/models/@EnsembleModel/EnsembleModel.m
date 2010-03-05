classdef EnsembleModel < Model

% EnsembleModel (SUMO)
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
%	EnsembleModel(varargin)
%
% Description:
%	Constructs a basic weighted ensemble object

  properties(Access = private)
    models;
    eqThreshold;
    weights;
  end

  methods
    function this = EnsembleModel(varargin)

      if(nargin < 1)
	models = {};
	eqThreshold = 0.05;
      elseif(nargin == 1)
	models = varargin{1};
	
	%ensemble members must differ by 5 percent
	eqThreshold = 0.05;
      elseif(nargin == 2)
	models = varargin{1};
	eqThreshold = varargin{2};
      else
	error('Invalid number of arguments');
      end

      if(nargin > 0)
	% check that all the input and output dimensions match
	[indim outdim] = getDimensions(models{1});

	for i=2:length(models)
		[id od] = getDimensions(models{i});
		if(id ~= indim || od ~=outdim)
			error('The input/output dimensions of the ensemble members must match');
		end
	end

	% Call construct on the base class to set things like id, dimension, etc.
	% TODO: this does not work due to a silly restriction of Matlabs OO impl
	%this = constructInModelSpace@Model(this,getSamplesInModelSpace(models{1}), getValues(models{1}));
	% instead an init method was added
	this = this.init(getSamplesInModelSpace(models{1}), getValues(models{1}));
      end		
      
      this.weights = [];
      this.models = models;
      this.eqThreshold = eqThreshold;

      % Set to a simple average ensemble by default
      this = setWeights(this,1);
    end


    function res = getModels(this)
      res = this.models;
    end

    function res = getSize(this)
      res = length(this.models);
    end

    function res = getWeights(this)
      res = this.weights;
    end
    
    function values = evaluateMSEInModelSpace( s, points )
        %Return the weighted average prediction
        [in out] = getDimensions(s);

        values = zeros(size(points,1),out);

        for i=1:length(s.models)
            values = values + (s.weights(i) .* evaluateMSEInModelSpace( s.models{i}, points ) );
        end
    end

    this = setWeights(this,w);
    this = removeDuplicates(this);
    [this replaced] = replaceWeakest(this, model);
    [this replaced] = randomReplace(this, model);
    this = optimizeWeights(this);
    res = getModelTypes(this);
    this = addModel(this,model);
    res = contains(this,model);
    this = constructInModelSpace(this, samples, values);
    [values] = evaluateInModelSpace(this, points);
    desc = getDescription(this);
    desc = getExpressionInModelSpace(this,outputIndex);
    res = complexity(this);
    res = saveobj(this);

  end
end
