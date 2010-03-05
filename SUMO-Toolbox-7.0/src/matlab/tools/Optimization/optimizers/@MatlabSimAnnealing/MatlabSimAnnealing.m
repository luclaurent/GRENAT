classdef MatlabSimAnnealing < Optimizer

% MatlabSimAnnealing (SUMO)
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
%	MatlabSimAnnealing(config)
%
% Description:
%	Wrapper around the matlab optimizers

	
	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		opts;
		algorithm;
		Aineq;
		Bineq;
		nonlcon;
	end
	
	methods

		% constructor
		% Description:
		%     Creates an MatlabGA object
		function this = MatlabSimAnnealing(config)
			% call superclass
			this = this@Optimizer(config);

			algorithm = char(config.self.getOption('algorithm','simulannealbnd'));

			%Generate a default set of opts
			eval(['opts = saoptimset(@' algorithm ');']);

			%Update SA defaults
			opts = saoptimset(opts, 'AnnealingFcn', eval(char(config.self.getOption('annealingFcn','@annealingfast'))));
			opts = saoptimset(opts, 'TemperatureFcn',eval(char(config.self.getOption('temperatureFcn','@temperatureexp'))));
			opts = saoptimset(opts, 'AcceptanceFcn',eval(char(config.self.getOption('acceptanceFcn','@acceptancesa'))));
			opts = saoptimset(opts, 'TolFun',		config.self.getDoubleOption('tolFun', 1.0000e-6));
			opts = saoptimset(opts, 'StallIterLimit',	config.self.getIntOption('stallIterLimit', 500));
			opts = saoptimset(opts, 'MaxFunEvals',	config.self.getIntOption('maxFunEvals', 1000));
			opts = saoptimset(opts, 'TimeLimit',	str2num(config.self.getOption('timeLimit', 'Inf')));
			opts = saoptimset(opts, 'MaxIter',	str2num(config.self.getOption('maxIter', 'Inf')));
			opts = saoptimset(opts, 'ObjectiveLimit',	str2num(config.self.getOption('objectiveLimit', '-Inf')));
			opts = saoptimset(opts, 'Display', 	char(config.self.getOption('display','final')));
			opts = saoptimset(opts, 'DisplayInterval', config.self.getIntOption('displayInterval', 10));

			hybridFcns = char(config.self.getOption('hybridFunction',''));
			if(length(hybridFcns > 0))
				opts = saoptimset(opts, 'HybridFcn',	eval(hybridFcns));
			end

			opts = saoptimset(opts, 'HybridInterval', 	char(config.self.getOption('hybridInterval','end')));

			%Set which plot functions to use
			plotFcns = char(config.self.getOption('plotFunctions',''));
			%plotFcns = char(config.self.getOption('plotFunctions','{@saplotbestf,@saplotf,@saplottemperature}'));
			if(length(plotFcns > 0))
				opts = saoptimset(opts, 'PlotFcns',	eval(plotFcns));
			end

			opts = saoptimset(opts, 'PlotInterval', config.self.getIntOption('plotInterval', 1));
			opts = saoptimset(opts, 'InitialTemperature',	config.self.getIntOption('initialTemperature', 100));
			opts = saoptimset(opts, 'ReannealInterval',	config.self.getIntOption('reannealInterval', 100));

			%Dont show any output
			opts = saoptimset(opts,'Display','off');

			this.opts = opts;
			this.algorithm = algorithm;
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
