classdef HeterogeneousFactory < GeneticFactory

% HeterogeneousFactory (SUMO)
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
%	HeterogeneousFactory(config)
%
% Description:
%	This is a meta-Factory that wraps other factories as part of the heterogeneous evolution for model type selection.

    properties(Access = private)
        modelInterfaces;
	logger;
    end
    
    methods
        function this = HeterogeneousFactory(config)
            import java.util.logging.*;

            this = this@GeneticFactory(config);

	    this.logger = Logger.getLogger('Matlab.HeterogeneousFactory');
   
            %Create all the nestes modelinterfaces
	    this.logger.fine('Creating HeterogeneousGeneticModelbuilder');
	    nodes = config.self.selectNodes( 'ModelFactory' );

	    if(isempty(nodes) || nodes.size() < 1)
	      error('You must specify at least one ModelFactory inside the heterogenetic model builder');
	    end

	    mi = cell(1,nodes.size());
	    for i=0:nodes.size()-1
		    tmp = instantiate( nodes.get(i), config );
		    mi{1,i+1} = tmp;
		    this.logger.fine(sprintf('Added model interface %s',class(tmp)));
	    end
  
	    this.modelInterfaces = mi;
     end

        group = groupModels(this,indices,population);
        
        function res = getModelFactories(this)
            res = this.modelInterfaces;
        end
        
	%%% Implement ModelFactory
	function res = supportsComplexData(this)
	    for i=1:length(this.modelInterfaces)
	      if(~supportsComplexData(this.modelInterfaces{i}))
		res = false;
		return;
	      end
	    end
	    res = true;
	end

	function res = supportsMultipleOutputs(this)
	    for i=1:length(this.modelInterfaces)
	      if(~supportsMultipleOutputs(this.modelInterfaces{i}))
		res = false;
		return;
	      end
	    end
	    res = true;
	end

        function [LB UB] = getBounds(this)
	    LB = [];
	    UB = [];  
	end
        
        function models = createInitialModels(this,number,wantModels)
	    models = [];
	end

        model = createModel(this,parameters);
        obs = getObservables(this);

	%%% Implement GeneticFactory
	function res = getModelType(this)
            res = '';
        end
	
	obs = getBatchObservables(this);
	population = createInitialPopulation(s,GenomeLength, FitnessFcn, options);
	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
