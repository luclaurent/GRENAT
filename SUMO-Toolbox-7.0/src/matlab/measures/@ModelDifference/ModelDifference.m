classdef ModelDifference < Measure

% ModelDifference (SUMO)
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
%	ModelDifference(config)
%
% Description:
%	Estimate the accuracy of the model by comparing it with all the other
%	models and assuming that, when models are similar, the algorithm is
%	converging to a stable model, which should be the correct one.

    
    properties(Access = private)
        logger;
        sampleGenerator;
        sampleGeneratorParameters;
    end
    
    methods(Access = public)
        
        function m = ModelDifference(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            m = m@Measure(config);
            
            % Get options
            grid = config.self.getIntOption('grid', -1);
            lhs = config.self.getIntOption('LHS', -1);
            
            if grid * lhs >= 0
                grid = 50;
                %logger.severe('Please specify either the grid or the LHS option, and provide positive sizes');
                %error('Parameter error');
            end
            
            % cap grid size for efficiency reasons
            maxGridSize = config.self.getIntOption('maxGridSize', 100000);
            maxGrid = floor(maxGridSize ^ (1/config.input.getInputDimension()));
            grid = min(grid, maxGrid);
            
            if grid > 0
                sgp = {grid, config.input.getInputDimension()};
                sg = @makePerturbedGrid;
            else
                sgp = {config.input.getInputDimension(),grid^config.input.getInputDimension()};
                sg = @latinHypercubeSample;
            end
            
            m.sampleGenerator = sg;
            m.sampleGeneratorParameters = sgp;
            m.logger = Logger.getLogger('Matlab.measure.ModelDifference');
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end


