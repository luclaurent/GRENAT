classdef MatlabOptimizer < Optimizer

% MatlabOptimizer (SUMO)
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
%	MatlabOptimizer(varargin)
%
% Description:
%	Wrapper around the matlab optimizers

	
	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		opts;
		Aineq;
		Bineq;
		nonlcon;
	end
	
	methods

		% constructor
		% Description:
		%     Creates an MatlabOptimizer object
		function this = MatlabOptimizer(varargin)
			% call superclass
			this = this@Optimizer(varargin{:});
			
            % FMINUNC/FMINCON
            % http://www.mathworks.com/access/helpdesk/help/toolbox/optim/ug/index.html?/access/helpdesk/help/toolbox/optim/ug/f3137.html
                
            % Initialise OPTIMISER opts

			% default case
            if(nargin == 1)
                config = varargin{1};

                % Create custom options structure
                opts.MaxIter = config.self.getIntOption('maxIterations', 100);
                opts.MaxFunEvals = config.self.getIntOption('maxFunEvals', 100);
                opts.LargeScale = char(config.self.getOption('largeScale', 'off'));
                opts.TolFun = config.self.getDoubleOption('functionTolerance', 1e-4);
				opts.GradObj = char(config.self.getOption('gradobj', 'off'));
                opts.Algorithm = char(config.self.getOption('algorithm','active-set'));

                opts.Diagnostics = char(config.self.getOption('diagnostics', 'off'));
				opts.DerivativeCheck = char(config.self.getOption('derivativecheck', 'off'));
            elseif(nargin == 3)
				% First 2 are parsed by base class
				%nvar = varargin{1};
				%nobj = varargin{2};
				opts = varargin{3};
			else
				error('Invalid number of arguments given');
            end

            % Dont show any output
            opts.Display = 'off';
			this.opts = opts;
			this.Aineq = [];
			this.Bineq = [];
			this.nonlcon = [];
		end % constructor

		% optimize
		% Description:
		%     This function optimizes the given function handle
		[this, x, fval] = optimize(this, arg )

		% setInputConstraints
		% Description:
		%     Sets input constraints
		this = setInputConstraints( this, con )

	end % methods
end % classdef
