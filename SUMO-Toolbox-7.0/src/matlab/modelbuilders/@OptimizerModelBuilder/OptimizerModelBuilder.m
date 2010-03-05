classdef OptimizerModelBuilder < AdaptiveModelBuilder

% OptimizerModelBuilder (SUMO)
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
%	OptimizerModelBuilder(config)
%
% Description:
%	Optimizes the model parameters using one the Optimizers available in src/matalb/tools/Optimizers
%	Which optimizer to use can be defined in the xml config

    properties(Access = private)
        optimizer;
        logger;
        initialPopulation;
    end
    
    methods(Access = public)
        function this = OptimizerModelBuilder(config)
            import java.util.logging.*;
        
            this = this@AdaptiveModelBuilder(config);
        
            optconfig = config.self.selectSingleNode('Optimizer');
            if(isempty(optconfig))
                error('You must define an <Optimizer> tag in OptimizerModelBuilder');
            end
            
            this.optimizer = instantiate(optconfig, config);
            this.logger = Logger.getLogger('Matlab.OptimizerModelBuilder');
            this.initialPopulation = [];
        end
        
        this = runloop(this);
        
    end
end

