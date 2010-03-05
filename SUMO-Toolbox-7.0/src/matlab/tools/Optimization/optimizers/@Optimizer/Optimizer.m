classdef Optimizer

% Optimizer (SUMO)
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
%	Optimizer(varargin)
%
% Description:
%	Abstract base class for an optimizer.
%	 Provides a logger to the derived classes
%	  And instantiates all constraints

	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		LB;
		UB;
		nvars;
		nobjectives;
		initialPopulation;
		logger;
		hints;
		state;
	end
   
	% public methods
	methods
		% constructor
		% Description:
		%     Creates an Optimizer object, not to be called explicitly.
		%     Always through derived classes
		function this = Optimizer(varargin)   
			% get logger
			import java.util.logging.*
			this.logger = Logger.getLogger('Matlab.Optimizer');

			if nargin == 1
				config = varargin{1};
				this.nvars = config.input.getInputDimension();
				this.nobjectives = config.output.getOutputDimension();
			elseif nargin >= 2
				this.nvars = varargin{1};
				this.nobjectives = varargin{2};
				% rest of parameters is for inherited classes
			else
				error('Invalid number of parameters given');
			end

			% set bounds to the default SUMO working range [-1,1], this can be set for a specific task with setBounds()
			this.LB = -ones( 1, this.nvars );
			this.UB =  ones( 1, this.nvars );
			this.initialPopulation = zeros(1, this.nvars );
			this.hints = [];
		end % constructor

	end
	
	% Final public methods
	methods (Sealed = true, Access = public)
		% getBounds
		% Description:
		%     Returns bounds for optimizers that need it
		[LB UB] = getBounds(this)

		% setBounds
		% Description:
		%     Sets bounds for optimizers that need it
		this = setBounds(this, LB, UB)

		% getInitialPopulation
		% Description:
		%     Gets the starting positions for the search
		startx = getInitialPopulation(this)

		% setInitialPopulation
		% Description:
		%     Sets the starting position for the search
		this = setInitialPopulation(this,startx)

		% getInputDimension
		% Description:
		%     Returns the number of input variables
		nvars = getInputDimension(this)

		% getOutputDimension
		% Description:
		%     Returns the number of input variables
		nobjectives = getOutputDimension(this)

		% setDimensions
		% Description:
		%     Sets the number of input and output dimensions (= number of
		%     objectives)
		this = setDimensions(this,inDim,outDim)

		% hint
		% Description:
		%     Gives a hint to the optimizer
		%     Only supports 'maxTime', time atm.
		this = setHint( this, key, value )
		
		% hint
		% Description:
		%     Gets a hint to the optimizer
		%     Only supports 'maxTime', time atm.
		value = getHint( this, key )
		
		function s = setState(s, state)
			s.state = state;
		end
		
		function state = getState(s)
			state = s.state;
		end
   end % sealed methods
   
	% Overridable methods, these CAN be implemented
	methods (Access = public)
		
		% getPopulationSize
		% Description:
		%     Get the number of individuals in the population
		%	  The base method assumes only 1 individual. Population-based
		%	  methods should override this
		size = getPopulationSize(this)

		% setInputConstraints
		% Description:
		%     Sets input constraints
		this = setInputConstraints( this, con )
	end % Overridable functions with standard implementation
	
   	% Abstract methods, these MUST be implemented
	methods (Abstract = true, Access = public)
		% optimize
		% Description:
		%     Dummy function. Subclasses should implement this function.
		%     This function optimizes the given function handle
		%      Subject to constraints
		[this, x, fval] = optimize(this, arg )
	end % public abstract methods
end
