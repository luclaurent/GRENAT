function [fighandle options trainingStats validationStats] = guiPlotModelErrors(model, outputIndex, validation, options, parentHandle)

% guiPlotModelErrors (SUMO)
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
% Revision: $Rev: 6383 $
%
% Signature:
%	[fighandle options trainingStats validationStats] = guiPlotModelErrors(model, outputIndex, validation, options, parentHandle)
%
% Description:
%	Plot a model's error stats for a single output and print or return a
%	summary. If the summaries aren't requested as return values, they
%	will be printed on standard output.
%	All parameters except the model are optional. The options provided
%	are not required to be complete, they will be merged with the
%	defaults.
%	@param model				the model to get the stats for
%	@param outputIndex		index of the output dimension to show
%	@param validation			validation function or matrix (may be empty)
%	@param options			options for plotting and validation
%	@param parentHandle		handles of figure or panels to plot in
%	@return fighandle			handle of the figure were the errors were plotted
%	@return options			plot and validation options, defaults if not specified
%	@return trainingStats		cell array of strings with training stats summary
%	@return validationStats	cell array of strings with validation stats summary
%	Example:
%	* Show errors of a model's first output.
%	guiPlotModelErrors(model, 1)
%	* Show errors of a model's second output in a predefined panel and
%	  return the summary instead of printing it. Use the default options.
%	[dummy1 dummy2 trainingStats] = guiPlotModelErrors(model, 2, [], struct, panelHandle)
%	* Get the default options.
%	[dummy options] = guiPlotModelErrors

defaults = struct(...
	'maxValPoints',		50000, ...
	'fontSize',		11, ...
	'relativeErrors',		false, ...
    'db', false, ...
    'complexFix', 'modulus' ...
);

if(nargin == 0 && nargout == 2)
	fighandle = [];
	options = defaults;
	return;
end

switch nargin
	case 1
		outputIndex = 1;
		validation = [];
		options = defaults;
		parentHandle = figure;
	case 2
		validation = [];
		options = defaults;
		parentHandle = figure;
	case 3
		options = defaults;
		parentHandle = figure;
	case 4
		options = structMerge(options,defaults);
		parentHandle = figure;
	case 5
		options = structMerge(options,defaults);
	otherwise
		error('Invalid parameters given');
end

if(isempty(outputIndex))
	outputIndex = 1;
end

[numInputs numOutputs] = getDimensions(model);

%Ensure the outputIndex is not out of bounds
if((outputIndex < 1) || (outputIndex > size(getValues(model),2)))
	error('Error, outputIndex (%d) exceeds number of outputs (%d)',outputIndex,size(getValues(model),2));
end

% get the samples/values in simulator space
samples = getSamples(model);
values = getValues(model);
values = values(:,outputIndex);
numSamples = size(samples,1);

% calculate the sample errors
modelValues = evaluate(model,samples);
modelValues = modelValues(:,outputIndex);

sampleErrors = complexFix(values - modelValues, options.complexFix);
histLabel = '(absolute)';
if options.relativeErrors
    sampleErrors = sampleErrors ./ complexFix(values, options.complexFix);
    idx = find( isinf( sampleErrors ) );
    sampleErrors(idx,:) = sign( sampleErrors(idx, :) ) .* 10.^15;
    histLabel = '(relative)';
end

% should the errors be plotted in dB scale
if options.db
    sampleErrors = dB(sampleErrors);
    histLabel = [histLabel(1:end-1) ' in dB)'];
end

% Print out some model statistics
trainingStats = getStats(numSamples, values, modelValues);

if (nargout < 3)
	% display the stats if they aren't requested as a return value
	disp(char(trainingStats));
end

% plot the errors
numRows = 1;
if(~isempty(validation))
	numRows = 2;
end

%% Prediction errors (error in samples)

% histogram
subplot(2,numRows,1, 'Parent', parentHandle);
plotHist(sampleErrors, -1, 'FontSize', options.fontSize)
xlabel(['prediction error ' histLabel],'FontSize', options.fontSize, 'Interpreter','none')
title('Density plot','FontSize', options.fontSize, 'Interpreter','none');

% qqplot
subplot(2,numRows,2, 'Parent', parentHandle);
qqplotWrapper( [values, modelValues] )
xlabel('y','FontSize', options.fontSize, 'Interpreter','none')
ylabel('Predicted y','FontSize', options.fontSize, 'Interpreter','none');
title(['Quantile-quantile plot of the prediction errors'],'FontSize', options.fontSize, 'Interpreter','none');

%% Test set errors

