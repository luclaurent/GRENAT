classdef GeneticFactory < ModelFactory

% GeneticFactory (SUMO)
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
%	GeneticFactory(config)
%
% Description:
%	Factories that support the Genetic Model Builder must derive from
%	this class
%

    properties(Access = private)
        customMode = false;
        constraintFcn = [];
        creationFcn = [];
        crossoverFcn = [];
        mutationFcn = [];
        constraintFcnStr = [];
        creationFcnStr = [];
        crossoverFcnStr = [];
        mutationFcnStr = [];
    end
    
    methods(Access = public)
        
        function this = GeneticFactory(config)
            import ibbt.sumo.config.*;
            
            this = this@ModelFactory(config);
            
            conFcn = (char(config.self.getOption('constraintFcn','[]')));
            mutFcn = (char(config.self.getOption('mutationFcn','@mutationgaussian')));
            xoFcn = (char(config.self.getOption('crossoverFcn','@crossoverscattered')));
            crFcn = (char(config.self.getOption('creationFcn','@gacreationuniform')));

            this.mutationFcn = mutFcn;	
            this.crossoverFcn = xoFcn;	
            this.creationFcn = crFcn;
            this.constraintFcn = conFcn;
            
            this.mutationFcnStr = mutFcn;	
            this.crossoverFcnStr = xoFcn;	
            this.creationFcnStr = crFcn;
            this.constraintFcnStr = conFcn;
            
            this = wrapFunctions(this);
        end
        
        function res = getConstraintFcn(this)
            res = this.constraintFcn;
        end
        
        function res = getCreationFcn(this)
            res = this.creationFcn;
        end
       
        function res = getCrossoverFcn(this)
            res = this.crossoverFcn;
        end
        
        function res = getMutationFcn(this)
            res = this.mutationFcn;
        end
                
        function res = isCustomMode(this)
            res = this.customMode;
        end
        
        function obs = getBatchObservables(this)
            obs = getBasicBatchObservables(this);
        end
        
        function res = getIndividualSize(this)
            if(this.customMode)
                res = 1;
            else
               [LB UB] = this.getBounds();
               res = length(LB);
            end
		end
		
        function this = setSamples(this,samples,values)
			this = setSamples@ModelFactory(this, samples, values);
			this = wrapFunctions(this);
        end
        
        obs = getBasicBatchObservables( this );
	population = createInitialPopulation(this, GenomeLength, FitnessFcn, options);

        this = wrapFunctions(this);
	end

    methods(Abstract)
	% What is the type of models that this factory generates (returns a string, e.g., 'SVMModel')
        type = getModelType(this);

	% A mutation function
	mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
  
	% A crossover function
	xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused, thisPopulation)
    end
    
end
