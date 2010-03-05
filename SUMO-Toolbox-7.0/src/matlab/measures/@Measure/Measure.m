classdef Measure

% Measure (SUMO)
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
%	Measure(varargin)
%
% Description:
%	Abstract base class for a measure.
%	Handles some of the configuration valid for all measures,
%	such as the error function and the target

    
    properties(Access = private)
        errorFcn = '';
        target = 0;
        weight = 1;
        enabled = true;
        parallelMode = false;
        logger = java.util.logging.Logger.getLogger('Matlab.measure.Measure');
    end
    
    methods(Access = public)
        
        function this = Measure(varargin)
            import java.util.logging.*
            
            if nargin == 1
                config = varargin{1};
                
                %The default error function is the root relative squared error
                errorFcn = str2func(char(config.self.getAttrValue('errorFcn','rootRelativeSquareError')));
                
                % get attributes
                % IT IS IMPORTANT THAT THE DEFAULT TARGET IS 0 !!
                % SINCE OTHERWISE TARGETS MAY BE REACHED TOO SOON (e.g.,
                % MinMax gives score of 0 but target is 0.01, see ProcessBestModel)
                target = str2double(config.self.getAttrValue('target', '0'));
                weight = config.self.getDoubleAttrValue('weight', '1.0');
                use = config.self.getBooleanAttrValue('use', 'on');
                
                parallelMode = config.context.parallelMode();
            else
                % TODO: get it from varargin...
                errorFcn = @rootRelativeSquareError;
                target  = 0.01;
                use = false;
                parallelMode = false;
                weight = 1;
            end
            
            this.logger.fine(sprintf('Measure configured with error function %s and weight %d',func2str(errorFcn),weight));
            
            this.errorFcn = errorFcn;
            this.target = target;
            this.weight = weight;
            this.enabled = use;
            this.parallelMode = parallelMode;
        end
        
        function this = setErrorFcn(this,efun)
            this.errorFcn = str2func(efun);
        end
        
        function fcn = getErrorFcn(this)
            fcn = this.errorFcn;
        end
        
        function res = getFinalTarget(this)
            res = this.target;
        end
        
        function res = getParallelMode(this)
            res = this.parallelMode;
        end
        
        function res = getWeight(this)
            res = this.weight;
        end
        
        function res = isEnabled(this)
            res = this.enabled;
        end
        
        function targets = getTarget(m)
            targets = m.target;
        end
        
        [m, scores] = processMeasure(m, model, context, outputIndex);
    end
    
    methods(Access = public, Abstract = true)
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end
