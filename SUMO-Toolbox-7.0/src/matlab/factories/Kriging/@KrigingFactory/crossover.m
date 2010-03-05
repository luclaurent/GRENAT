function xoverKids = crossover(this,parents, options, nvars, FitnessFcn, unused,thisPopulation)

% crossover (SUMO)
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
%	xoverKids = crossover(this,parents, options, nvars, FitnessFcn, unused,thisPopulation)
%
% Description:
%	A Simple crossover operator
%	The arguments to the function are
%	 * parents ??? Row vector of parents chosen by the selection function
%	 * options ??? options structure
%	 * nvars ??? Number of variables
%	 * FitnessFcn ??? Fitness function
%	 * unused ??? Placeholder not used
%	 * thisPopulation ??? Matrix representing the current population.
%	The number of rows of the matrix is Population size and the number of
%	columns is Number of variables.

% How many children to produce?
nKids = length(parents) / 2;

%Pre-allocate childern array
xoverKids = cell(nKids, nvars);

[smp val] = this.getSamples();

index = 1;
for i = 1:nKids
	% get parents
	parent1 = thisPopulation{parents(index),:};
	index = index + 1;
	parent2 = thisPopulation{parents(index),:};
	index = index + 1;

	%% mix up hyperparameters	
	[dummy hp1] = parent1.getHp();
	[dummy hp2] = parent2.getHp();
	nHp = length(hp1);

	dice = rand;
	if dice >= 0.5
		% Method 1: Take a average of the location	
		hp3 = (hp1 + hp2) ./ 2;
	else
		% Method 2 (NEW): view it per dimension (=BFFactory), take some from dad and some
		% from mom
		select = rand(1,nHp) > .5;
		hp3(find(select)) = hp1(find(select)); % dad
		hp3(find(~select)) = hp2(find(~select)); % mom
	end
	
	%% mix up regression functions (trend)
	% In this case, just inherit the function from mom or dad
	regrfunc1 = parent1.regressionFunction(); % dad
	regrfunc2 = parent2.regressionFunction(); % mom
	
	dice = rand;
	if dice >= 0.5 % dad wins
		regrfunc3 = regrfunc1;
	else % mom wins
		regrfunc3 = regrfunc2;
	end
	
	%% mix up correlation functions
	% In this case, just inherit the function from mom or dad
    corrfunc1 = correlationFunction(parent1); % dad
	corrfunc2 = correlationFunction(parent2); % mom
	
	dice = rand;
	if dice >= 0.5 % dad wins
		corrfunc3 = corrfunc1;
	else % mom wins
		corrfunc3 = corrfunc2;
	end
	
	%% build child
	m = this.createModel(this.options, hp3, regrfunc3, corrfunc3);
	xoverKids{i,1} = m;
end

% Make sure all are trained
xoverKids = constructModels(xoverKids,smp,val,this.getParallelMode());

this.logger.fine(sprintf('Produced %d of %d kriging crossover children', nKids, length(thisPopulation)));
