classdef InterpolationFactory < ModelFactory

% InterpolationFactory (SUMO)
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
%	InterpolationFactory(config)
%
% Description:
%	A very simple class that generates InterpolationModel objects.

    
    properties(Access = private)
        method;
        logger;
    end
    
    methods(Access = public)
        function this = InterpolationFactory(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            % construct the base class
            this = this@ModelFactory(config);
            
            % setup the logger
            this.logger = Logger.getLogger('Matlab.InterpolationFactory');
            
            % get the interpolation method to use from the config
            this. method = char(config.self.getOption('method', 'linear'));
        end
        
        %%% Implement ModelFactory
        function res = supportsComplexData(this)
            res = true;
        end
        
        function res = supportsMultipleOutputs(this)
            res = false;
        end
        
        function [LB UB] = getBounds(this)
            LB = [];
            UB = [];
        end
        
        function models = createInitialModels(this,number,wantModels)
            if(wantModels == false)
                error('InterpolationModelFactory only supports the fixed, base model builder');
            end
            
            %Pre-allocate the models
            models = repmat(InterpolationModel(),number,1);
            
            % Generate the models
            for i=1:number
                models(i) = this.createModel();
            end
        end
        
        % generate a single default model
        function model = createModel(this,parameters)
            model = InterpolationModel(this.method);
        end
        
    end
end
