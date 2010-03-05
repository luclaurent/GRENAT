classdef ModelFactory

% ModelFactory (SUMO)
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
%	ModelFactory(config)
%
% Description:
%	Base class for all model factories
%

    properties(Access = private)
        samples = [];
        values = [];
        numInputs = -1;
        numOutputs = -1;
        parallelMode = false;
	mode = 'regression';
    end
    
    methods(Access = public)
        
        function this = ModelFactory(config)
            this.numInputs = config.input.getInputDimension();
            this.numOutputs = config.output.getOutputDimension();
            this.parallelMode = config.context.parallelMode();
            
	    % are we in regression or classification mode
	    this.mode = char(config.self.getOption('mode','regression'));
	    if(strcmp(this.mode,'regression') || strcmp(this.mode,'classification'))
	    	% all ok
	    else
	    	error(sprintf('Invalid mode %s given, must be either "regression" or "classification"',this.mode));
	    end
	    
            % Can we deal with complex data directly?
            if (config.output.hasComplexOutputs() && ~this.supportsComplexData())
                msg = sprintf('ComplexHandling must be set to real, imaginary, split, or modulus for %s to work',class(this));
                error(msg);
            end
            
            % Are models with multiple outputs supported?
            if (this.numOutputs > 1 && ~this.supportsMultipleOutputs())
                msg = sprintf('Sorry, %s does not support models with multiple outputs, please set combineOutputs to false',class(this));
                error(msg);
            end
            
        end
        
        function this = setSamples(this,samples,values)
            this.samples = samples;
            this.values = values;
        end
        
        function [s v] = getSamples(this)
            s = this.samples;
            v = this.values;
        end
        
        function [ni no] = getDimensions(this)
            ni = this.numInputs;
            no = this.numOutputs;
        end
        
        function model = createRandomModel(this)
            error('The createRandomModel function must be overridden in the derived class');
        end
        
        function obs = getObservables(this)
            obs = [];
        end
        
        function res = getParallelMode(this)
            res = this.parallelMode;
        end
	
	function res = getMode(this)
            res = this.mode;
        end
	
        % Generate 'number' models, if wantModels=true they should be model objects, else
        % a matrix should be returned with each row containing the parameters of one model
	% This method should internally use createModel(..) where possible.
        function models = createInitialModels(this,number,wantModels)
		error('The createInitialModels function must be overridden in the derived class');
	end
        
        % Return the lower bounds and upper bounds (each a row vector) for each model parameter
        function [LB UB] = getBounds(this)
		error('The getBounds function must be overridden in the derived class');
	end
    end
    
    
    methods(Abstract)
        % Create a model object represented by the given parameters.
        % The following calling signatures should be supported:
	%  - no parameters are passed: return a default model as defined by the config
	%  - parameters is a double vector: return a model with the hyperparameters set to the passed values
	%  - parameters is a model object: do nothing, simply return the passed object
        model = createModel(this,parameters);
        
        % Return true if this factory can generate models that can work on complex data directly
        res = supportsComplexData(this);
        
        % Return true if this factory can generate models with multiple outputs
        res = supportsMultipleOutputs(this);
    end
    
end