% get data (dataset or function handle)
if(~isempty(validation))
	% is validation a validation set
	if(isa(validation,'double'))
		if (size(validation, 2) ~= (numInputs + numOutputs))
			error('Validation matrix dimensions must match the model dimensions.');
		end
		valSamples = validation(:,1:numInputs);
		valValues = validation(:,numInputs + outputIndex);	

	% is validation a function handle
	elseif(isa(validation,'function_handle'))
		% create our own validation grid (make sure we never use more than maxpoints)
		gridSize = floor(options.maxValPoints^(1/numInputs));

		% calculate the min/max range in each dimension
		[inFunc outFunc] = getTransformationFunctions(model);
		minRange = outFunc(-ones(1,numInputs));
		maxRange = outFunc(ones(1,numInputs));

		% generate the grid (equally spaced in all dimensions)
		grids = cell(numInputs,1);
		for i=1:numInputs
			grids{i} = linspace(minRange(i),maxRange(i),gridSize);
		end
		
		% generate an evaluation grid over the sample space
		valSamples = makeEvalGrid(grids);
		 % call the function handle to get the expected output values for the grid
		valValues = validation(valSamples);
		% take only the currently selected output
		valValues = valValues(:,outputIndex);
	else
		error('The validation data must be a matrix (samples and values as columns) or a function handle');
	end
	numSamples = size(valSamples,1); % number of validation samples
    
	%Evaluate the model on the validation grid
	modelValValues = evaluate(model,valSamples);
	modelValValues = modelValValues(:,outputIndex);

		%print some statistics on the validation data
	validationStats = getStats(numSamples, valValues, modelValValues);

	if (nargout < 4)
		% display the stats if they aren't requested as a return value
		disp(char(validationStats));
	end
	
	% plot the errors
	validationErrors = complexFix(valValues - modelValValues, options.complexFix);
	histLabel = '(absolute)';
    if options.relativeErrors
        validationErrors = validationErrors ./ complexFix(valValues, options.complexFix);
		idx = find( isinf( validationErrors ) );
		validationErrors(idx,:) = sign( validationErrors(idx, :) ) .* 10.^15;
		histLabel = '(relative)';
	end

	% should the errors be plotted in dB scale
	if options.db
		validationErrors = dB(validationErrors);
		histLabel = [histLabel(1:end-1) ' in dB)'];
	end
	
	% histogram
    subplot(2,numRows,3, 'Parent', parentHandle)
    plotHist(validationErrors, -1, 'FontSize', options.fontSize)
	xlabel(['prediction error ' histLabel],'FontSize', options.fontSize, 'Interpreter','none')
    title('Density plot of the test set errors','FontSize', options.fontSize, 'Interpreter','none');
    
    % qqplot
    subplot(2,numRows,4, 'Parent', parentHandle)
    qqplotWrapper( [valValues, modelValValues] )
    xlabel('y','FontSize', options.fontSize, 'Interpreter','none')
    ylabel('Predicted y','FontSize', options.fontSize, 'Interpreter','none');
    title('Quantile-quantile plot of the test set errors','FontSize', options.fontSize, 'Interpreter','none');
	
    %subplot( numRows, 2, [5 6 7 8], 'Parent', parentHandle );
else
	validationStats = [];
end

if (nargout > 0)
	fighandle = ancestor(parentHandle, 'figure' );
	assert(strcmp(get(fighandle, 'Type'), 'figure'), 'Error: failed to find figure handle');
end

%%%%%%%%%%%%%%%%%%%
	function stats = getStats(numSamples, values, modelValues)
	  stats = cell(16,2);
      
      stats(1,:) = {'samples' numSamples};
	  stats(2,:) = {'min value' min(values,[],1)};
	  stats(3,:) = {'max value' max(values,[],1)};
	  stats(4,:) = {'mean value',mean(values,1)};
	  stats(5,:) = {'mean absolute',meanAbsoluteError(values,modelValues)};
	  stats(6,:) = {'max absolute',maxAbsoluteError(values,modelValues)};
	  stats(7,:) = {'MSE',meanSquareError(values,modelValues)};
	  stats(8,:) = {'RMSE',rootMeanSquareError(values,modelValues)};
	  stats(9,:) = {'AEE',averageEuclideanError(values,modelValues)};
	  stats(10,:) = {'mean relative',meanRelativeError(values,modelValues)};
	  stats(11,:) = {'mean rel. (+1)',meanCombinedRelativeError(values,modelValues)};
	  stats(12,:) = {'max relative',maxRelativeError(values,modelValues)};
	  stats(13,:) = {'max rel.  (+1)',maxCombinedRelativeError(values,modelValues)};
	  stats(14,:) = {'R2',rSquared(values,modelValues)};
	  stats(15,:) = {'RRSE',rootRelativeSquareError(values,modelValues)};
	  stats(16,:) = {'BEEQ',beeq(values,modelValues)};
	end

end
