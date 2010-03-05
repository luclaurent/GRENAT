classdef SVMFactory < GeneticFactory

% SVMFactory (SUMO)
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
%	SVMFactory(config)
%
% Description:
%	The class serves as a kind of base class for SVM based modelers, it takes care
%	of parsing and holding the basic configuration options that any SVM modeler needs

    properties(Access = private)
        backend;
        type;
        kernel;
        kernelParamBounds;
        regParamBounds;
        nu;
        epsilon;
        stoppingTolerance;
        extraParams;
	logger;
    end
    
    methods
        function this = SVMFactory(config)
            import java.util.logging.*;

            this = this@GeneticFactory(config);
            this.backend = char(config.self.getOption('backend', 'libSVM'));
            this.type = char(config.self.getOption('type', 'epsilon-SVR'));
            this.kernel = char(config.self.getOption('kernel', 'rbf'));
            this.kernelParamBounds = str2num(config.self.getOption('kernelParamBounds','-4,4'));
            this.regParamBounds = str2num(config.self.getOption('regParamBounds','-5,5'));
            this.nu = config.self.getDoubleOption('nu', 0.5);
            this.epsilon = config.self.getDoubleOption('epsilon', 1e-4);
            this.stoppingTolerance = config.self.getDoubleOption('stoppingTolerance', 1e-5);
            this.extraParams = char(config.self.getOption('extraParams', ''));
	    this.logger = Logger.getLogger('Matlab.SVMFactory');
        end

        function res = getType(this)
            res = this.type;
        end
        
        function res = getBackend(this)
            res = this.backend;
        end
        
        function res = getKernel(this)
            res = this.kernel;
        end
        
	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	    res = false;
	end

	function res = supportsMultipleOutputs(this)
	  res = true;
	end

        function [LB UB] = getBounds(this)
                LB = [this.kernelParamBounds(1) this.regParamBounds(1)];
                UB = [this.kernelParamBounds(2) this.regParamBounds(2)];
	end
        
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        model = createRandomModel(this);
        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'SVMModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
