classdef SplineFactory < GeneticFactory

% SplineFactory (SUMO)
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
%	SplineFactory(config)
%
% Description:
%	This class is responsible for generating Smoothing Spline models (1D and 2D only), based on the Matlab
%	splines toolbox

    properties(Access = private)
        smoothingBounds;
	logger;
    end
    
    methods
        function this = SplineFactory(config)
            import java.util.logging.*;
	    import ibbt.sumo.config.*;

            this = this@GeneticFactory(config);

            this.logger = Logger.getLogger('Matlab.SplineFactory');

	    v = ver('splines');
	    if(isempty(v))
	      error('In order to use the Spline models you must have the Matlab Spline Toolbox installed')
	    end

	    %% Smoothing Parameter
	    smoothBounds = str2num(char(config.self.getOption('smoothingBounds', '0,1')));

	    % checks
	    if length(smoothBounds) ~= 2
		    msg = 'Illegal size of smoothBounds';
		    error(msg);
	    end

	    lb = smoothBounds(1);
	    ub = smoothBounds(2);

	    % more checks
	    if (lb < 0)
		    msg = 'Lower smoothing bound must be >= 0';
		    error(msg);
	    end
		    
	    if lb >= ub
		    msg = 'Lower smoothing bound should be less than upper smoothing bound';
		    error(msg);
	    end
	    this.smoothingBounds = [lb ub];
        end

	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	    res = false;
	end

	function res = supportsMultipleOutputs(this)
	  res = false;
	end

        function [LB UB] = getBounds(this)
	    LB = this.smoothingBounds(1);
	    UB = this.smoothingBounds(2);
	end

	function model = createRandomModel(this)
	    sm = boundedRand(this.smoothingBounds(1),this.smoothingBounds(2));
	    model = this.createModel(sm);
	end
        
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'SplineModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
