function children = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)

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
%	children = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation)
%
% Description:
%	Mutation operator, mutates population and returns it

% make sure the percentage respects the absolute maximum degrees of freedom
% how many samples do we have now
[smp val] = getSamples(this);
nsamples = size(smp,1);
% Whats the maximum percentage we can set so that we do not exceed the maximum absolute bound
maxPerc = (getMaxDegrees(this) / nsamples) * 100;

nparents = length(parents);

children = cell(nparents,1);
weightBounds = this.weight;
percentBounds = this.percent;

% enforce the maximum
percentBounds.upper = round(min(percentBounds.upper, maxPerc));

this.logger.finest( '----- MUTATE -------' );

for i=1:nparents
	parent = thisPopulation{parents(i)};
	
	[percent, weights, flags] = getParameters( parent );
	
	this.logger.finest( sprintf( ' Original : %s ; %s ; %s', ...
		num2str( percent), num2str( weights ), num2str( flags ) ) );
	
	sw = fix(rand(1)*3-eps);
	switch sw
		case 0
			% Change percentage
			percent = randomInt( percentBounds.lower, percentBounds.upper );
		case 1
			% Change weigths
			range = weightBounds.upper - weightBounds.lower;
			rnd = (rand(size(range)) - .5) * 2 .* ceil(range / 5);
			weights = truncate( round(weights + rnd), ...
				weightBounds.lower, weightBounds.upper );
		case 2
			% Change flags
			flags = rand(size(flags)) > (this.rational / 100);
	end
	
	this.logger.finest( sprintf( ' New : %s ; %s ; %s', ...
		num2str( percent), num2str( weights ), num2str( flags ) ) );
	this.logger.finest( '' );

	model = RationalModel( percent, weights, flags, this.frequencyVariable, this.baseFunction, 0 );
	children{i,1} = model;
end

% Make sure all are trained
children = constructModels(children,smp,val,this.getParallelMode());

this.logger.fine(sprintf('Produced %d of %d rational mutation children',length(parents),length(thisPopulation)));
