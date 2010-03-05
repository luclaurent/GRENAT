classdef LRMMeasure < Measure

% LRMMeasure (SUMO)
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
%	LRMMeasure(varargin)
%
% Description:
%	Return a score based on how much a model approaches a linear fit (the
%	more linear the lower the score)
%	LRM: Linear Reference Model

    
    properties(Access = private)
        logger;
        blockSize;
    end
    
    methods(Access = public)
        
        function this = LRMMeasure(varargin)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            logger = Logger.getLogger('Matlab.measure.LRMMeasure');
            
            if(nargin == 0)
                superArgs = {};
                blockSize = 1000;
            elseif(nargin == 1)
                config = varargin{1};
                
                if (config.output.hasComplexOutputs())
                   error('LRMMeasure does not support complex data directly.');
                end
            
                blockSize = config.self.getIntOption('blockSize',1000);
                inDim = config.input.getInputDimension();
                
                if(inDim > 4)
                    logger.warning('The LRM Measure can become very slow to use for problems with more than 4 dimensions and more than 1500 samples');
                end
                
                superArgs = {config};
            else
                error('Invalid number of arguments given');
            end
            
            this = this@Measure(superArgs{:});
            this.logger = logger;
            this.blockSize = blockSize;
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end
