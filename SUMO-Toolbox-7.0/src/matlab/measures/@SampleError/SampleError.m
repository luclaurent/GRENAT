classdef SampleError < Measure

% SampleError (SUMO)
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
%	SampleError(config)
%
% Description:
%	This measure simply compares the values of the model at the locations
%	of all the samples used for constructing it with the actual values of
%	these samples.

    
    properties(Access = private)
        logger;
    end
    
    methods(Access = public)
        
        function m = SampleError(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            m = m@Measure(config);
            
            m.logger = Logger.getLogger('Matlab.measure.SampleError');
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end

