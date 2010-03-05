classdef GaussianProcessFactory < GeneticFactory

% GaussianProcessFactory (SUMO)
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
%	GaussianProcessFactory(config)
%
% Description:
%	This class is responsible for generating Kriging Models

    properties(Access = private)
        dimension;
		regrFunction;
		covFunction;
		nrParameters;
		lowerThetaBounds;
		upperThetaBounds;
		initialTheta;
		nrParams;
		logger;
    end
    
    methods
		% Constructor
        function this = GaussianProcessFactory(config)
            import java.util.logging.*;

            this = this@GeneticFactory(config);
	    
			this.logger = Logger.getLogger('Matlab.GaussianProcessFactory');

			%% Theta Bounds
			initialTheta = str2num(char(config.self.getOption('initialTheta')));

			% If no initial theta, bounds are required
			if isempty( initialTheta )
				lowerThetaBound = str2num(char(config.self.getOption('lowerThetaBound', '[-5 -5 -5]')));
				upperThetaBound = str2num(char(config.self.getOption('upperThetaBound', '[3 3 3]')));
			% Otherwise, it is optional and are set empty if not given
			else
				lowerThetaBound = str2num(char(config.self.getOption('lowerThetaBound', '[]')));
				upperThetaBound = str2num(char(config.self.getOption('upperThetaBound', '[]')));
			end

			% initial theta
			if ~isempty(initialTheta)
				% checks
				if length(initialTheta) ~= 1 && length(initialTheta) ~= config.input.getInputDimension()
					msg = 'Illegal size of initialThetas, either provide 1 or provide 1 for each inputDimension';
					logger.severe(msg);
					error(msg);
				end

				% set bound for each parameter
				if length(initialTheta) == 1
					initialTheta = initialTheta * ones(1,config.input.getInputDimension());
				end
			else
				initialTheta = ones(1,config.input.getInputDimension());
			end

			regrFunc = char(config.self.getOption('regrFunction','regpoly0'));
			covFunc = char(config.self.getOption('covFunction','covSEiso'));
			D = config.input.getInputDimension(); % some cov functions use D to denote the number of input dimensions
			nrParameters = eval( feval( covFunc ) );

			% lower bound
			if ~isempty(lowerThetaBound)
				% checks
				if length(lowerThetaBound) ~= 1 && length(lowerThetaBound) ~= nrParameters
					msg = sprintf( 'Illegal size of lowerThetaBounds, either provide 1 or provide the complete %i for the covariance funcion', nrParameters );
					logger.severe(msg);
					error(msg);
				end

				% set bound for each parameter
				if length(lowerThetaBound) == 1
					lowerThetaBound = lowerThetaBound * ones(1,nrParameters);
				end
			end

			% upper bound
			if ~isempty(upperThetaBound)
				% checks
				if length(upperThetaBound) ~= 1 && length(upperThetaBound) ~= nrParameters
					msg = sprintf( 'Illegal size of upperThetaBounds, either provide 1 or provide the complete %i for the covariance funcion', nrParameters );
					logger.severe(msg);
					error(msg);
				end

				% set bound for each parameter
				if length(upperThetaBound) == 1
					upperThetaBound = upperThetaBound * ones(1,nrParameters);
				end
			end

			% checks
			if any(lowerThetaBound >= upperThetaBound) 
				msg = 'Lower Theta bound should be less than upper Theta bound';
				logger.severe(msg);
				error(msg);
			end
	  
			this.dimension = config.input.getInputDimension();
			this.regrFunction = regrFunc;
			this.covFunction =	covFunc;
			this.nrParameters = nrParameters;
			this.lowerThetaBounds =	lowerThetaBound;
			this.upperThetaBounds =	upperThetaBound;
			this.initialTheta = initialTheta;
        end

        function res = getRegressionFunction(this)
            res = this.regrFunction;
        end
     
        function res = getCovarianceFunction(this)
            res = this.covFunction;
        end
   
        function res = getBackend(this)
            res = 'GPML Matlab'; % from GaussianProcess.org
	end
        
	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	  res = false;
	end

	function res = supportsMultipleOutputs(this)
	    res = false;
	end

	function [LB UB] = getBounds(this)
	  LB = this.lowerThetaBounds;
	  UB = this.upperThetaBounds;
	end

	function model = createRandomModel(this)
	  [lb,ub] = getBounds(this);
	  theta = boundedRand(lb, ub);
	  model = this.createModel(theta);
	end

	% Function declarations
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'GaussianProcessModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)

	end % methods
end % classdef
