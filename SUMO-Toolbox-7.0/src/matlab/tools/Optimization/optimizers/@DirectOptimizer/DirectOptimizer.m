classdef DirectOptimizer < Optimizer

% DirectOptimizer (SUMO)
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
%	DirectOptimizer(varargin)
%
% Description:
%	Wrapper around the DIRECT optimization algorithm

%                    opts.testflag  = 1 if globalmin known, 0 otherwise (default is 0)
%                    opts.showits   = 1 if disp. stats shown, 0 oth.
%                                      (default is 1)
%                    opts.globalmin = globalmin (if known)
%                                      (default is 0)
%                    opts.tol       = tolerance for term. if tflag=1
%                                      (default is 0.01)
%                    opts.impcons   = turns on implicit constraint capability
%                                      (default is 0)
%                                     If set to one, objective function
%                                     is expected to return a flag which represents
%                                     the feasibility of the point sampled
	
	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		opts;
		constraints;
		penalty;
	end
	
	methods

		% constructor
		% Description:
		%     Creates an DirectOptimizer object
		function this = DirectOptimizer(varargin)
			% call superclass
			this = this@Optimizer(varargin{:});

			defaults = struct( ...
				'ep', 1e-4, ...
				'maxevals',  200 , ...
				'maxits',  100 , ...
				'maxdeep',  100 , ...
				'showits',  false...
			);
			opts = defaults;

			% default case
			if(nargin == 1)
				config = varargin{1};
				opts.ep = config.self.getDoubleOption( 'ep', 1e-4 );
				opts.maxevals = config.self.getIntOption( 'maxevals', 200 );
				opts.maxits = config.self.getIntOption( 'maxits', 100 );
				opts.maxdeep = config.self.getIntOption( 'maxdeep', 100 );
				opts.showits = config.self.getBooleanOption( 'showits', false );
				penalty = config.self.getDoubleOption( 'penalty', 25000 );

			% custom constructors
			elseif(nargin == 2)
				% no options, take defaults (only options are for base class
				penalty = 25000;
			elseif(nargin == 3)
				%First 2 are parsed by base class
				%nvar = varargin{1};
				%nobj = varargin{2};
				opts = mergeStruct( opts, varargin{3} );

				penalty = 25000;
			else
				error('Invalid number of arguments given');
			end	

			this.opts = opts;
			this.constraints = {};
			this.penalty = penalty;
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
