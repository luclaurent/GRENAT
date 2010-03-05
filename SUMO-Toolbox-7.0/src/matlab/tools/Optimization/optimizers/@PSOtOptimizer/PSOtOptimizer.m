classdef PSOtOptimizer < Optimizer

% PSOtOptimizer (SUMO)
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
%	PSOtOptimizer(varargin)
%
% Description:
%	Wrapper around the PSOt library (Particle Swarm Optimization)

	
	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		mv = 4;
		plotFuncs;
		PSOParams = [0 200 24 2 2 0.9 0.4 150 1e-25 150 NaN 0 0];
	end
	
	methods
		
		% constructor
		% Description:
		%     Creates an PSOtOptimizer object
		function this = PSOtOptimizer(varargin)
			% call superclass
			this = this@Optimizer(varargin{:});
			
			% GENETIC ALGORITHM
			opts = ga('defaults');

			% default case
			if(nargin == 1)
				config = varargin{1};
			
				PSOParams(1) = 0; % P(1) - Epochs between updating display, default = 100. if 0 no display
				PSOParams(2) = config.self.getIntOption( 'maxiters', 200 ); % P(2) - Maximum number of iterations (epochs) to train, default = 200.
				PSOParams(3) = config.self.getIntOption( 'popSize', 24 ); % P(3) - population size, default = 24
				PSOParams(4) = config.self.getIntOption( 'acc_const1', 2 ); % P(4) - acceleration const 1 (local best influence), default = 2
				PSOParams(5) = config.self.getIntOption( 'acc_const2', 2 ); % P(5) - acceleration const 2 (global best influence), default = 2
				PSOParams(6) = config.self.getDoubleOption( 'initialInertiaWeight', 0.9 ); % P(6) - Initial inertia weight, default = 0.9
				PSOParams(7) = config.self.getDoubleOption( 'finalIntertiaWeight', 0.4 ); % P(7) - Final inertia weight, default = 0.4
				PSOParams(8) = config.self.getIntOption( 'epochIntertia', 150 ); % P(8) - Epoch when inertial weight at final value, default = 150

				%      P(9)- minimum global error gradient, 
				%                 if abs(Gbest(i+1)-Gbest(i)) < gradient over 
				%                 certain length of epochs, terminate run, default = 1e-25
				PSOParams(9) = config.self.getDoubleOption( 'minGlobalError', 1e-25 );


				%      P(10)- epochs before error gradient criterion terminates run, 
				%                 default = 150, if the SSE does not change over 250 epochs
				PSOParams(10) = config.self.getIntOption( 'gradientTermination', 150 );


				PSOParams(11) = config.self.getDoubleOption( 'errorGoal', NaN ); % P(11)- error goal, if NaN then unconstrained min or max, default=NaN

				%      P(12)- type flag (which kind of PSO to use)
				%                 0 = Common PSO w/intertia (default)
				%                 1,2 = Trelea types 1,2
				%                 3   = Clerc's Constricted PSO, Type 1"
				PSOParams(12) = config.self.getIntOption( 'typePSO', 0 );


				%      P(13)- PSOseed, default=0
				%               = 0 for initial positions all random
				%               = 1 for initial particles as user input
				PSOParams(13) = config.self.getIntOption( 'seedPSO', 0 );
				
				this.PSOParams = PSOParams;

				this.mv = config.self.getIntOption( 'mv', 4 ); % FIXME: can be specified as a vector too
			% custom constructors
			elseif(nargin == 2)
				% no options, take defaults (only options are for base class
			elseif(nargin == 3)
				%First 2 are parsed by base class
				%nvar = varargin{1};
				%nobj = varargin{2};
			else
				error('Invalid number of arguments given');    
			end
			
			this.plotFuncs = [];
			
		end

		% optimize
		% Description:
		%     This function optimizes the given function handle
		[this, x, fval] = optimize(this, arg )
		
		% getPopulationSize
		% Description:
		%     Get the number of individuals in the population
		size = getPopulationSize(this)

		
	end
	
end
