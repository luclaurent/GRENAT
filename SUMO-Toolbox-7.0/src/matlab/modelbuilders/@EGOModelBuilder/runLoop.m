function [s] = runLoop( s )

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
%	[s] = runLoop( s )
%
% Description:
%	The main loop. Uses EGO to generate new models

import java.util.*;
import ibbt.sumo.profiler.*;

% get samples and values
[samples,values] = getData( s );

% set the data
mi = getModelFactory( s );
mi = setSamples(mi,samples,values);
s = setModelFactory(s,mi);

%Get lower and uppber bounds on the model parameters (may be [])
[LB UB] = getBounds(getModelFactory(s));

% Generate a starting point for the hyperparameter optimization
if(isempty(s.initialPop))
    % happens the very first time
	[initPop s] = generateNewModels(s, s.initPopSize, 0, s.initialPop);
	s.initialPop = initPop;
    s.initialScores = [];
else
	% continuing from the previous iteration
    
    % keep the initialScores only if sampling is disabled and the restart strategy is continue
    if( strcmp(getRestartStrategy(s),'continue') && (~isSamplingEnabled(s)) )
        % keep the previous population and the previous scores
    else
        % keep the previous population but reset the scores
        s.initialScores = [];
    end
end

% if the scores are empty generate them
if(isempty(s.initialScores))
    % score each model
    [sc s scoredModels] = defaultFitnessFunction(s,s.initialPop,1);
    s.initialScores = sc;
else
    % do nothing, scores already set
end
    
% Ok we have a few points in hyperparameter space, fit a kriging model
% first scale the hyperparameters to -1 1 to enable fitting in model space
smp = zeros(size(s.initialPop,1),size(s.initialPop,2));
for i=1:size(s.initialPop,2)
    smp(:,i) = scaleColumns(s.initialPop(:,i),-1,1,LB(i),UB(i));
end

% set the inital population and scores
pop = s.initialPop;
scores = s.initialScores;

% The Kriging model used to drive EGO
theta = 0.5.*ones(1,size(s.initialPop,2));

% Construct the kriging model
bf = BasisFunction('corrgauss',size(s.initialPop,2),-3,2,{'log'});
opts = KrigingFactory.getDefaultOptions();
opts.hpOptimizer = s.modelOptimizer;
krigModel = KrigingModel(opts,theta,'regpoly0',bf,'useLikelihood');

for iter=1:s.numIterations
    % fit the Kriging model.  Fit the log to accomodate large ranges in
    % scores
    krigModel = constructInModelSpace(krigModel,smp,log(scores));

    % If you enable this, its best to disable model plotting
    %plotModel(krigModel);
    
    % Ok, we have a kriging model, this model will be used to drive EGO

    % setup the state
    state.samples = smp;
    state.samplesFailed = [];
    state.values = log(scores);
    state.lastModels = {{krigModel}};
    state.numNewSamples = 1;  % we want one new sample

    % Let ego propose a new point
    [s.egoSS newPoints] = selectSamples(s.egoSS,state);

    % scale it back to hyperparameter space (from -1 1)
    newPointsScaled = zeros(size(newPoints,1),size(newPoints,2));
    for i=1:size(newPoints,2)
        newPointsScaled(:,i) = scaleColumns(newPoints(:,i),LB(i),UB(i),-1,1);
    end

    % Evaluate the fitness of the point
    [newScore] = defaultFitnessFunction(s,newPointsScaled,1);

    % add it to the samples
    smp = [smp ; newPoints];
    scores = [scores ; newScore];

    % keep track of what we have visited
    pop = [pop ; newPointsScaled];
end

% EGO is done, save the search trace for the next round
s.initialPop = pop;
s.initialScores = scores;

if(~isSamplingEnabled(s))
	% if sampling is disabled, we can just keep everything up to a maximum number of points
	% (to prevent overloading kriging)
	% if the maximum history size has been exceeded -> trim

    if(size(s.initialPop,1) > s.maxPoints)
        % keep some of the best points
        nBest = 5;
        [Y I] = sort(s.initialScores,1);

        % choose the remaining ones in a space filling way
        [dummy Ispace] = selectTestSet(s.initialPop, I(1:nBest,:)', s.maxPoints - nBest, 'distance');

        newScores = [s.initialScores(I(1:nBest),:) ; s.initialScores(Ispace,:)];
        newPop = [s.initialPop(I(1:nBest),:) ; s.initialPop(Ispace,:)];

        s.initialScores = newScores;
        s.initialPop = newPop;
        
        % do the same but randomly
        %	p = randperm(size(s.initialPop,1));
        %	idx = p(1:s.maxPoints);
        %
        %	s.initialPop = s.initialPop(idx,:);
        %	s.initialScores = s.initialScores(idx,:);
	end
else
	% sampling is enabled, simply coninue, using the points of the last
	% iteration as a starting point
	s.initialPop = s.initialPop(end-(s.initPopSize + s.numIterations)+1:end,:);
	s.initialScores = s.initialScores(end-(s.initPopSize + s.numIterations)+1:end,:);
end
