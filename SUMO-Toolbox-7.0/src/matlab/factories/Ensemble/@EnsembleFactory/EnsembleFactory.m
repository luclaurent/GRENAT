classdef EnsembleFactory < GeneticFactory

% EnsembleFactory (SUMO)
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
%	EnsembleFactory(config)
%
% Description:
%	Responsible for generating weighted ensemble models.  This class is not intended to be used on its own
%	but rather as a byproduct of the heterogeneous evolution.

    properties(Access = private)
        eqThreshold;
	maxSize;
	logger;
    end
    
    methods
        function this = EnsembleFactory(config)
            import java.util.logging.*;

            this = this@GeneticFactory(config);

	    this.eqThreshold = config.self.getDoubleOption('equalityThreshold',0.05);
	    this.maxSize = config.self.getIntOption('maxSize',4);
	    this.logger = Logger.getLogger('Matlab.EnsembleInterface');
        end

        function res = getEqualityThreshold(this)
            res = this.eqThreshold;
        end
          
	function res = getMaxSize(this)
	    res = this.maxSize;
	end

	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	    res = true;
	end

	function res = supportsMultipleOutputs(this)
	    res = true;
	end

        function [LB UB] = getBounds(this)
           LB = [];
	   UB = [];
	end
        
        function models = createInitialModels(this,number,wantModels)
	    models = [];
	end

        function model = createModel(this,parameters)
	    model = [];
	end

        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'EnsembleModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
