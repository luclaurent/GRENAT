function this = runLoop(this)

% runLoop (SUMO)
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
%	this = runLoop(this)
%
% Description:
%	The main loop. Runs a full optimization before returning.

import java.util.*;
import ibbt.sumo.profiler.*;

% get samples and values
[samples,values] = getData(this);

% set the data
mi = getModelFactory( this );
mi = setSamples(mi,samples,values);
this = setModelFactory(this,mi);

%Get lower and upper bounds on the model parameters (may be [])
[LB UB] = getBounds(getModelFactory(this));

% set dimensions of L2 parameters
this.optimizer = this.optimizer.setDimensions( length(LB), 1 );

% set the bounds
this.optimizer = this.optimizer.setBounds(LB , UB);

% Generate a starting point for the hyperparameter optimization
[initialPopulation this] = generateNewModels(this, this.optimizer.getPopulationSize(), 0, this.initialPopulation);
this.initialPopulation = initialPopulation;

% set the initial starting population (not used by all optimizers)
this.optimizer = this.optimizer.setInitialPopulation(this.initialPopulation);

%Ensure we respect the global maximum time limit set by the user
elTime = etime(clock,getStartTime(this)); 	 %How many seconds have passed since the toolbox was started
maxTime = getMaximumTime(this)*60; 	 %How many seconds is the toolbox allowed to run in total
remainingTime = max(1,maxTime - elTime); %How many seconds do we have left
this.optimizer = this.optimizer.setHint( 'maxTime', remainingTime ); % Suggests to the optimizer when to stop
this.logger.fine(sprintf([class(this.optimizer) ' time limit suggested of %d minutes'],remainingTime/60));

	% Nested function that computes the objective function
	function score = fitnessFunction(x)
		[score this scoredModels] = defaultFitnessFunction(this,x);
	end

%Run the optimizer
[this.optimizer x fval] = this.optimizer.optimize(@fitnessFunction);

%Save the result as the previous best value for the next iteration
this.initialPopulation = x;

% TODO: this is needed for custom fitness funcs (likelihood etc)
% construct model and score it (to include it in history)
%[samples values] = getData(this);
%mod = createModel(getModelFactory(this),x(1,:),samples,values);
%this = scoreModel( this, mod );

this.logger.info(sprintf([class(this.optimizer) ' Optimization terminated']));
this.logger.fine(sprintf('Best parameter vector found is %s with score %d',num2str(x(1,:)),fval(1,:)));

end
