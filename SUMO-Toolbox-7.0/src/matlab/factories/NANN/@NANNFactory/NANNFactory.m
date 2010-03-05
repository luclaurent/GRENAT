classdef NANNFactory < GeneticFactory

% NANNFactory (SUMO)
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
%	NANNFactory(config)
%
% Description:
%	This class is responsible for generating neural network models as implemented in the NNSYSID library
%	http://www.iau.dtu.dk/research/control/nnsysid.html

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
        function this = NANNFactory(config)
            import java.util.logging.*;
	    import ibbt.sumo.config.*;

            this = this@GeneticFactory(config);

            this.logger = Logger.getLogger('Matlab.NANNFactory');

	    this.initialSize = config.self.getIntOption('initialSize', 5);
	    this.epochs = config.self.getIntOption('epochs',1000);
	    this.trainingGoal = config.self.getDoubleOption('trainingGoal',0);
	    this.initWeightRange = str2num( config.self.getOption('initWeightRange', '-0.8,0.8') );
	    this.hiddenUnitDelta = str2num( config.self.getOption('hiddenUnitDelta', '-2,3') );
	    this.allowedPruneTechniques = str2num(config.self.getOption('allowedPruneTechniques', '0,1,2,3,4'));
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

	function res = getAllowedPruneTechniques(this)
	  res = this.allowedPruneTechniques;
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
	    newDim = [s.numInputs randomInt([0 20]) s.numOutputs];
	    model = this.createModel(newDim);
	end
        
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'NANNModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
