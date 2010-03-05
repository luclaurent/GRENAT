function s = updateLevelPlots( s, model )

% updateLevelPlots (SUMO)
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
%	s = updateLevelPlots( s, model )
%
% Description:
%	Update the levelplots

if(~s.makeLevelPlots)
	return;
end

nSamples = size( getSamplesInModelSpace( model ), 1 );
modelValues = evaluateInModelSpace( model, s.levelPlotSamples );
numOutputs = size(modelValues,2);

%are we dealing with a model with more than one output?
if(size(modelValues,2) ~= size(s.levelPlotValues,2))
	error(sprintf('The output dimension of the model (%d) does not match the output dimension of the levelplot object (%d), remember that the combineOutputs flag should have the same value for the LevelPlot and AdaptiveModelBuilder components',size(modelValues,2),size(s.levelPlotValues,2)));
else
	%update the profiler for each output
	for i=1:numOutputs
		prof = s.profilers{i};

		%Calculate the error
		errors = feval(s.errorFcn, s.levelPlotValues(:,i), modelValues(:,i));

		scale = 100.0 / length(errors(:));
		percentages = [];
		percentages(1) = sum( errors >= s.ticks(1) );
		for k=2:s.nTicks
			percentages(k) = sum( (errors < s.ticks(k-1)) & (errors >= s.ticks(k)) );
		end
		percentages(s.nTicks+1) = sum( errors < s.ticks(end) );
		
		tmp = percentages*scale;
		
		%Ensure the percentages always add up to 100
		tmp(end) = 100 - sum(tmp(1:end-1));
		
		if(s.samplingEnabled)
			%Adaptive sampling is switched on
			percentages = [nSamples tmp];
			prof.addEntry( percentages );
		else
			%Adaptive sampling is switched off, the same number of samples is used every iteration
			%so instead we use a counter for the x axis
			percentages = [ s.counter tmp];
			prof.addEntry( percentages );
		end
	end

	if(~s.samplingEnabled)
		s.counter = s.counter + 1;
	end
end
