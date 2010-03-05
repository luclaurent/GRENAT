classdef AdaptiveModelBuilder

% AdaptiveModelBuilder (SUMO)
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
%	AdaptiveModelBuilder(config)
%
% Description:
%	Adaptive model builder base class.  The model builder implements a hyperparameter
%	optimization algorithm that drives the ModelFactory object

    
    properties(Access = private)
        % The model factory responsible for generating the actual models
        modelFactory;
        % Simulator dimensions
        inputDimension;
        inputNames;
        outputNames;
        outputDesc;
        outputDimension;
        flatOutputDimension;
        combineOutputs;
        samplingEnabled;
        % Model data
        bestModels;
        bestModelId;
        nBestModels;
        transformationValues;
        % measure data for each output processed by this builder
        measureData;
        % if more than 1 a multi objective algorithm can be used (pareto mode)
        numTargets;
        paretoMode;
        % Location to store the models
        rootDirectory;
        outputDirectory;
        % Counters
        bestModelIndex;
        modelCounter;
        runNumber;
        % how had adding samples affected the score of the best model
        rebuildBestModelEffect;
        % Counter to keep track of the number of orderBestModels (= when the pareto front is changed and re-saved)
        paretoIndex;
        % Levelplot object
        levelPlot;
        % keep models from previous modeling iterations
        keepOldModels;
        % AMB provides a generic implementation of a fitness function, these fields are rleated to that
        plotOptimSurface;
        plotOptimSurfaceOpts;
        plotHandle;
        searchHistory;
        scoreHistory;
        restartStrategy;
        reliability;
        % other stuff
        startTime;
        maximumTime;
        finalTargetsReached;
        penalty;
        state;
        plotOptions;
        parallelMode;
        % profilers & logging
        rebuildBestModelProfiler;
        bestModelProfiler;
        elapsedTimeProfiler;
        freeParamProfiler;
        resourcesProfiler;
        minimumProfiler;
        paretoProfiler;
        obsProfilers;
        profilerID;
        logger;
    end
    
    methods(Access = public)
        
        function this = AdaptiveModelBuilder(config)
            import java.util.logging.*
            import ibbt.sumo.profiler.*;
            import ibbt.sumo.config.*;
            
            this.logger = Logger.getLogger('Matlab.AdaptiveModelBuilder');
            
            % important directories
            this.rootDirectory = char(config.context.getRootDirectory());
            this.outputDirectory = char(config.context.getOutputDirectory());
            
            % simulator dimensions
            this.outputDimension = config.output.getOutputDimension();
            this.inputDimension = config.input.getInputDimension();
            this.flatOutputDimension = config.output.getSimulatorOutputDimension();
            this.outputNames = cell(config.output.getOutputNames());
            this.inputNames = cell(config.input.getInputNames());
            this.outputDesc = config.output.getOutputDescriptions();
            
            if(this.outputDimension < 1)
                msg = 'Not a single output has been selected!';
                this.logger.severe(msg);
                error(msg);
            end
            
            % are we generating models with multiple outputs?
            this.combineOutputs = config.self.getBooleanAttrValue('combineOutputs','false');
            
            % is sampling enabled
            this.samplingEnabled = config.context.samplingEnabled();
            
            % Get the model factory
            mf = config.self.selectSingleNode('ModelFactory');
            if(isempty(mf))
                error('The modelbuilder must contain a <ModelFactory> tag in order to work');
            end
            this.modelFactory = instantiate(mf, config);
            
            % Get the model plot options
            plotOptions = config.context.getPlotOptions();
            if ~isempty( plotOptions )
                plotOptions = convertProperties( plotOptions.getAllOptionsAsProperties() );
            end
            
            % Get the optim surface plot options
            this.plotOptimSurface = config.self.getBooleanOption('plotOptimSurface',false);
            this.plotOptimSurfaceOpts = plotScatteredData();
            
            [LB UB] = getBounds(this.modelFactory);
            this.plotOptimSurfaceOpts.lowerBounds = LB;
            this.plotOptimSurfaceOpts.upperBounds = UB;
            this.plotOptimSurfaceOpts.title = 'Hyperparameter optimization surface';
            this.plotOptimSurfaceOpts.contour = 1;
            this.plotOptimSurfaceOpts.colorbar = 1;
            
            % Fill in the blanks with defaults
            [plotDefaults] = Model.getPlotDefaults();
            this.plotOptions = mergeStruct( plotDefaults, plotOptions );
            
            % setup the measures
            [this.measureData this.numTargets] = setupMeasures(this, config);
            
            % create sample manager, so we can get the transformation functions for models
            sampleManager = SampleManager(config);
            this.transformationValues = getTransformationValues(sampleManager);
            
            % is pareto mode enabled?
            this.paretoMode = false;
            this.nBestModels = str2num(char(config.self.getOption('nBestModels', '[]')));
            
            if(this.numTargets == 1)
                % there is only one active enabled measure
                
                % did the user specify nBestModels
                if(isempty(this.nBestModels))
                    % no he didnt, set to 5, should be more than enough
                    this.nBestModels = 5;
                else
                    % use what the user wanted
                end
            elseif(this.numTargets > 1)
                % more than one active enabled measure
                
                % did the user specify nBestModels
                if(isempty(this.nBestModels))
                    % no he didnt, set to 8
                    this.nBestModels = 8;
                else
                    % use what the user wanted
                end
                
                % are we in pareto mode
                this.paretoMode = config.self.getBooleanOption('paretoMode',0);
                if(this.paretoMode)
                    this.logger.info(sprintf('The model builder will run in multi-objective (pareto) mode with %d objectives',this.numTargets));
                else
                    this.logger.info(sprintf('The model builder will  not run in multi-objective mode, a weighted average of the %d objectives will be taken',this.numTargets));
                end
            else
                error('A modelbuilder needs at least one enabled measure');
            end
            this.logger.fine(sprintf('nBestModels set to %d',this.nBestModels));
            
            % Setup the profilers
            this.profilerID = char(config.output.getOutputNamesAsString('_'));
            this.logger.info(sprintf('Configuring model builder for outputs %s', this.profilerID));
            
            profname = ['BestModelScore_' this.profilerID];
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            this.bestModelProfiler = ProfilerManager.getProfiler(profname);
            this.bestModelProfiler.setDescription('Model Score; aggregated score over all measures');
            
            profname = ['ElapsedTime_' this.profilerID];
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            this.elapsedTimeProfiler = ProfilerManager.getProfiler(profname);
            this.elapsedTimeProfiler.setDescription('Runtime; number of samples vs elapsed time');
            
            profname = ['ModelComplexity_' this.profilerID];
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            this.freeParamProfiler = ProfilerManager.getProfiler(profname);
            this.freeParamProfiler.setDescription('Model Complexity; number of samples vs # number of parameters');
            
            profname = ['MemoryUse_' this.profilerID];
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            this.resourcesProfiler = ProfilerManager.getProfiler(profname);
            this.resourcesProfiler.setDescription('JVM Memory Usage');
            
            profname = ['SampleMinimum_' this.profilerID];
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            this.minimumProfiler = ProfilerManager.getProfiler(profname);
            this.minimumProfiler.setDescription('Current feasible minimum value');
            
            % construct profilers for adaptive sampling
            if (this.samplingEnabled)
                this.bestModelProfiler.addColumn('sampleSize', 'Number of samples');
                this.elapsedTimeProfiler.addColumn('sampleSize', 'Number of samples');
                this.freeParamProfiler.addColumn('sampleSize', 'Number of samples');
                this.resourcesProfiler.addColumn('sampleSize', 'Number of samples');
                this.minimumProfiler.addColumn('sampleSize', 'Number of samples');
                
                profname = ['RebuildBestModelEffect_' this.profilerID];
                profname = ProfilerManager.makeUniqueProfilerName(profname);
                this.rebuildBestModelProfiler = ProfilerManager.getProfiler(profname);
                this.rebuildBestModelProfiler.setDescription('Impact of adding samples on the overall score of the best model');
                this.rebuildBestModelProfiler.addColumn('sampleSize', 'Number of samples');
                this.rebuildBestModelProfiler.addColumn('scoreChange', 'Change in the overall best model score');
                
                % construct profilers for adaptive modelling
            else
                this.bestModelProfiler.addColumn('iteration', 'New best model number');
                this.elapsedTimeProfiler.addColumn('iteration', 'New best model number');
                this.freeParamProfiler.addColumn('iteration', 'New best model number');
                this.resourcesProfiler.addColumn('iteration', 'New best model number');
                this.minimumProfiler.addColumn('iteration', 'New best model number');
            end
            
            this.bestModelProfiler.addColumn('bestScore', 'Best model score');
            this.elapsedTimeProfiler.addColumn('elaspedTime', 'Elapsed Time in minutes');
            this.freeParamProfiler.addColumn('complexity', 'Model complexity (number of paramters)');
            this.resourcesProfiler.addColumn('usage', 'JVM memory usage (MB)');
            this.resourcesProfiler.addColumn('available', 'Available JVM memory (MB)');
            
            for i=1:length(this.outputNames)
                name = sprintf( 'fmin%i', i );
                desc = sprintf( 'Minimum sampled value of output %s', this.outputNames{i} );
                this.minimumProfiler.addColumn(name, desc);
            end
            
            % if we are in pareto mode create a profiler for plotting the pareto trace
            if(this.paretoMode)
                profname = ['gen_pareto_' this.profilerID];
                profname = ProfilerManager.makeUniqueProfilerName(profname);
                this.paretoProfiler = ProfilerManager.getProfiler(profname);
                this.paretoProfiler.setDescription('Pareto search trace');
                
                for i=1:this.numTargets
                    this.paretoProfiler.addColumn(['m' num2str(i)], ['Objective ' num2str(i)]);
                end
                
                this.paretoProfiler.setPreferredChartType(ChartType.SCATTER);
            else
                this.paretoProfiler = [];
            end
            
            % register model observables
            if (this.samplingEnabled)
                this = this.registerObserver('best', 'Number of samples', 'Hyperparameter values for each new best model', getObservables( this.modelFactory ) );
            else
                this = this.registerObserver('best', 'Best model number', 'Hyperparameter values for each new best model', getObservables( this.modelFactory ) );
            end
            
            % Register observables for each model
            observables = getObservables( this.modelFactory );
            this = this.registerObserver('model', 'Model #', ['Hyperparameter optimization process'], observables );
            
            % restart strategy fields
            this.restartStrategy = char(config.self.getOption('restartStrategy','intelligent'));
            this.bestModels = {};
            this.searchHistory = [];
            this.scoreHistory = [];
            this.reliability = [];
            this.rebuildBestModelEffect = [];
            
            % random stuff
            this.keepOldModels = config.context.keepOldModels();
            this.parallelMode = config.context.parallelMode();
            
            this.bestModelId = 0;
            this.bestModelIndex = 1;
            this.modelCounter = 0;
            this.runNumber = 0;
            this.paretoIndex = 1;
            this.levelPlot = [];
            this.startTime = 0;
            this.maximumTime = Inf;
            this.finalTargetsReached = false;
            this.penalty = 1.2;
            this.state = [];
        end %constructor
        
        createMovie(this);
        [scores this scoredModels] = defaultFitnessFunction(this, pop, train);
        [initialPop this] = generateNewModels(this, number, wantModels, previousPop);
        this = observe(this, tag, x_value, object)
        printBestResults(this)
        this = rebuildBestModel(this, keepOldModels)
        this = registerObserver( this, tag, x_name, description, observables );
        this = runLoop( this )
        [this,scores,allMeasureScores,models] = scoreModels(this, models)
        this = setData(this, state)
        model = setModelInfo(this, model, score)
        
        % Description:
        %     This function returns true if all final targets were met...
        function allTargetsReached = done( this )
            allTargetsReached = this.finalTargetsReached;
        end
        
        % Description:
        %     Return the last best model built
        function model = getBestModel(this)
            if isempty(this.bestModels)
                model = [];
            else
                model = this.bestModels{1};
            end
        end
        
        % Description:
        %     Get the Global score of the best model
        function score = getBestModelScore(this)
            if isempty(this.bestModels)
                score = +Inf;
            else
                score = getScore(this.bestModels{1});
            end
        end
        
        %     Return the `n' last best models, optionally filtered for one output
        function models = getBestModels(this, n)
            models = this.bestModels;
            models = models(1:min(n,length(models)));
        end
        
        % Description:
        %     Get current samples en values, i.e. the samples
        %     and values of all simulations ran up till now
        function [samples,values] = getData( this )
            samples = this.state.samples;
            values = this.state.values;
        end
        
        % Description:
        %     Should old models be kept when managing the model trace
        function res = getKeepOldModels(this)
            res = this.keepOldModels;
        end
        
        % Description:
        %     Get the maximum running time
        function time = getMaximumTime(this)
            time = this.maximumTime;
        end
        
        function dir = getOutputDirectory(this)
            dir = this.outputDirectory;
        end
        
        function mf = getModelFactory( this )
            mf = this.modelFactory;
        end
        
        % Description:
        %     Returns the number of objectives the model builder has to deal with (if they are not combined)
        %     This corresponds to the number of enabled measures.
        function n = getNumObjectives(this)
            n = this.numTargets;
        end
        
        function res = getOutputNames(this)
            res = this.outputNames;
        end
        
        function res = getParallelMode(this)
            res = this.parallelMode;
        end
        
        function res = getParetoMode(this)
            res = this.paretoMode;
        end
        
        function res = getRestartStrategy(this)
            res = this.restartStrategy;
        end
        
        function time = getStartTime(this)
            time = this.startTime;
        end
        
        function res = isSamplingEnabled(this)
            res = this.samplingEnabled;
        end
        
        function this = setLevelPlotObject(this, levelObj)
            this.levelPlot = levelObj;
        end
        
        function this = setModelFactory( this, mf )
            this.modelFactory = mf;
        end
        
        function this = setRunNumber( this, number )
            this.runNumber = number;
        end
        
        function this = setStartTime(this,time,maxTime)
            this.startTime = time;
            this.maximumTime = maxTime;
        end
        
    end % public methods
    
    methods(Access = private)
        [this, measureScores, score] = evaluateMeasures(this, model);
        bestModelMeasures = getBestModelMeasures(this);
        [this, isNewBestModel] = orderBestModels(this);
        [this] = processBestModel(this);
        [measureData numTargets] = setupMeasures(logger,config,samplingEnabled);
    end % private methods
    
end % classdef
