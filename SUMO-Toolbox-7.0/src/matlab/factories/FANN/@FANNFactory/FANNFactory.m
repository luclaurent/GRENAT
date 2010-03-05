classdef FANNFactory < GeneticFactory

% FANNFactory (SUMO)
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
%	FANNFactory(config)
%
% Description:
%	This class is responsible for generating neural network models as implemented in the
%	Fast Artificial Neural Network Libary (FANN) http://leenissen.dk/fann/

    properties(Access = private)
	initialSize;
        epochs;
	trainingGoal;
	initWeightRange;
	hiddenUnitDelta;
	allowedPruneTechniques;
	logger;
    end
    
    methods
        function this = FANNFactory(config)
            import java.util.logging.*;
	    import ibbt.sumo.config.*;

            this = this@GeneticFactory(config);

            this.logger = Logger.getLogger('Matlab.FANNFactory');

	    hidLayers = config.self.getOption('initialSize','4,4');
	    if(length(hidLayers) < 1)
		%No hidden layers requested
		hiddenLayerDim = [];
	    else
		hiddenLayerDim = str2num(hidLayers);
	    end	
	      
	    this.initialSize = hiddenLayerDim;
	    this.epochs = config.self.getIntOption('epochs',1000);
	    this.trainingGoal = config.self.getDoubleOption('trainingGoal',0);
	    this.initWeightRange = str2num( config.self.getOption('initWeightRange', '-0.8,0.8') );
	    this.hiddenUnitDelta = str2num( config.self.getOption('hiddenUnitDelta', '-2,3') );
        end

	function res = getTrainingGoal(this)
	  res = this.trainingGoal;
	end

	function res = getInitWeightRange(this)
	  res = this.initWeightRange;
	end

	function res = getInitialSize(this)
	  res = this.initialSize;
	end

	function res = getEpochs(this)
	  res = this.epochs;
	end

	function res = getHiddenUnitDelta(this)
	  res = this.hiddenUnitDelta;
	end

	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	    res = false;
	end

	function res = supportsMultipleOutputs(this)
	    res = true;
	end

        function [LB UB] = getBounds(this)
	    LB = [];
	    UB = [];
	end

	function model = createRandomModel(this)
	    newDim = [randomInt([0 20]) randomInt([0 20])];
	    model = this.createModel(newDim);
	end

        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'FANNModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end

