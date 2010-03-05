classdef ModelGridManager < handle

% ModelGridManager (SUMO)
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
%	ModelGridManager(config)
%
% Description:
%	Create a new empty model grid manager which can be used to store & get
%	the evaluated grid of a model.

  properties(Access = private)
    grids = {};
    sampleGenerator = [];
    sampleGeneratorParameters = [];
    samples = [];
    modelIdToGrids = [];
  end

  methods(Access = public)
    function this = ModelGridManager(config)
		
      % add cell array which will contain our grids
      this.grids = {};

      % cap grid size for efficiency reasons
      grid = config.self.getIntOption('modelGridSize', 20);
      maxGridSize = config.self.getIntOption('maxModelGridSize', 2500);
      maxGrid = floor(maxGridSize ^ (1/config.input.getInputDimension()));
      grid = min(grid, maxGrid);

      type = char(config.self.getOption('modelGrid', 'grid'));

      switch (type)	
	case 'grid'
		sgp = {grid, config.input.getInputDimension()};
		sg = @makePerturbedGrid;
	case 'lhs'
		sgp = {config.input.getInputDimension(),grid^config.input.getInputDimension()};
		sg = @latinHypercubeSample;
	end

	this.sampleGenerator = sg;
	this.sampleGeneratorParameters = sgp;

	% generate initial sample batch
	this.samples = feval(this.sampleGenerator, this.sampleGeneratorParameters{:});

	% sparse matrix which contains modelId -> grid index mapping
	this.modelIdToGrids = sparse(2147483646,1);
    end

    % Returns the samples on which a grid should be evaluated.
    function samples = getSamples(this)
      samples = this.samples;
    end

    this = addGrid(this, values, modelId);
    values = getGrid(this, modelId);
    this = reset(this);

  end
end
