classdef SequentialModelBuilder < AdaptiveModelBuilder

% SequentialModelBuilder (SUMO)
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
%	SequentialModelBuilder(config)
%
% Description:
%	Adaptive model builder subclass that builds models sequentially
%	Each new set of model parameters should be selected based on
%	the history of good model parameters provided.

    properties(Access = private)
        historySize;
        decay;
        runLength;
        maximumRunLength;
        strategy;
        history;
        logger;
    end
    
    methods(Access = public)
       function this = SequentialModelBuilder(config)
            import java.util.logging.*
            import ibbt.sumo.profiler.*

            this = this@AdaptiveModelBuilder(config);
            
            if(getParetoMode(this))
                error('The sequential model builder does not support pareto mode, please turn it off');
            end
            
            this.historySize = config.self.getIntOption('historySize',10);
            this.decay = config.self.getDoubleOption('decay', 0.99);
            this.runLength = 0;
            this.maximumRunLength = config.self.getIntOption('maximumRunLength',20);
            this.strategy = char(config.self.getOption('strategy', 'best'));
            this.history = struct('models', [], 'scores', [], 'runLength', 0);
            this.logger = Logger.getLogger('Matlab.SequentialModelBuilder');
       end
       
       function rl = getRunLength(this)
           rl = this.runLength;
       end
       
       this = runloop(this);
       
    end
end
