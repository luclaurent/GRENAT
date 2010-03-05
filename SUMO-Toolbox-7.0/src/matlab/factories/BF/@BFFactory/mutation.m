function children = mutation(s, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)

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
%	children = mutation(s, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)
%
% Description:
%	Mutation operator, returns the mutated population

nparents = length(parents);
functions = getBasisFunctions(s);
children = cell(nparents,nvars);

[smp val] = getSamples(s);

%s.logger.fine( '----- MUTATE -------' );

for i=1:nparents
	parent = thisPopulation{parents(i)};
	parent = struct(parent);

	%s.logger.fine( sprintf( 'Parent:  %s with theta = %s and polynomial degree = %d', parent.config.RBF, arr2str( parent.config.theta ), parent.config.degrees ) );

	% Most of the time only change the basis functions parameters
	% When mutating the Basisfunction too, do something useless on its
	% shape parameters to ensure enough randomness	
	choice = rand(1)*100;
	dimension1 = randomInt( 1, getDim(s) );
	dimension2 = randomInt( 1, getDim(s) );
	
	func = parent.config.func;
	
	if choice < 20
		% Mutate BF and parameters
		% Amounts to new random model
		m = makeModel( s, randomModelParameters(s) );
		children{i,1} = m;
		continue
	elseif choice < 50
		% Mutate shape parameter for one dimension
		func = mutateDimension( s, func, dimension1 );
	elseif choice < 80
		% Mutate shape parameter for two dimensions
		func = mutateDimension( s, func, dimension1 );
		if getDim(s) > 1 && dimension2 ~= dimension1
			func = mutateDimension( s, func, dimension2 );
		end	
	else
		% Mutate all shape parameters
		for dim=1:getDim(s)
			func = mutateDimension( s, func, dim );
		end
	end

	if rand(1) < .25
		posibilities = getRegression(s);
		newRegression = posibilities(randomInt(1,length(posibilities)));
	else
		newRegression = parent.config.degrees;
	end

	modelConfig = struct( ...
		'func',				func, ...
		'degrees',			newRegression, ...
		'backend',			getBackend(s), ...
		'targetAccuracy',	0.005 ...
	);
	
	%s.logger.fine( sprintf( 'Child  :  %s with theta = %s and polynomial degree = %d', ...
	%	BFSpec.name, arr2str( newTheta ), newRegression ) );

	m = makeModel( s, modelConfig );
	children{i,1} = m;
end

% Make sure all are trained
children = constructModels(children,smp,val,s.getParallelMode());

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function func = mutateDimension( s, func, dim )

spec = getBasisFunction( s, func(dim).name );
which = randomInt( 1, length(spec.min) );

scaled = scaleOut( s, func(dim).theta, spec );
scaled(which) = truncate( scaled(which) + randn(1) * .2, 0, 1 );
func(dim).theta = scaleIn( s, scaled, spec );
