classdef ParetoModelBuilder < AdaptiveModelBuilder

% ParetoModelBuilder (SUMO)
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
%	ParetoModelBuilder(config)
%
% Description:
%	Uses a Multiobjective GA to select the best model parameters.

    properties(Access = private)
        paretoSaveInterval;
        options;
        population;
        scores;
        logger;
        generationCounter;
        paretoProfiler;
    end
    
    methods(Access = public)
        
        function this = ParetoModelBuilder(config)

            import java.util.logging.*;
            import ibbt.sumo.profiler.*;

            % Construct parent class
            this = this@AdaptiveModelBuilder(config);

            %Generate a default set of options
            options = nsga2optimset;

            %Update GA defaults
            options.PopulationSize = str2num(config.self.getOption('populationSize', '20'));
            options.Generations = config.self.getIntOption('maxGenerations', 20);

            % create a profiler for the pareto front trace
            profilerID = char(config.output.getOutputNamesAsString('_'));
            profname = ['gen_pareto_' profilerID];
            profname = ProfilerManager.makeUniqueProfilerName(profname);
            this.paretoProfiler = ProfilerManager.getProfiler(profname);
            this.paretoProfiler.setDescription('Pareto search trace');

            for i=1:this.getNumObjectives()
                this.paretoProfiler.addColumn(['m' num2str(i)], ['Objective ' num2str(i)]);
            end

            this.paretoProfiler.setPreferredChartType(ChartType.SCATTER);

            this.paretoSaveInterval = config.self.getIntOption('paretoSaveInterval',4);
            this.options = options;
            this.population = [];
            this.scores = [];
            this.logger = Logger.getLogger('Matlab.ParetoModelBuilder');
            this.generationCounter = 1 ;

            % Check if pareto Mode is enabled
            if(~this.getParetoMode())
              error('The paretoMode option must be set to true in order for the ParetoModelBuilder to work');
            end	

            % Register observables per generation
            observables = getBatchObservables( getModelFactory( this ) );
            this = this.registerObserver('gen', 'Generation number', 'Hyperparameter evolution per generation', observables );

            % Register observables per run
            if(this.isSamplingEnabled())
              this = this.registerObserver('run', 'Number of Samples', 'Hyperparameter evolution per adaptive sampling iteration', observables );
            else
              this = this.registerObserver('run', 'ModelBuilder Run', 'Hyperparameter evolution per adaptive modeling iteration', observables );
            end
        end
        
        this = runLoop( this );
        
    end
end
