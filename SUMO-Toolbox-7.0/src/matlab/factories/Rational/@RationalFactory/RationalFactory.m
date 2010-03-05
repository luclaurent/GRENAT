classdef RationalFactory < GeneticFactory

% RationalFactory (SUMO)
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
%	RationalFactory(config)
%
% Description:
%	This class generates Rational models

    properties(Access = private)
        percent;
        frequencyVariable;
	weight;
	maxDegrees;
	baseFunction;
	rational;
	logger;
    end
    
    methods
        function s = RationalFactory(config)
            import java.util.logging.*;

            s = s@GeneticFactory(config);

	    logger = Logger.getLogger('Matlab.RationalFactory');

	    [numIn numOut] = getDimensions(s);

            % Set bounds for variable weights.
	    % These can be one of:
	    %   * Variable not set, use 1..10 as default
	    %   * Two values, use same values for each dimension
	    bounds = str2num( char( config.self.getOption( 'weightBounds', '' ) ) );
	    if ~isempty(bounds)
		    if length(bounds) ~= 2 && length(bounds) ~= 2 * numIn
			    msg = 'Illegal size of weightBounds, either provide 2 or 2*inputDimension';
			    logger.severe(msg);
			    error(msg);
		    end

		    if length(bounds) == 2
			    lb = bounds(1);
			    ub = bounds(2);
		    else
			    lb = bounds(1:2:end);
			    ub = bounds(2:2:end);
		    end

		    if any(lb <= 0) || any(fix(lb) ~= lb) || any(fix(ub) ~= ub)
			    msg = 'Weights should be positive integers';
			    logger.severe(msg);
			    error(msg);
		    end
		    
		    lb = iff(length(lb==1), lb*ones(1,numIn), lb);
		    ub = iff(length(ub==1), ub*ones(1,numIn), ub);
		    
		    if any(lb > ub)
			    msg = '[E] Lower bounds should be less than upper bounds';
			    logger.severe(msg);
			    error(msg);
		    end
		    
		    s.weight = struct('lower', lb, 'upper', ub);
	    else
		    s.weight = struct('lower', dfix(1, numIn), 'upper', dfix(10, numIn));
		    logger.warning('Weight bounds not found, using defaults');
	    end

	    % Set percentbounds, bounds for the ratio degrees 
	    % of freedom over number of samples.
	    % Two values between 0 and 100.
	    bounds = str2num(char(config.self.getOption('percentBounds', '' )));
	    if isempty(bounds)
		    lb = 80;
		    ub = 100;
	    elseif length(bounds) == 2
		    lb = bounds(1);
		    ub = bounds(2);
	    else
		    msg = 'Percent bounds should be two comma separated integers';
		    logger.severe(msg);
		    error(msg);
	    end

	    assert(all([length(lb) length(ub)] == 1), '[E] Percent bounds invalid');
	    assert(lb <= ub, '[E] Lower bound should be less than upper bound');

	    s.percent = struct( ...
		    'lower', lb, ...
		    'upper', ub ...
	    );

	    % Never use more than this many degrees of freedom
	    s.maxDegrees = config.self.getIntOption('maxDegrees', 100 );

	    % Set the chance that a variable will get a
	    % rational flag with value 0, see rational
	    % class doc for a description of the rational
	    % flag.
	    b = str2num(char(config.self.getOption('percentRational', '')));
	    if ~isempty(b)
		    if any(b < 0) || any(b > 100)
			    error('[E] Percentrational should be between 0 and 100');
		    end
		    
		    s.rational = dfix(b, numIn, '[E] Percentrational should be either scalar or of length numIn' );
	    else
		    s.rational = dfix(50, numIn);
		    logger.warning('Flag percentage not found, using 50 as default');
	    end

	    % Set the frequency variable. When this is set, models are built 
	    % using real unknowns, the frequency variable is treated as
	    % a complex frequency s = j * f to accomodate complex outputs.
	    % This is only used for modelling physical (EM) simulators
	    fv = config.self.getOption( 'frequencyVariable', '0' );
	    fvindex = 0;
	    fvauto = 0;
	    for i=1:numIn
		    iname = config.input.getInputName(i-1);
		    if strcmpi( iname, fv )
			    fvindex = i;
		    elseif strcmpi( iname, 'f' ) || strcmpi( iname, 'freq' ) || strcmpi( iname, 'frequency' )
			    fvauto = i;
		    end
	    end

	    if strcmpi( fv, 'auto' )
		    fv = fvauto;
	    elseif fvindex > 0
		    fv = fvindex;
	    elseif (str2num(fv) > 0) & (str2num(fv) <= numIn)
		    fv = str2num(fv);
	    else
		    fv = 0;
	    end
	    s.frequencyVariable = fv;
	    logger.fine( sprintf( 'Frequency variable setting : %s', iff( fv == 0, 'disabled', num2str(fv) ) ) );

	    % Get the basis functions to use in the model construction process.
	    bf = config.self.getOption( 'basis' );
	    if strcmp( bf, 'power' ) || strcmp( bf, 'chebyshev' ) || strcmp( bf, 'legendre' )
		    s.baseFunction = str2func( [ char(bf) 'Base' ] );
	    else
		    logger.warning( 'Unknown basis function, using Chebyshev base' );
		    s.baseFunction = @chebyshevBase;
	    end

	    s.logger = logger;
        end

        function res = getPercentBounds(this)
            res = this.percent;
        end
        
        function res = getFrequencyVariable(this)
            res = this.frequencyVariable;
        end
        
        function res = getWeights(this)
            res = this.weights;
        end
        
        function res = getMaxDegrees(this)
            res = this.maxDegrees;
        end

        function res = getBaseFunction(this)
            res = this.baseFunction;
        end

        function res = getRational(this)
            res = this.rational;
        end

	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	    res = true;
	end

	function res = supportsMultipleOutputs(this)
	  res = true;
	end

        function [LB UB] = getBounds(this)
	    [smp val] = getSamples(this);
	    [ni no] = getDimensions(this);

	    weightBounds = this.weight;
	    percentBounds = this.percent;

	    % Whats the maximum percentage we can set so that we do not exceed the maximum absolute bound
	    maxPerc = (this.maxDegrees / size(smp,1)) * 100;

	    % enforce the maximum
	    percentBounds.upper = min(percentBounds.upper, maxPerc);

	    LB = [percentBounds.lower weightBounds.lower zeros(1,ni) ];
	    UB = [percentBounds.upper weightBounds.upper ones(1,ni) ];
	end
        
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        model = createRandomModel(this);
        obs = getObservables(this);
	[this,model] = createFromHistory(this, history);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = 'RationalModel';
        end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
