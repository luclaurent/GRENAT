classdef AIC < Measure

% AIC (SUMO)
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
% Revision: $Rev: 6402 $
%
% Signature:
%	AIC(config)
%
% Description:
%	Calculates Akaike's information criteria (AIC)

    
    properties(Access = private)
        logger;
        useEvidenceRatios;
    end
    
    methods(Access = public)
        
        function m = AIC(varargin)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            m = m@Measure(varargin{:});
            
			if nargin > 0
				config = varargin{1};
				m.useEvidenceRatios = config.self.getBooleanOption('useEvidenceRatios',false);
			else
				m.useEvidenceRatios = false;
			end
				
            m.logger = Logger.getLogger('Matlab.measure.AIC');
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end
