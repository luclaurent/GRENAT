classdef MatlabPatternSearch < Optimizer

% MatlabPatternSearch (SUMO)
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
%	MatlabPatternSearch(varargin)
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
		%     Creates an MatlabGA object
		function this = MatlabPatternSearch(varargin)
			% call superclass
			this = this@Optimizer(varargin{:});

			%Generate a default set of opts
			opts = psoptimset(@patternsearch);
			searchFcn = '';
			plotFcns = '';

			% default case
			if(nargin == 1)
				config = varargin{1};
				%Update PS defaults
				opts = psoptimset(opts, 'MaxIter',		config.self.getIntOption('maxIterations', 500));
				opts = psoptimset(opts, 'MaxFunEvals',		config.self.getIntOption('maxFunEvals', 100));
				opts = psoptimset(opts, 'TimeLimit',		str2num(config.self.getOption('timeLimit', 'Inf')));
				opts = psoptimset(opts, 'MeshExpansion',		config.self.getIntOption('meshExpansion',opts.MeshExpansion));
				opts = psoptimset(opts, 'MeshContraction',	config.self.getDoubleOption('meshContraction',opts.MeshContraction));
				opts = psoptimset(opts, 'MeshAccelerator',	char(config.self.getOption('meshAccelerator',opts.MeshAccelerator)));
				opts = psoptimset(opts, 'MeshRotate',		char(config.self.getOption('meshRotate',opts.MeshRotate)));
				opts = psoptimset(opts, 'InitialMeshSize',	config.self.getIntOption('initialMeshShize',opts.InitialMeshSize));
				opts = psoptimset(opts, 'ScaleMesh',		char(config.self.getOption('scaleMesh',opts.ScaleMesh)));
				opts = psoptimset(opts, 'TolMesh',	config.self.getDoubleOption('meshTolerance',1e-4));
				opts = psoptimset(opts, 'TolFun',		config.self.getDoubleOption('functionTolerance',1e-4));
				opts = psoptimset(opts, 'MaxMeshSize',		str2num(config.self.getOption('maxMeshShize','Inf')));
				opts = psoptimset(opts, 'InitialPenalty',		config.self.getIntOption('initialPenalty',opts.InitialPenalty));
				opts = psoptimset(opts, 'PenaltyFactor',		config.self.getIntOption('penaltyFactor',opts.PenaltyFactor));
				opts = psoptimset(opts, 'PollMethod',		char(config.self.getOption('pollMethod',opts.PollMethod)));
				opts = psoptimset(opts, 'CompletePoll',		char(config.self.getOption('completePoll',opts.CompletePoll)));
				opts = psoptimset(opts, 'PollingOrder',		char(config.self.getOption('pollingOrder',opts.PollingOrder)));
				opts = psoptimset(opts, 'SearchMethod',		str2num(config.self.getOption('searchMethod', '')));
				opts = psoptimset(opts, 'CompleteSearch',		char(config.self.getOption('completeSearch',opts.CompleteSearch)));
				opts = psoptimset(opts, 'Display',		char(config.self.getOption('display','final')));
				opts = psoptimset(opts, 'Cache',			char(config.self.getOption('cache','on')));
				opts = psoptimset(opts, 'CacheTol',		config.self.getDoubleOption('cacheTolerance',1e-6));
				
				%Set which search method to use
				searchFcn = char(config.self.getOption('searchMethod','GPSPositiveBasisNp1'));
				
				%Set which plot functions to use
				plotFcns = char(config.self.getOption('plotFunctions',''));
				%plotFcns = char(config.self.getOption('plotFunctions','{@psplotbestf,@psplotfuncount,@psplotmeshsize}'));
				

			% custom constructors
			elseif(nargin == 2)
				% no options, take defaults (only options are for base
				% class
			elseif(nargin == 3)
				%First 2 are parsed by base class
				%nvar = varargin{1};
				%nobj = varargin{2};
				opts = psoptimset( opts, varargin{3} );
			else
				error('Invalid number of arguments given');
			end	
			
			if(length(searchFcn > 0))
					if(searchFcn(1) == '@')
						opts = psoptimset(opts, 'SearchMethod',	eval(searchFcn));
					else
						opts = psoptimset(opts, 'SearchMethod',	searchFcn);
					end
			end
			
			if(length(plotFcns > 0))
					opts = psoptimset(opts, 'PlotFcns',		eval(plotFcns));
			end
				
			%Dont show any output
			opts = psoptimset(opts,'Display','off');

			this.opts = opts;
			his.Aineq = [];
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
