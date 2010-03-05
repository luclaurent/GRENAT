function [movieOptions plotOptions] = genMovie(model, outputIndex, inputs, plotOptions, fighandle, movieOptions)

% genMovie (SUMO)
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
%	[movieOptions plotOptions] = genMovie(model, outputIndex, inputs, plotOptions, fighandle, movieOptions)
%
% Description:
%	Create a movie by varying over a chosen dimension. Get the default
%	movie options and plot options as a return value by specifying zero parameters.
%	The slices will be saved in a subdirectory 'slices' at the location
%	of the movie. All previously existing png and fig files will be
%	deleted from that directory. The plot and movie options will be
%	merged with the defaults, so you need not specify all fields.
%	@param model			the model whereof a movie must be created
%	@param outputIndex	the index of the output dimension to plot
%	@param inputs			input settings: xIndex, yIndex, zIndex (varies over time), bounds and values
%	@param plotOptions	plot options
%	@param fighandle		handle of the figure to plot in
%	@param movieOptions	movie options
%	Examples:
%	* Create a movie of the second output.
%	genMovie(model,2)
%	* Get the default movie and plot options.
%	[movieOptions plotOptions] = genMovie

movieDefaults = struct(...
		'numSlices',	51,...		% number of slices to create
		'fps',		3,...			% frames per second in the movie
		'outputFile',	'movie.avi',... % file to save the movie to
		'quality',	100,...			% compression quality (applicable if compression type supports it)
		'fixAxis',	true,...		% set the output axes the same in each slice
		'showSliceTitle',	true... % show the slice value in the title of each plot
	);
[xa xb plotDefaults] = quickPlotModel();

if (nargin == 0 && nargout > 0)
	% only the default options are requested
	movieOptions = movieDefaults;
	plotOptions = plotDefaults;
	return;
end
switch nargin
	case 1
		outputIndex = 1;
		inputs = defaultInputSettings(model);
		plotOptions = plotDefaults;
		fighandle = gcf;
		movieOptions = movieDefaults;
	case 2
		inputs = defaultInputSettings(model);
		plotOptions = plotDefaults;
		fighandle = gcf;
		movieOptions = movieDefaults;
	case 3
		plotOptions = plotDefaults;
		fighandle = gcf;
		movieOptions = movieDefaults;
	case 4
		% merge the provided plot options with the defaults
		plotOptions = structMerge(plotOptions, plotDefaults);
		fighandle = gcf;
		movieOptions = movieDefaults;
	case 5
		% merge the provided plot options with the defaults
		plotOptions = structMerge(plotOptions, plotDefaults);
		movieOptions = movieDefaults;
	case 6
		% everything is set
		% merge the provided plot options with the defaults
		plotOptions = structMerge(plotOptions, plotDefaults);
		% merge the provided movie options with the defaults
		movieOptions = structMerge(movieOptions, movieDefaults);
	otherwise
		error('Invalid argument count!');
end

if (nargin < 3) && (getDimensions(model) > 2)
	% default plot type for movies of models with 3 or more inputs
	plotOptions.plotType = '2D';
end

import java.util.logging.*;
logger = Logger.getLogger('Matlab.genMovie');

imagetype = 'png';
if (movieOptions.fixAxis)
	extension = '.fig';
else
	extension = ['.' imagetype];
end
% get the directory where the output file should be stored
movieDir = fileparts(movieOptions.outputFile);
% the directory where slices will be saved
picsDir = fullfile(movieDir, 'slices');

% remove existing slices from the slices dir, to avoid inclusion in movie
delete(fullfile(picsDir, ['*.' imagetype]));
if (movieOptions.fixAxis)
	% also delete temporary files
	delete(fullfile(picsDir, ['*' extension]));
end

% create the slices directory (if it doesn't exist)
mkdir(picsDir);

% the steps to generate slices for
steps = linspace(inputs.bounds(inputs.zIndex,1),inputs.bounds(...
		inputs.zIndex,2),movieOptions.numSlices);

% save the current graph title, add a newline if non-empty (to print
% the current value of the varying axis on a new line)
if (movieOptions.showSliceTitle)
	inputNames = getInputNames(model);
	originalTitle = plotOptions.title;
	plotTitle = originalTitle;
	if ~strcmp(plotTitle, '')
		plotTitle = sprintf('%s\n', plotTitle);
	end
	plotTitle = [plotTitle inputNames{inputs.zIndex} ' = '];
end

maxOutput = -Inf;
minOutput = Inf;

numSteps = length(steps);
logger.info(sprintf('Generating %i slices.', numSteps));
for i = 1:numSteps;
	logger.finer(sprintf('Generating slice %i.',i));
	inputs.values(inputs.zIndex) = steps(i);
	
	if (movieOptions.showSliceTitle)
		plotOptions.title = [plotTitle num2str(steps(i))];
	end
	[tmpMin tmpMax] = quickPlotModel(model, outputIndex, inputs,...
			plotOptions, fighandle);
	
	minOutput = min(tmpMin,minOutput);
	maxOutput = max(tmpMax,maxOutput);
	
	% how many zero's before the file name? (to ensure correct order)
	numZeros = floor(log10(movieOptions.numSlices))-floor(log10(i));
	padding = char(ones(1,numZeros)*double('0'));
	
	saveas(fighandle,fullfile(picsDir, [padding num2str(i) extension]));
end
logger.info('Slices generated.');

if (movieOptions.showSliceTitle)
	% restore the title to it's original value
	title(gca(fighandle), originalTitle, 'FontSize',plotOptions.fontSize, 'interpreter','none');
end

if movieOptions.fixAxis
	xMin = inputs.bounds(inputs.xIndex,1);
	xMax = inputs.bounds(inputs.xIndex,2);
	if strcmp(plotOptions.plotType, '1D')
		% Only 1 input is plotted, the Y-axis is the output.
		yMin = minOutput;
		yMax = maxOutput;
	else
		% 2 inputs plotted, Y-axis is specified by yIndex.
		yMin = inputs.bounds(inputs.yIndex,1);
		yMax = inputs.bounds(inputs.yIndex,2);
	end
	if (minOutput < maxOutput)
		% limits for colour could be left at default, but it's clearer with
		% them
		axisSettings = [xMin xMax yMin yMax minOutput maxOutput minOutput maxOutput];
	else
		warnString = sprintf('Output limits are not ordered correctly ([%d,%d]), not fixing output axis.', minOutput, maxOutput);
		logger.warning(warnString);
		warning('genMovie:WrongOutputLimits', warnString);
		% don't specify the axis parameters
		axisSettings = [];
		% but we still need to convert from fig to png
	end
	plotFixedAxis(picsDir, imagetype, axisSettings);
end

images2movie(picsDir, movieOptions.outputFile, 'png', movieOptions.fps, movieOptions.quality);
