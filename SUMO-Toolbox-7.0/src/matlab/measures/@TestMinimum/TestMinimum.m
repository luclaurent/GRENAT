classdef TestMinimum < Measure

% TestMinimum (SUMO)
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
%	TestMinimum(config)
%
% Description:
%	This measure is used for validition purpose of the optimization framework
%	 The true minimum (function value!) is compared to the current minimum found according
%	 to some type of measure. Currently:
%	 1. Euclidean distance

    
    properties(Access = private)
        logger;
        trueValue;
    end
    
    methods(Access = public)
        
        function m = TestMinimum(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            m = m@Measure(config);
            
            m.trueValue = str2double(config.self.getAttrValue('trueValue', '0'));
            m.logger = Logger.getLogger('Matlab.measure.TestMinimum');
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end


