classdef CMAESOptimizer < Optimizer

% CMAESOptimizer (SUMO)
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
%	CMAESOptimizer(config)
%
% Description:
%	Wrapper around the CMA-ES optimization algorithm

	
	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		opts;
		sigma;
	end
	
	methods
		
		% constructor
		% Description:
		%     Creates an PSOtOptimizer object
		function this = CMAESOptimizer(config)
			import cmaes.*;
			
			% call superclass
			this = this@Optimizer(config);
			
			% start with defaults
			opts = cmaes('defaults');

			opts.Display = 'off';
			opts.Plotting = 'off';
			opts.Saving = 'off';
			opts.VerboseModulo = '0';

			opts.MaxFunEvals 	= char(config.self.getOption('maxFunEvals',opts.MaxFunEvals));
			opts.StopFitness 	= char(config.self.getOption('stopFitness',opts.StopFitness));
			opts.MaxIter 		= char(config.self.getOption('maxIterations',opts.MaxIter));
			opts.TolFun 		= char(config.self.getOption('tolFun',opts.TolFun));

			this.opts = opts;
			this.sigma = config.self.getDoubleOption('sigma',-1);
		end % constructor
		
		% optimize
		% Description:
		%     This function optimizes the given function handle
		[this, x, fval] = optimize(this, arg )
		
	end % methods
end
