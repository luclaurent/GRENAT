function [this lik] = tuneParameters( this, F )

% tuneParameters (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	[this lik] = tuneParameters( this, F )
%
% Description:
%	Optimizes parameters of kriging model
%

% TODO: make dim_in, dim_out member variables ?
[n p] = size(this.samples); % 'number of samples' 'dimension'

%% construct objective
if isinf( this.options.lambda0 )
	% only theta
	func = @(hp) likelihood( this, F, hp, this.lambda);
    initialPopulation = this.hyperparameters0;
    bounds = this.options.hpBounds;
else %if ~isempty( this.boundsLambda )
	% theta + lambda
	func = @(param) likelihood( this, F, param(:,1:p), param(:,end) );
    initialPopulation = [this.hyperparameters0 this.options.lambda0];
    bounds = [this.options.hpBounds this.options.lambdaBounds];
end

%% Initialize optimization algorithm
dim = size( bounds, 2 );

% Only possible by constructing Kriging or KrigingModel directoly
if isempty( this.options.hpOptimizer )
	choice = 2;
	if choice == 1
		opts.HybridFcn = [];
		opts.Generations = 100;
		opts.EliteCount = 2;
		opts.CrossoverFraction = 0.8;
		opts.PopulationSize = 50;
		opts.MutationFcn = @mutationadaptfeasible;
		%this.thetaOptimizer = MatlabGA( dim, 1, opts );
		%this.thetaOptimizer = HCOptimizer( dim, 1, 100); % 1000 iterations
	elseif choice == 2 
		opts.GradObj = 'on'; %@fmincon;
		opts.DerivativeCheck = 'off';
		opts.Diagnostics = 'off';
		opts.Algorithm = 'active-set'; % best
		%opts.Algorithm = 'interior-point';
		%opts.Algorithm = 'trust-region-reflective'; % default of Matlab

		%opts.TolFun = eps
		%opts.TolX = eps

		this.options.hpOptimizer = MatlabOptimizer( dim, 1, opts );	
		% TODO: fmincon with gradient = second output of objective
	else % choice == 3
		%opts.GradObj = 'off'; %@fmincon;
		%opts.Algorithm = 'trust-region-reflective';
		opts = [];
		this.options.hpOptimizer = SQPLabOptimizer( dim, 1, opts );	
		% TODO: fmincon with gradient = second output of objective
	end
end

%% Optimize
this.options.hpOptimizer = this.options.hpOptimizer.setDimensions( dim, 1 );
this.options.hpOptimizer = this.options.hpOptimizer.setInitialPopulation( initialPopulation  );
this.options.hpOptimizer = this.options.hpOptimizer.setBounds( bounds(1,:), bounds(2,:) );
[this.options.hpOptimizer pop opvalue] = optimize( this.options.hpOptimizer, func );

% boundary check (=nice hint to the user when bounds are too small)
lbCheck = abs(bounds(1,:) - pop(1,:));
ubCheck = abs(bounds(2,:) - pop(1,:));
if any( min( lbCheck, ubCheck ) < eps )
    warning('Found optimum is close to the boundaries. You may try enlarging the bounds.');
end

% store optimum
this.hyperparameters = pop(1,1:size(this.hyperparameters0,2)); % take best one (if it is a population)
if ~isinf( this.options.lambda0 )
    this.lambda = pop( 1, end );
end
	
if this.options.debug
    persistent likPlot
    
    if isempty( likPlot )
        likPlot = figure;
    else
        figure(likPlot);
    end
    
    % likelihood contour plot
	this.plotLikelihood(func);

    % initial population and minimum
    hold on;
    plot(initialPopulation(:,1), initialPopulation(:,2),'ko','Markerfacecolor','k');
	plot(pop(2:end,1), pop(2:end,2),'ko','Markerfacecolor','r');
	plot(pop(1,1), pop(1,2), '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
	hold off
	foundminimum = opvalue(1,:)
	pause;
end

end
