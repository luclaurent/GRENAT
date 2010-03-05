function mutationChildren = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)

% mutation (SUMO)
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
%	mutationChildren = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)
%
% Description:
%	 The arguments to the function are
%	 * parents - Row vector of parents chosen by the selection function
%	 * options - Options structure
%	 * nvars - Number of variables
%	 * FitnessFcn - Fitness function
%	 * state - Structure containing information about the current generation.
%	 * thisScore - Vector of scores of the current population
%	 *thisPopulation - Matrix of individuals in the current population
%
%	The function returns mutationChildren as a matrix whose rows correspond to the children.
%	The number of columns of the matrix is Number of variables.

%Pre-allocate
mutationChildren = cell(size(parents,1),nvars);

[smp val] = this.getSamples();

for i = 1:length(parents)
	parent = thisPopulation{parents(i),:};

	%% Mutate Hyperparameters
	[dummy hp] = parent.getHp();
	rd = rand(size(hp)) .* 2 - 1;
	hp = hp + rd;
	
	% ensure bounds
	o = ones( size(hp) );
	hp = min( max(-o, hp), o);
	
	%% Change correlation function
	corrfunc = parent.correlationFunction();
	dice = rand;
	if dice < 0.1
		corrfunc = this.correlationFunctions{ randomInt( 1, this.nBFs ) };
	end
	
	%% Change regression function
	regrfunc = parent.regressionFunction();
    dice = rand;
    if dice < 0.1
        % switch two columns
        dice1 = randomInt( 1, size(regrfunc, 2) );
        dice2 = randomInt( 1, size(regrfunc, 2) );

        tmp = regrfunc( :, dice1 );
        regrfunc( :, dice1 ) = regrfunc( :, dice2 );
        regrfunc( :, dice2 ) = tmp;
    end

	m = this.createModel(this.options, hp, regrfunc, corrfunc );
	mutationChildren{i,1} = m;
end

% Make sure all are trained
mutationChildren = constructModels(mutationChildren,smp,val,this.getParallelMode());

this.logger.fine(sprintf('Produced %d of %d kriging mutation children',length(parents),length(thisPopulation)));
