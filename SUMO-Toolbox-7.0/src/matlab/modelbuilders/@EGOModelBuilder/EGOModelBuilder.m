classdef EGOModelBuilder < AdaptiveModelBuilder

% EGOModelBuilder (SUMO)
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
%	EGOModelBuilder(config)
%
% Description:
%	Uses the EGO algorithm to optimize in hyperparameter space

    properties(Access = private)
        logger;
        egoSS;
        initialPop;
        initialScores;
        numIterations;
        maxPoints;
        initPopSize;
		
		modelOptimizer = [];
    end
    
    methods(Access = public)
        
        function this = EGOModelBuilder(config)
            import java.util.logging.*;
            import ibbt.sumo.profiler.*;

            % Create parent class
            this = this@AdaptiveModelBuilder(config);
			
			% Get the kriging model optimizer
			optconfig = config.self.selectSingleNode('Optimizer');
            if(isempty(optconfig))
                error('You must define an <Optimizer> tag in EGOModelBuilder');
            end
            
            this.modelOptimizer = instantiate(optconfig, config);

            % Get the EGO sample selector to use
            egoSS = config.self.selectSingleNode('SampleSelector');
            this.egoSS = instantiate(egoSS, config);

            this.logger = Logger.getLogger('Matlab.EGOModelBuilder');
            this.initialPop = [];
            this.initialScores = [];
            this.numIterations = config.self.getIntOption('numIterations',10);
            this.maxPoints = config.self.getIntOption('maxPoints',200);
            this.initPopSize = config.self.getIntOption('initPopSize',5);

            if(this.maxPoints < 20)
                error('maxPoints should be at least 20');
            end
            
            if( ~strcmp(this.getRestartStrategy(),'continue') )
                msg = 'The EGOModelBuilder can only be used with restart strategy continue';
                this.logger.severe(msg);
                error(msg);
            end
        end
        
        this = runLoop( this );
        
    end
    
end

