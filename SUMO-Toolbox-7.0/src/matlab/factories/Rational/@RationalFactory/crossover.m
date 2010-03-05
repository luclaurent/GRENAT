function children = crossover(this,parents, options, nvars, FitnessFcn, unused,thisPopulation)

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
%	children = crossover(this,parents, options, nvars, FitnessFcn, unused,thisPopulation)
%
% Description:
%	Crossover operator, returns offspring

% How many children to produce?
nKids = fix(length(parents)/2);

% Split the mama's and the papa's
mamas = parents(1:2:end);
papas = parents(2:2:end);

[smp val] = getSamples(this);
children = cell(nKids,1);

this.logger.finest( '----- CROSSOVER -------' );

for i=1:nKids
	% Extract config
	papa = thisPopulation{papas(i)};
	mama = thisPopulation{mamas(i)};

	[ppercent, pweights, pflags] = getParameters( papa );
	[mpercent, mweights, mflags] = getParameters( mama );
	
	this.logger.finest( sprintf( ' Original A : %s ; %s ; %s', ...
		num2str( ppercent), num2str( pweights ), num2str( pflags ) ) );
	this.logger.finest( sprintf( ' Original B : %s ; %s ; %s', ...
		num2str( mpercent), num2str( mweights ), num2str( mflags ) ) );

	% if both parents are identical (this seems to happen quite often), create a random child
	if([ppercent, pweights, pflags] == [mpercent, mweights, mflags])
	  model = this.createRandomModel();
	  this.logger.finest( sprintf( ' Child    : random child') );
	  this.logger.finest( '' );
	else
	  % if parents differ on more than just the percentage
	  if([pweights, pflags] ~= [mweights, mflags])
	    % do one point crossover
	    [c1 c2] = onePointCrossover([ppercent, pweights, pflags] , [mpercent, mweights, mflags],1);
	      
	    if(rand < 0.5)
	      model = this.createModel( c1 );
	    else
	      model = this.createModel( c2 );
	    end
	  else
	    % custom crossover
	  
	    % for weights
	    weight = mweights; % take weights of mama
	    
	    % for flags
	    flags = pflags; % take flags of papa
	    
	    % for percent (respects the absolute maximum degrees of freedom)
	    nsamples = size(smp,1); % how many samples do we have now
	    % Whats the maximum percentage we can set so that we do not exceed the maximum absolute bound
	    maxPerc = (getMaxDegrees(this) / nsamples) * 100;
	    % enforce the maximum
	    percent = min( average( [ppercent, mpercent] ) + (3*rand), maxPerc);

	    this.logger.finest( sprintf( ' Child    : %s ; %s ; %s', ...
		    num2str( percent), num2str( weight ), num2str( flags ) ) );
	    this.logger.finest( '' );
	    
	    model = this.createModel( [percent, weight, flags] );
	  end
	end

	children{i,1} = model;
end

% Make sure all are trained
children = constructModels(children,smp,val,this.getParallelMode());

this.logger.fine(sprintf('Produced %d of %d rational crossover children',nKids,length(thisPopulation)));
