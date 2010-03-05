classdef KrigingFactory < GeneticFactory

% KrigingFactory (SUMO)
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
% Revision: $Rev: 6405 $
%
% Signature:
%	KrigingFactory(config)
%
% Description:
%	This class is responsible for generating Kriging Models

    
    properties(Access = private)
		options = KrigingFactory.getDefaultOptions();
			
		initialHp = [];
		initialCorrelationFunction = 1; % always the first one
        correlationFunctions;
        nBFs;
		nrHyperparameters = [];
        regressionFunction;
        logger;
    end
    
    methods
        function this = KrigingFactory(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            this = this@GeneticFactory(config);
            this.logger = Logger.getLogger('Matlab.KrigingFactory');
            
            %% Parse correlation functions
            bfs = BasisFunction.loadBasisFunctions(config);
            this.nBFs = length(bfs);
            
            if this.nBFs == 0
                msg = 'No BasisFunctions found';
                this.logger.severe(msg);
                error(msg);
            elseif this.nBFs ~= 1
                override = config.self.getBooleanOption( 'multipleBasisFunctionsAllowed', false );
                if override
                    this.logger.warning( 'More than one basis function is provided, and override is switched on' );
                    this.logger.warning( 'Using a discrete extra parameter value to represent the basis function' );
                    this.nrHyperparameters = this.nrHyperparameters + 1; % extra parameter is correlation func
                else
                    this.logger.severe( 'More than one basis function specified, set multipleBasisFunctionsAllowed to true' );
                    this.logger.severe( 'to continue, this will add a discrete extra parameter to represent the selected BF' );
                    error( 'More than one basis function present, see log message above for explanation' );
                end
            end
            
            this.correlationFunctions = bfs;
			
			%% number of hyperparameters
            this.nrHyperparameters = this.correlationFunctions{1}.nrHyperParameters();
            
            %% Theta Bounds
            this.initialHp = str2num(char(config.self.getOption('initialHp')));
            
            % initial theta
			if isempty(this.initialHp)
				this.initialHp = 0.5*ones(1,this.nrHyperparameters);
			end
            
            this.regressionFunction = char(config.self.getOption('regressionFunction','regpoly0' ) );
			this.options.regressionMetric = char(config.self.getOption('regressionMetric','' ) );
			
            this.options.lambda0 = config.self.getDoubleOption('noise', -Inf );
			%this.options.lambdaBounds = str2num(config.self.getOption('noiseBounds','[-15 -5]' ) );
			
            %DISABLED for version 7.0
			%this.options.lowRankApproximation = config.self.getBooleanOption('lowRank', false );
            %this.options.maxOrder = str2num( config.self.getOption('maxOrder', '2' ) );
			this.options.debug = config.self.getBooleanOption('debug', false );
			
			% if GA,... + blind kriging then error
			if ~strcmp(config.parent.getAttrValue( 'type' ), 'AdaptiveModelBuilder' ) && ...
				   ~isempty( this.options.regressionMetric )
				msg = sprintf('Blind kriging (regressionMetric=cvpe) works only with an AdaptiveModelbuilder.');
				this.logger.severe(msg);
				error(msg);
			end
			
			% optimizer
			optimizer = config.self.selectSingleNode('Optimizer');
			
			if strcmp(config.parent.getAttrValue( 'type' ), 'AdaptiveModelBuilder' )
				if isempty( optimizer )
					msg = 'You must specify the optimization method for the (Blind) Kriging model.';
					this.logger.severe(msg);
					error(msg)
				else
					this.options.hpOptimizer = instantiate(optimizer,  config);
				end
			else
				if ~isempty( optimizer )
					this.logger.warning('Optimizer tag specified for kriging but not used');
				end
			end
			
        end
        
        function res = getRegressionFunction(this)
            res = this.regressionFunction;
        end
                
        %%% Implement ModelFactory
        function res = supportsComplexData(this)
            res = true;
        end
        
        function res = supportsMultipleOutputs(this)
            res = true;
        end
        
        function [LB UB] = getBounds(this)
			% Set hyperparameter range - fixed [-1,1]
            LB = -ones(1,this.nrHyperparameters);
			UB =  ones(1,this.nrHyperparameters);
            
            % Fill up initial theta and bounds with the number of basis functions if needed
            if this.nBFs > 1
                LB(:,end) = 1;
                UB(:,end) = this.nBFs;
            end
        end
        
        function model = createRandomModel(this)
            [lb,ub] = getBounds(this);
            theta = boundedRand(lb', ub')';
            model = this.createModel(theta);
        end
        
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,varargin);
        obs = getObservables(this);
        
        %%% Implement GeneticFactory
        function res = getModelType(this)
            res = 'KrigingModel';
        end
        
        mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
        xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
	end
	
	methods(Static)
		
		function options = getDefaultOptions()
			options = struct( ...
				'hpBounds', [], ... %
				'lambda0' ,-Inf, ... % lambda, regression coefficient (optional)
				'lambdaBounds', [-10 ; 0], ... % log
				'regressionMetric', '', ... % string -> function handle
				'maxOrder', 2, ... % maximum order of candidate feature to consider (quadratic)
				'hpOptimizer', [], ... % optimizer class
				'lowRankApproximation', false, ...
				'rankTol', 1e-12, ... % tolerance for lowRankApprox.
				'rankMax', Inf, ... % maximum rank to achieve for lowRankApprox.
				'retuneParameters', false, ... % retune parameters after every BK step
				'debug', false );
		end
	end
end
