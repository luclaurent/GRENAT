classdef GeneticModelBuilder < AdaptiveModelBuilder

% GeneticModelBuilder (SUMO)
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
%	GeneticModelBuilder(config)
%
% Description:
%	Uses a Genetic Algorithm (GA) to select the best model parameters.
%	Requires the Matlab Direct Search Toolbox

    properties(Access = private)
        logger;
        extPrev;
        minTypeCount;
        paretoSaveInterval;
        options;
        population;
        scores;
        state;
        varianceProfiler;
        distanceProfiler;
        generationCounter;
        outputDir;
        nrMeasures;
    end
    
    methods(Access = public)
        
        function this = GeneticModelBuilder(config)

            import java.util.logging.*;
            import ibbt.sumo.profiler.*;

            this = this@AdaptiveModelBuilder(config);
            
            this.logger = Logger.getLogger('Matlab.GeneticModelBuilder');

            % Check if we are doing multiobjective optimization
            this.nrMeasures = this.getNumObjectives();
            paretoMode = this.getParetoMode();

            %Generate a default set of options
            options = gaoptimset(@ga);

            %Update GA defaults
            popType = char(config.self.getOption('populationType','doubleVector'));
            options = gaoptimset(options, 'PopulationType',		popType);
            options = gaoptimset(options, 'PopulationSize',		str2num(config.self.getOption('populationSize', '20')));
            options = gaoptimset(options, 'Generations',		config.self.getIntOption('maxGenerations', 20));
            options = gaoptimset(options, 'CrossoverFraction',	config.self.getDoubleOption('crossoverFraction',0.8));
            options = gaoptimset(options, 'StallGenLimit',		config.self.getIntOption('stallGenLimit',5));
            options = gaoptimset(options, 'StallTimeLimit',		str2num(config.self.getOption('stallTimeLimit','Inf')));
            options = gaoptimset(options, 'TolFun',             str2num(config.self.getOption('functionTolerance','1e-6')));
            options = gaoptimset(options, 'EliteCount',         config.self.getIntOption('eliteCount',2));
            options = gaoptimset(options, 'CreationFcn',		getCreationFcn(this.getModelFactory()));
            options = gaoptimset(options, 'CrossoverFcn',		getCrossoverFcn(this.getModelFactory()));
            options = gaoptimset(options, 'MutationFcn',		getMutationFcn(this.getModelFactory()));
            options = gaoptimset(options, 'FitnessScalingFcn', 	@fitscalingprop );

            % in the multi objective case only tournament selection is supported
            if(paretoMode)
                options = gaoptimset(options, 'SelectionFcn',		eval(char(config.self.getOption('selectionFcn','@selectiontournament'))));
                %options = gaoptimset(options, 'ParetoFraction',		eval(char(config.self.getOption('paretoFraction','1'))));
            else
                options = gaoptimset(options, 'SelectionFcn',		eval(char(config.self.getOption('selectionFcn','@selectionstochunif'))));
            end

            options = gaoptimset(options, 'MigrationDirection',	char(config.self.getOption('migrationDirection','both')));
            options = gaoptimset(options, 'MigrationInterval',	config.self.getIntOption('migrationInterval',5));
            options = gaoptimset(options, 'MigrationFraction',	config.self.getDoubleOption('migrationFraction',0.1));

            hybridFcns = char(config.self.getOption('hybridFunction',''));
            if(~isempty(hybridFcns))
                options = gaoptimset(options, 'HybridFcn',	eval(hybridFcns));
            end

            plotFcns = char(config.self.getOption('plotFunctions',''));
            %plotFcns = char(config.self.getOption('plotFunctions','{@gaplotbestf,@gaplotrange}'));
            if(~isempty(plotFcns))
                options = gaoptimset(options, 'PlotFcns',		eval(plotFcns));
            end
            options = gaoptimset(options, 'Vectorize',			'on');

            %Dont show any output
            options = gaoptimset(options,'Display','off');

            % What is the population type
            customPopType = strcmp(gaoptimget(options,'PopulationType'),'custom');

            %create a profiler for tracking the population variance
            profilerID = char(config.output.getOutputNamesAsString('_'));
            profname = ['gen_variance_' profilerID];
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            varianceProfiler = ProfilerManager.getProfiler(profname);
            varianceProfiler.setDescription('Fitness variance per generation');
            varianceProfiler.addColumn('generation', 'Generation');
            if(paretoMode)
                for i=1:this.nrMeasures
                    varianceProfiler.addColumn(['variance_' i], ['Variance of measure ' i]);
                end
            else
                varianceProfiler.addColumn('variance', 'Population fitness variance');
            end

            %create a profiler for tracking the average distance between individuals
            if(~customPopType)
                profname = ['gen_dist_' profilerID];
                profname = ProfilerManager.makeUniqueProfilerName(profname);
                distanceProfiler = ProfilerManager.getProfiler(profname);
                distanceProfiler.setDescription('Average distance between individuals');
                distanceProfiler.addColumn('generation', 'Generation');
                distanceProfiler.addColumn('dist', 'Average distance');
            else
                distanceProfiler = [];
            end

            this.extPrev = config.self.getBooleanOption('extinctionPrevention',0);
            this.minTypeCount = config.self.getIntOption('minTypeCount',2);
            this.paretoSaveInterval = config.self.getIntOption('paretoSaveInterval',4);
            this.options = options;
            this.population = {};
            this.scores = [];
            this.state = [];
            this.varianceProfiler = varianceProfiler;
            this.distanceProfiler = distanceProfiler;
            this.generationCounter = 1;

            % Does the population type declared match the genetic operator type
            customOps = isCustomMode( this.getModelFactory());

            if(strcmp(popType,'custom') && ~customOps)
                error('The population type is set to custom but the genetic operators do not refer to member functions of the Genetic interface object.  You probably should set the population type to doubleVector');
            elseif(strcmp(popType,'doubleVector') && customOps)
                error('The population type is set to doubleVector but the genetic operators do not refer to standalone matlab functions (they dont start with an @).  You probably should set the population type to custom');
            else
                % all should be ok
            end

            % Register observables per generation
            observables = getBatchObservables( this.getModelFactory() );
            this = this.registerObserver('gen', 'Generation number', 'Hyperparameter evolution per generation', observables );

            % Register observables per run
            if(this.isSamplingEnabled())
              this = this.registerObserver('run', 'Number of samples', 'Hyperparameter evolution per adaptive sampling iteration', observables );
            else
              this = this.registerObserver('run', 'ModelBuilder Run', 'Hyperparameter evolution per adaptive modeling iteration', observables );
            end
        end % end constructor
        
        this = runLoop( this );
                
    end % end public methods
    
    methods(Access = private)
        [newPop newScores] = extinctionPrevention(this, sz,prevPop, prevScores, curPop, curScores, minCount);
    end
    
end % end classdef
