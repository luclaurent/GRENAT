classdef RBFNNFactory < GeneticFactory

% RBFNNFactory (SUMO)
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
%	RBFNNFactory(config)
%
% Description:
%	This class is responsible for generating Radial Basis Function Neural Networks as implemented in the Matlab NN toolbox

    properties(Access = private)
        goal;
	spread;
	maxNeurons;
	spreadBounds;
	logger;
    end
    
    methods
        function this = RBFNNFactory(config)
            import java.util.logging.*;
	    import ibbt.sumo.config.*;

            this = this@GeneticFactory(config);

            this.logger = Logger.getLogger('Matlab.RBFNNFactory');

	    this.goal = config.self.getDoubleOption('goal', 0);
	    this.spread = config.self.getDoubleOption('spread',1);
	    this.maxNeurons = config.self.getIntOption('maxNeurons',800);
	    this.spreadBounds = str2num(config.self.getOption('spreadBounds','0.0001,2'));
        end

	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	    res = false;
	end

	function res = supportsMultipleOutputs(this)
	  res = true;
	end

        function [LB UB] = getBounds(this)
	    LB = [this.spreadBounds(1)];
	    UB = [this.spreadBounds(2)];
	end

	function res = getGoal(this)
	    res = this.goal;
	end
  
	function res = getMaxNeurons(this)
	    res = this.maxNeurons;
	end

	function model = createRandomModel(this)
	    sm = boundedRand(this.spreadBounds(1),this.spreadBounds(2));
	    model = this.createModel(sm);
	end
        
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'RBFNNModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
