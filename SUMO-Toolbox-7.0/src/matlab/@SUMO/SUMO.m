classdef SUMO

% SUMO (SUMO)
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
%	SUMO(config)
%
% Description:
%	The main class of the SUMO Toolbox. One instance of this
%	class coordinates the whole metamodelling process. Objects of
%	this type are created through the SUMODriver script

    
    properties(Access = private)
        logger;
        % start time of the toolbox
        startTime;
        % Maximum number of samples
        maximumTotalSamples;
        % Minimum number of samples
        minimumTotalSamples;
        % Maximum number of modeling iterations
        maxModelingIterations;
        % Maximum amount of time (in minutes) to run for
        maximumTime;
        % Stop the main loop if there is a problem with the SE, if false, switch to adaptive modeling mode only
        stopOnError;
        % Sub-objects, set by setObjects
        adaptiveModelBuilder;
        sampleEvaluator;
        % Sample selection related configuration
        sampleSelector;
        averageModellingTime;
        % Initial sample related parameters
        initialDesign;
        minimumAdaptiveSamples;
        minimumInitialSamplesType;
        minimumInitialSamples;
        maximumSamples;
        % check samples against constraints before submitting them to the evaluator
        newSamplesMustSatisfyConstraints;
        % must the entire dataset be used in adaptive modeling mode?
        adaptiveModelingInitialDesignOnly;
        % Simulator related configurations
        dimension;
        outputDimension;
        simulatorDimension;
        simulatorOutputDimension;
        % complex outputs
        flatOutputDimension;
        sampleManager;
        outputNames;
        % create a movie of the model plots
        createMovie;
        % Java logger object
        outputDirectory;
        numSamples;
        %Profilers
        sampleBatchProfiler;
        % keep models from previous modeling iterations
        keepOldModels;
        %Levelplot object
        levelPlot;
    end
    
    methods(Access = public)
        
        function this = SUMO(config)
            
            import java.util.logging.*
            import ibbt.sumo.config.*;
            import ibbt.sumo.profiler.*;
            
            this.logger = Logger.getLogger('Matlab.SUMO');
            
            
            inputConstraints = ConstraintManager(config);
            Singleton('ConstraintManager', inputConstraints );
            
            % Construct the minimumSamples field, either absolute number provided or relative amount
            minS = char(config.self.getOption('minimumInitialSamples','10'));
            
            % if the last character is a % sign then we take the number as a percentage, otherwise take it as an absolute number
            if(minS(end) == '%')
                % percentage
                minimumSamples = str2num(minS(1:end-1));
                minimumSamplesType = 'percentage';
            else
                % absolute value
                minimumSamples = str2num(minS);
                minimumSamplesType = 'count';
            end
            
            % create SampleManager used for filtering outputs from the SampleEvaluator
            sampleManager = SampleManager(config);
            
            %Seed the random number generators
            handleRandomState(config,this.logger);
            
            outputNames = {};
            for i = 0:config.output.getOutputDimension()-1
                outputNames = [outputNames char(config.output.getOutputName(i))];
            end
            
            % initialize the model grid manager as a singleton
            Singleton('ModelGridManager', ModelGridManager(config));
            
            % Do some sanity checking
            maxSamples = str2double(char(config.self.getOption('maximumTotalSamples','1000')));
            minSamples = str2double(char(config.self.getOption('minimumTotalSamples','0')));
            
            newSamplesMustSatisfyConstraints = config.self.getBooleanOption('newSamplesMustSatisfyConstraints', false);
            
            if(maxSamples < 2)
                maxSamples = 1000;
                logger.warning('Invalid value for maxSamples, setting to 1000');
            end
            
            if((minSamples > maxSamples) || (minSamples < 0))
                minSamples = 0;
                logger.warning('Invalid value for minSamples, setting to 0');
            end
            
            maxPendingSamples = str2num(config.self.getOption( 'maximumSamples','10'));
            if(maxPendingSamples < 1)
                maxPendingSamples = 10;
                logger.warning('Invalid value for maximumSamples, setting to 10');
            end
            
            %Construct profilers
            profname = 'SampleBatchSize';
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            this.sampleBatchProfiler = ProfilerManager.getProfiler(profname);
            this.sampleBatchProfiler.setDescription('Size of the batch of samples submitted each sampling iteration');
            this.sampleBatchProfiler.addColumn('batchSize', 'Number of samples in a batch');

            % termination criteria
            this.startTime = 0;
            this.maximumTotalSamples = maxSamples;
            this.minimumTotalSamples = minSamples;
            % maximum number of modeling iterations
            this.maxModelingIterations = str2num(char(config.self.getOption('maxModelingIterations','Inf')));
            % Maximum amount of time (in minutes) to run for
            this.maximumTime = str2double(char(config.self.getOption('maximumTime','120')));
            % Stop the main loop if there is a problem with the SE, if false, switch to adaptive modeling mode only
            this.stopOnError = config.self.getBooleanOption('stopOnError',1);

            % Sample selection related configuration
            this.sampleSelector = [];
            this.averageModellingTime = 0;
            this.sampleManager = sampleManager;
            % check samples against constraints before submitting them to the evaluator
            this.newSamplesMustSatisfyConstraints = config.self.getBooleanOption('s.newSamplesMustSatisfyConstraints', true);
            % must the entire dataset be used in adaptive modeling mode?
            this.adaptiveModelingInitialDesignOnly = config.self.getBooleanOption('adaptiveModelingInitialDesignOnly', false);
            
            % Initial sample related parameters
            this.initialDesign = [];
            this.minimumAdaptiveSamples = config.self.getDoubleOption('minimumAdaptiveSamples',0);
            this.minimumInitialSamplesType = minimumSamplesType;
            this.minimumInitialSamples = minimumSamples;
            this.maximumSamples = maxPendingSamples;
            
            % Simulator related configurations
            this.dimension = config.input.getInputDimension();
            this.outputDimension = config.output.getOutputDimension();
            this.simulatorDimension = config.input.getSimulatorInputDimension();
            this.simulatorOutputDimension = config.output.getSimulatorOutputDimension();
            this.flatOutputDimension = config.output.getSimulatorOutputDimension();
            this.outputNames = outputNames;
            
            % create a movie of the model plots
            this.createMovie = config.self.getBooleanOption('createMovie',0);

            % Java logger object
            this.outputDirectory = char(config.context.getOutputDirectory());
            this.numSamples = 0;

            % keep models from previous modeling iterations
            this.keepOldModels = config.context.keepOldModels();
            
            % Sub-objects, set by setObjects            
            this.adaptiveModelBuilder = [];
            this.sampleEvaluator = [];
            this.levelPlot = [];
        end
        
        [this, bestModel] = runLoop(this, passedSamples, passedValues);
        this = setObjects(this, objects );
        this = stopSampleEvaluator(this);
    end
    
    methods(Access = private)
        [numNewSamples] = calculateNumNewSamples(s);
        [s, newSamples, newValues, newIds] = fetchEvaluatedPoints(s);
        [s] = handleInitialSamples(s);
        [passedSamples passedValues samplesPassed] = handlePassedSamples(s, passedSamples, passedValues);
        handleRandomState(config,logger);
        [s, nSuccesfullyQueued] = queueSamples(s, samples, priorities);
        [s, lastModels, doneBuilding] = runModelingLoop(s, numLoop, nNewSamples);
        [s, nNew] = runSamplingLoop(s, doneBuilding, lastModels, numModelingLoops);
        [s] = setLevelPlotConfig(s);
        s = setObjectsInternal( s, objects, name, stopOnError, perOutput );
    end
    
end

