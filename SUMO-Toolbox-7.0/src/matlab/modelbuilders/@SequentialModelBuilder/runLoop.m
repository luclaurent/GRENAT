function s = runLoop(s)

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
%	s = runLoop(s)
%
% Description:
%	Main adaptive modelling code. Just sequentially
%	create new models (by calling the modelInterface's
%	`create' method) and score them, keeping a history
%	window of `historySize' models.

% get samples and values
[samples,values] = getData(s);

if(isempty(s.history.models))
    % first time, no history, do nothing
else
    % since we are continuing we have to check if new samples
    % arrived since the previous iteration.  If this is the case
    % the population needs to be updated with the new data
            
    if(isSamplingEnabled(s))
      % yup, sampling is enabled, we have to update all models to prevent poor model selection                
      s.logger.fine(sprintf('New samples may have arrived since the last iteration, updating the %d models in the history first',length(s.history.models)));
      s.history.models = constructModels(s.history.models,samples,values,getParallelMode(s));
      
      % now score them
      [scores s scoredModels] = defaultFitnessFunction(s,s.history.models,false);
      s.history.scores = scores;
    end
end

s.runLength = 0;
while ((s.runLength < s.maximumRunLength) && ~done(s))
	
	% get samples and values
	[samples,values] = getData(s);

	% set the data
	mi = getModelFactory( s );
	mi = setSamples(mi,samples,values);
	s = setModelFactory(s,mi);

	% Log iteration number
	s.logger.finer(sprintf('StationaryRunLength : %d', s.runLength));
	
	% Get a new model from the modeller, then call
	% the construct method to create a model through
	% samples and values
	mi = getModelFactory( s );
	[mi, newModel] = createFromHistory(mi, s.history);
	s = setModelFactory( s, mi );

	% What is the score of the current best model
	oldBestScore = getBestModelScore(s);

	% Calculate the score for this model
	[newScore s newModel] = defaultFitnessFunction(s, newModel, 1);
	newModel = newModel{1};

	% was there a new best model?
	if(newScore < oldBestScore)
		% reset the runlength
		s.runLength = 0;
	else
		% increment the runlength
		s.runLength = s.runLength + 1;
	end
	
	% Add model to history
	s.history.scores = [s.history.scores * s.decay; newScore];
	s.history.models = [s.history.models; newModel];
    s.history.runLength = s.runLength;
	
	% Get current history size
	currentSize = size(s.history.scores);
	
	% Trim history
	if currentSize(1) > s.historySize
		
		index=1:currentSize;
		switch s.strategy
			case 'best'
				% Find the worst model and drop it (only if we exceed historySize)
				[dummy,index] = sort(s.history.scores);
				% Drop its entries in scores and models
				index = index(1:s.historySize);
				
			case 'window'
				% keep last models
				index = (currentSize - s.historySize+1) : currentSize;
		end
		
		% drop em
		s.history.scores = s.history.scores(index);
		s.history.models = s.history.models(index);
		
	end
end
