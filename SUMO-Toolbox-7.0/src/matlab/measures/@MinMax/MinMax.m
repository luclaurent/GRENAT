classdef MinMax < Measure

% MinMax (SUMO)
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
%	MinMax(config)
%
% Description:
%	This measure enforces the minimum and maximum that is defined for the
%	output. This is a simple but very useful implementation of a simple
%	constraint.

    
    properties(Access = private)
        logger;
        minima;
        maxima;
        complex;
    end
    
    methods(Access = public)
        
        function m = MinMax(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            m = m@Measure(config);
            
            % get minimum/maximum values for all outputs
            outputDimension = config.output.getOutputDimension();
            outputs = config.output.getOutputDescriptions();
            minima = zeros(1,outputDimension);
            maxima = zeros(1,outputDimension);
            complex = zeros(1,outputDimension);
            
            for i = 1 : outputDimension
                minima(i) = outputs(i).getMinimum();
                maxima(i) = outputs(i).getMaximum();
                complex(i) = strcmp(char(outputs(i).getType()), 'complex');
            end
            
            m.minima = minima;
            m.maxima = maxima;
            m.complex = logical(complex);
            m.logger = Logger.getLogger('Matlab.measure.MinMax');
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end

