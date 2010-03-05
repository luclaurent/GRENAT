classdef DifferentialEvolution < Optimizer

% DifferentialEvolution (SUMO)
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
%	DifferentialEvolution(varargin)
%
% Description:
%	Differential Evolution (DE) algorithm

% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		options = struct;
	end
	
	methods

		% constructor
		% Description:
		%     Creates an DifferentialEvolution object
		function this = DifferentialEvolution(varargin)
			% call superclass
			this = this@Optimizer(varargin{:});

			% I_strategy     1 --> DE/rand/1:
			%                      the classical version of DE.
			%                2 --> DE/local-to-best/1:
			%                      a version which has been used by quite a number
			%                      of scientists. Attempts a balance between robustness
			%                      and fast convergence.
			%                3 --> DE/best/1 with jitter:
			%                      taylored for small population sizes and fast convergence.
			%                      Dimensionality should not be too high.
			%                4 --> DE/rand/1 with per-vector-dither:
			%                      Classical DE with dither to become even more robust.
			%                5 --> DE/rand/1 with per-generation-dither:
			%                      Classical DE with dither to become even more robust.
			%                      Choosing F_weight = 0.3 is a good start here.
			%                6 --> DE/rand/1 either-or-algorithm:
			%                      Alternates between differential mutation and three-point-
			%                      recombination.
			
			config = varargin{1};
			
			I_strategy = config.self.getIntOption( 'strategy', 3 );

			options.F_weight     = config.self.getDoubleOption( 'weight', 0.85 ); % DE-stepsize F_weight ex [0, 2]
			options.F_CR         = config.self.getDoubleOption( 'crossover', 1 );% crossover probabililty constant ex [0, 1]
			options.I_D          = this.getInputDimension(); % number of parameters of the objective function 
			options.I_NP         = config.self.getIntOption( 'populationSize', 10.*options.I_D ); % number of population members


			% FVr_minbound,FVr_maxbound   vector of lower and bounds of initial population
			options.FVr_minbound = -1;
			options.FVr_maxbound = 1;
			options.I_bnd_constr = true; % uses FV_*bound as constraints
			options.I_itermax    = config.self.getIntOption( 'maxIterations', 50 ); % maximum number of iterations (generations)
			options.F_VTR        = -Inf; % "Value To Reach" (stop when ofunc < F_VTR)
			options.I_strategy   = I_strategy; % see above
			options.I_refresh    = 0; % no intermediate results
			options.I_plotting   = 0; % no plotting
			
			this.options = options;
		end % ctor
		
		% optimize
		% Description:
		%     This function optimizes the given function handle
		[this, x, fval] = optimize(this, arg )
		
		% getPopulationSize
		% Description:
		%     Get the number of individuals in the population
		size = getPopulationSize(this)
		
	end % methods
	
end % classdef
