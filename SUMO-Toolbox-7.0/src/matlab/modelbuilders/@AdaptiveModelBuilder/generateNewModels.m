function [initialPop s] = generateNewModels(s, number, wantModels, previousPop);

% generateNewModels (SUMO)
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
%	[initialPop s] = generateNewModels(s, number, wantModels, previousPop);
%
% Description:
%	Generates starting point for the hyperparameter optimization and also implements different restart strategies
%	(= ie how to continue they hyperparameter optimization process in the next modeling iteration)

%  if(length(s.searchHistory)>1)
%  	figure(99)
%  	subplot(1,3,1)
%  	plot(s.searchHistory(:,1),s.searchHistory(:,2),'b+')
%  	subplot(1,3,2)
%  	plot(1:length(s.scoreHistory),s.scoreHistory(:,1),'b-')
%  	subplot(1,3,3)
%  	x = makeMonotonic(s.scoreHistory,'descending',1);
%  	plot(1:length(x),x(:,1),'b-')
%  end

[samples, values] = getData(s);

%Get lower and uppber bounds on the model parameters (may be [])
[LB UB] = getBounds(getModelFactory(s));

% is the previous population a cell array?
isCell = iscell(previousPop);

% first make sure the previous pop is sane
d = number - size(previousPop,1);
if(isempty(previousPop))
	% first time, simply generate a new starting point/population and return
	initialPop = createInitialModels(getModelFactory(s),number,wantModels);
	return;
elseif(d > 0)
	% the previous pop does not contain enough models, fill it up
	% this could happen if using an optimizer with dynamic population size
	% ask the model factory to fill in the blanks
	extraPop = createInitialModels(getModelFactory(s),d,wantModels);
	previousPop = [previousPop ; extraPop];
	s.logger.warning(sprintf('%d extra models added to previousPopulation to ensure %d can be returned',d,number));
elseif(d < 0)
	% too many previous models, simply cutoff
	previousPop = previousPop(1:number,:);
	s.logger.warning(sprintf('%d extra models removed from previousPopulation to ensure %d are returned',abs(d),number));
else
	% sizes are equal, all ok
end

% the final point/population from the previous model building run is available
% Decide how to restart the optimization in the next iteration

% Are we dealing parameter vectors or Model objects
if(isCell)
  customPopType = (isa(previousPop{1,:},'ModelInterface'));
else
  customPopType = (isa(previousPop(1,:),'ModelInterface'));
end

if(customPopType)
	if(strcmp(s.restartStrategy,'model'))

		% ask the model interface to generate new model objects
		pop = createInitialModels(getModelFactory(s),number,wantModels);

		% if the previous population was a cell, also return a cell
		if(isCell)
		    initialPop = cell(number,1);
		    for i=1:number
		      initialPop{i} = pop(i);
		    end
		else
		    initialPop = pop;
		end

	elseif(strcmp(s.restartStrategy,'continue'))

		% save the result as the initial population for the next iteration
		initialPop = previousPop;
	else
		% any other strategy is not supported when dealing with model objects, set to continue
		s.logger.warning(['The restart strategy ' s.restartStrategy ' is not valid when evolving models, switching to continue']);
		s.restartStrategy = 'continue';

		initialPop = previousPop;
	end

else

    % intelligent only works in single objective mode
	if(strcmp(s.restartStrategy,'intelligent') && s.paretoMode)
		s.logger.warning(['The restart strategy ' s.restartStrategy ' is not valid in multi objective mode, switching to continue']);
		s.restartStrategy = 'continue';
	end

	if(strcmp(s.restartStrategy,'intelligent') && ~license('test','statistics_toolbox'))
		s.logger.warning(['The restart strategy ' s.restartStrategy ' needs the Statistics toolbox, switching to continue']);
		s.restartStrategy = 'continue';
	end

	if(strcmp(s.restartStrategy,'continue'))

		%Save the result as the initial point for the next iteration
		initialPop = previousPop;

	elseif(strcmp(s.restartStrategy,'random'))

		%Choose a random initial point
		initialPop = zeros(number, size(previousPop,2));
		for i=1:number
			initialPop(i,:) = boundedRand(LB(:),UB(:));
		end

	elseif(strcmp(s.restartStrategy,'model'))

		%Ask the model interface what to use
		initialPop = createInitialModels(getModelFactory(s),number,wantModels);

	elseif(strcmp(s.restartStrategy,'intelligent'))

		% Do an intelligent restart
		initialPop = intelligentRestart(s,previousPop, samples, number, LB, UB);			

	else
		msg = ['Invalid restart strategy ' s.restartStrategy ' given'];
		s.logger.severe(msg);
		error(msg);
	end
end



function pop = intelligentRestart(s, prevPop, samples, number, LB, UB)
    % Magic number, only look at the last 12 models built
	windowSize = 12;

    % If our window is filled, look at the evolution of the best score and
    % do a linear fit to find the slope of improvement.  The more negative
    % the slope, the faster we are converging to a local optima, the lower
    % the probability of a restart

    if(size(s.scoreHistory,1) >= windowSize)
        % get the last 'window' scores
        scoreWindow = s.scoreHistory(end-windowSize+1:end,:);	
        scoreWindow = makeMonotonic(scoreWindow,'descending',1);
        xvals = 1:windowSize;

        % perform a linear fit on the window
        coef = [xvals' ones(windowSize,1)] \ scoreWindow;

        % get the slope
        slope = coef(1);

        % build a logistic regression model for the slope
        % it calculates the probability that we should restart 

        % fix some data points (more magic numbers :) )
        % first column = slope, second = probability of restarting
        xx = [-2  0 ;
              -1  0 ;
               0  0.90 ;
               1  1];

        % do the regression
        B = glmfit(xx(:,1),xx(:,2),'binomial','link','probit');

        % now evaluate the regression at the current slope
        restartProb = glmval(B,slope,'probit');

        %slope
        %restartProb
    else
        % window not filled yet, continue
        restartProb = 0;
    end

	if(rand <= restartProb)
        %disp('******* restarting')
		% restart intelligently
		if(~isSamplingEnabled(s) || getKeepOldModels(s))
			% no sampling or using some objective measure (e.g., dense validation set),
			% all runs are equally reliable
			s.reliability = [];
		else
			% calculate the reliability of this optimization trace
			[reliability] = calculateReliability( samples );
			len = size(s.scoreHistory,1) - size(s.reliability,1);
			s.reliability = [s.reliability ; ones(len,1)*reliability];
		end
		
		% Generate a new starting point intelligently
		pop = genNewOptimizationSeed(s.searchHistory, s.scoreHistory, s.reliability, number, LB, UB );
	else
		% simply continue
		pop = prevPop;		
	end
