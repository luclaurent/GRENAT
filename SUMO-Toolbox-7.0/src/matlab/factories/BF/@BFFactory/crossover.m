function children = crossover(s,parents, options, nvars, FitnessFcn, unused,thisPopulation)

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
%	children = crossover(s,parents, options, nvars, FitnessFcn, unused,thisPopulation)
%
% Description:
%	crossover operator, breeds offspring

% How many children to produce?
nKids = fix(length(parents)/2);

% Split the mama's and the papa's
mamas = parents(1:2:end);
papas = parents(2:2:end);

[smp val] = getSamples(s);
children = cell(nKids,nvars);

%s.logger.fine( '----- CROSSOVER -------' );

for i=1:nKids
	% Extract config
	papa = thisPopulation{papas(i)};
	mama = thisPopulation{mamas(i)};

	papa = struct(papa);
	mama = struct(mama);

	%s.logger.fine( sprintf( 'Parent 1:  %s with theta = %s and polynomial degree = %d', mama.config.RBF, arr2str( mama.config.theta ), mama.config.degrees ) );
	%s.logger.fine( sprintf( 'Parent 2:  %s with theta = %s and polynomial degree = %d', papa.config.RBF, arr2str( papa.config.theta ), papa.config.degrees ) );

	choice = rand(1) * 100;
	
	if getDim(s) == 1
		if strcmp( mama.config.func.name, papa.config.func.name )
			% Intermix parameters
			spec = getBasisFunction( s, mama.config.func.name );
			nTheta = length(spec.min);
			
			if nTheta <= 1
				p = scaleOut( s, papa.config.func.theta, spec );
				m = scaleOut( s, mama.config.func.theta, spec );
				BF.theta = scaleIn( s, average( [p m] ), spec );
			else
				% Pick some theta from the papa, and some from the mama...
				select = rand(1,nTheta) > .5;
				while all( select ) || ~any( select )
					select = rand(1,nTheta) > .5;
				end
				
				newTheta = zeros(1,nTheta);
				newTheta(find(select)) = mama.config.func.theta(find(select));
				newTheta(find(~select)) = papa.config.func.theta(find(~select));
				BF.theta = newTheta;
			end
			BF.name = spec.name;
			BF.func = spec.func;
		else
			% Trouble, can't think of anything sensible
			% to do here, except taking the BF from
			% one parent and rescaling the shape parameters
			% from the other.
			
			% Use the mothers BF
			spec = getBasisFunction( s, mama.config.func.name );
			nTheta = length(spec.min);
			
			pspec = getBasisFunction( s, papa.config.func.name );
			
			% Select random indices
			indices = randomInt( 1, length(papa.config.func.theta), nTheta );
			% Rescale originals to percentages
			scaled = scaleOut( s, papa.config.func.theta, pspec );
			% And rescale to suitable ranges
			BF.theta = scaleIn( s, scaled(indices), spec ); 
			BF.func = spec.func;
			BF.name = spec.name;
		end
	else
		% Chop base function arrays for parent, and join pieces
		split = randomInt( 1, getDim(s)-1 );
		if choice < 80
			if choice < 40
				set1 = 1:split;
			else
				tmp = randperm( getDim(s) );
				set1 = tmp(1:split);
			end
			BF = papa.config.func;
			BF(set1) = mama.config.func(set1);
		else
			for k=1:getDim(s)
				pspec = getBasisFunction( s, papa.config.func(k).name );
				mspec = getBasisFunction( s, mama.config.func(k).name );
				
				BF(k).name = pspec.name;
				BF(k).func = pspec.func;
				x = scaleOut( s, mama.config.func(k).theta, mspec );
				y = x( randomInt( 1,length(x), length(pspec.min) ) );
				BF(k).theta = scaleIn( s, y, pspec );
			end
		end
		
	end
	
	% The above was complex enough, just take the fathers degrees
	newRegression = papa.config.degrees;

	modelConfig = struct( ...
		'func',				BF, ...
		'degrees',			newRegression, ...
		'backend',			getBackend(s), ...
		'targetAccuracy',	0.005 ...
	);
	
	m = makeModel( s, modelConfig );
	children{i,1} = m;

	%s.logger.fine( sprintf( 'Child  :  %s with theta = %s and polynomial degree = %d', ...
	%	spec.name, arr2str( newTheta ), newRegression ) );

end

% Make sure all are trained
children = constructModels(children,smp,val,s.getParallelMode());
