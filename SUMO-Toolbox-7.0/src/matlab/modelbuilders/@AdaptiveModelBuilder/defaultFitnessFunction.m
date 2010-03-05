function [scores s scoredModels] = defaultFitnessFunction(s, pop, train)

% defaultFitnessFunction (SUMO)
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
%	[scores s scoredModels] = defaultFitnessFunction(s, pop, train)
%
% Description:
%	Return the score of the given models or parameter vector (representing one or more models)
%	This is a generic implementation that every model builder can use.

if(~exist('train','var'))
  train = 1;
end

% is the population stored in a cell array?
isCell = iscell(pop);

[samples values] = getData(s);
mi = getModelFactory(s);

scores = [];
tmpModels = cell(size(pop,1),1);

try
	% first convert them all to model objects
	if(isCell)
	  for i=1:size(pop,1)
	    tmpModels{i} = createModel(mi,pop{i,:});
	  end
	else
	  for i=1:size(pop,1)
	    tmpModels{i} = createModel(mi,pop(i,:));
	  end
	end

	% now train them all, this may occur in parallel
	if(train)
	  tmpModels = constructModels(tmpModels,samples,values,s.parallelMode);
	end

	% now score them all on the different meausres, best score is 0
	[s, scores, measureScores, scoredModels] = scoreModels( s, tmpModels );

	% If we are in multi-objective mode, use the measure scores instead of the global scores
	if s.paretoMode
	  scores = measureScores;
	  s.paretoProfiler.addEntries(measureScores);
	end

	% now do some profiling on each model
	for i=1:length(tmpModels)
		model = scoredModels{i};

		s = observe( s, 'model', s.modelCounter, model );
		s.modelCounter = s.modelCounter + 1;
	end

	% if the original population were doubles (not model objects) save the search history
	% this is used in the intelligent restart and (optionally) for plotting the optimizaiton surface
	if(isa(pop(1,:),'double'))
	  s.searchHistory = [s.searchHistory ; pop];
	  s.scoreHistory = [s.scoreHistory ; scores];
	end

	% Optionally plot the optimization surface if it is 2D
	if(s.plotOptimSurface ...
		&& (size(s.searchHistory,1) > 2) ...
		&& (size(s.scoreHistory,2) == 1) ...
		&& (size(s.searchHistory,2) == 2))

		if(isempty(s.plotHandle))
		    s.plotHandle = figure;
		end
		
		s.plotHandle = figure(s.plotHandle);

		try
		  plotScatteredData(s.searchHistory(:,1),s.searchHistory(:,2),log(s.scoreHistory),s.plotOptimSurfaceOpts);
		catch err
		  %ignore
		end
	end

catch err
	%these errors are hard to trace otherwise
	msg = err.message;
	msg = sprintf('Error during fitness evaluation: %s',msg);
	s.logger.severe(msg);
	printStackTrace( err.stack, s.logger, java.util.logging.Level.SEVERE );
	error(msg);
end
