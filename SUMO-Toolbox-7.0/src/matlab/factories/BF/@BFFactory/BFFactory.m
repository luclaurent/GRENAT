classdef BFFactory < GeneticFactory

% BFFactory (SUMO)
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
%	BFFactory(config)
%
% Description:
%	This class is responsible for generating DACE/RBF models

    properties(Access = private)
        backend;
        type;
		functions;
		regression;
		dimension;
		nparam;
		nfree;
		logger;
    end
    
    methods
        function this = BFFactory(config)
            import java.util.logging.*;

            this = this@GeneticFactory(config);

            logger = Logger.getLogger('Matlab.BFFactory');
	    type = char( config.self.getOption( 'type' ) );

	    switch type
		    case 'RBF'
			    backend = char( config.self.getOption( 'backend', 'Direct' ) );
			    dim = 1;
		    case 'DACE'
			    backend = [];
			    dim = config.input.getInputDimension();
		    otherwise
			    msg = 'Please set type option to either RBF or DACE!';
			    logger.severe( msg );
			    error( msg );
	    end

	    rbfs = config.self.selectNodes( 'BasisFunction' );
	    nBFs = size(rbfs);

	    if nBFs == 0
		    msg = 'No BasisFunction declaration found';
		    logger.severe(msg);
		    error(msg);
	    end

	    for i=1:nBFs
		    node = rbfs.get(i-1);
		    functions(i).name  = char(node.attributeValue( 'name' ));
		    functions(i).func  = rbfFixFunctionName( functions(i).name );
		    functions(i).min   = str2num(char(node.attributeValue( 'min' )));
		    functions(i).max   = str2num(char(node.attributeValue( 'max' )));
		    functions(i).scale = stringSplit(char(node.attributeValue( 'scale' )), ',');
		    functions(i).range = functions(i).max - functions(i).min;
		    
		    assert( ( length(functions(i).min) == length(functions(i).max) ) && ( length(functions(i).min) == length(functions(i).scale) ), ...
			    'Size of the min, max and scale attributes to basis function specification has to be the same' );
		    assert( all( functions(i).min < functions(i).max ), 'Maxima should be larger than minima for basis function parameters' );
	    end

	    override = config.self.getBooleanOption( 'multipleBasisFunctionsAllowed', 1 );

	    if ( length( functions ) ~= 1 )
		if override
		    logger.warning( 'More than one basis function is provided, and override is switched on' );
		    logger.warning( 'Using a discrete extra parameter value to represent the basis function' );
		else
		    logger.severe( 'More than one basis function specified, set multipleBasisFunctionsAllowed to true' );
		    logger.severe( 'to continue, this will add a discrete extra parameter to represent the selected BF' );
		    logger.severe( 'If the number of thetas for the different basis functions differ,' );
		    logger.severe( 'the dimension of the search space will be that of the basis function' );
		    logger.severe( 'with the largest number of parameters, some of which will be ignored' );
		    error( 'More than one basis function present, see log message above for explanation' );
		end
		
		% For each dimension : 1 degree of freedom for the BF, PLUS the maximum
		% of the number of thetas over all basis functions
		% This is an unorthodox way to make the algorithms work on multiple
		% BF's
		% On top of that, the order in which the basis functions are specified
		% might influence the outcome of a run...
		nparam = 0;
		for k=1:length(functions)
		    nparam = max( nparam, 1+length( functions(k).min ) );
		end
	    else
		nparam = length( functions(1).min );
	    end

	    logger.info( sprintf( 'Creating initial models with basis functions %s', stringJoin( {functions.name },' ' ) ) );

	    this.nparam = nparam;  % Maximum number of theta's per percieved `dimension' (d=1 for rbf and d=d for DACE)
	    this.nfree = nparam * dim;  % Number of free parameters
	    this.type = type;
	    this.backend = backend;
	    % function handles
	    this.functions = functions;
	    this.dimension = dim;
	    this.regression = str2num(char(config.self.getOption('regression','-1')));
	    this.logger = logger;
        end

	function res = getDim(this)
	    res = this.dimension;
	end

        function res = getType(this)
            res = this.type;
        end
        
        function res = getBackend(this)
            res = this.backend;
        end
        
        function res = getBasisFunctions(this)
            res = this.functions;
        end
        
        function res = getBasisFunction(this,name)
            res = [];
	    for k=1:length(this.functions )
		    if strcmp( name, this.functions(k).name )
			    res = this.functions(k);
			    break;
		    end
	    end
        end

	function res = getRegression(this)
	    res = this.regression;
	end

	function res = supportsComplexData(this)
	    res = true;
	end

	function res = supportsMultipleOutputs(this)
	    res = false;
	end

	x = scaleIn( s, x, spec );
	x = scaleOut( s, x, spec );
	modelConfig = randomModelParameters( s );
	model = makeModel( s, config );
        obs = getObservables(this);
	[s,model] = createFromHistory(s, history );

	function [LB UB] = getBounds(this)
	  LB = zeros(1,this.nfree);
	  UB = ones(1,this.nfree);   
	end

	function model = createRandomModel(this)
	  model = makeModel( this, randomModelParameters( this ) );
	end

	models = createInitialModels(this,number,wantModels);
	model = createModel(this,parameters);

	%%% Implement GeneticFactory
	function res = getModelType(this)
	    res = iff( strcmp( this.type, 'RBF' ), 'RBFModel', 'DACEModel' );
	end

	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
