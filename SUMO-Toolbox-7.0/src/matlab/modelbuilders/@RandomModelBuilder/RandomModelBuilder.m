classdef RandomModelBuilder < AdaptiveModelBuilder

% RandomModelBuilder (SUMO)
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
%	RandomModelBuilder(config)
%
% Description:
%	Generate random models, usefull as a baseline benchmark

    properties(Access = private)
        runSize;
        logger;
    end
    
    methods(Access = public)
       
        function this = RandomModelBuilder(config)
            
            % construct base class
            this = this@AdaptiveModelBuilder(config);
            
            import java.util.logging.*
            import ibbt.sumo.profiler.*

            this.runSize = config.self.getIntOption('runSize',10);
            this.logger = Logger.getLogger('Matlab.RandomModelBuilder');
        end
        
        this = runLoop( this );
        
    end
    
end
