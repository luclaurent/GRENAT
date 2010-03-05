function [minOut maxOut options] = quickPlotModel(model, outputIndex, inputs, options, fighandles)

% quickPlotModel (SUMO)
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
% Revision: $Rev: 6402 $
%
% Signature:
%	[minOut maxOut options] = quickPlotModel(model, outputIndex, inputs, options, fighandles)
%
% Description:
%	Plot 1 or 2 inputs of a model against one of it's outputs. Customize
%	the plot through the options parameter.
%	If options.showAllOutputs is true, you must pass as many figure
%	handles as there are outputs. Otherwise you must pass 1
%	handle or no handle (to use the current figure).
%	@param model			the model to plot
%	@param outputIndex	index of the output dimension to plot
%	@param inputs			axis indices, bounds and values for each input
%	@param options		plot customization options (must be complete!)
%	@param fighandles		figure handles for plotting in
%	Examples:
%	* Get the default options
%	[dummy1 dummy2 options] = quickPlotModel
%	* Simple plot
%	quickPlotModel(m,1)

defaults = struct(...
	'plotModel',	true,...	% toggle for plotting the model
	'plotPoints',	true,...	% toggle for plotting the samples
	'plotUncertainty', false,... % toggle for plotting the uncertainty
	'plotDerivatives',	false,...	% toggle for plotting the derivative
	'pointsDeviation',	10,...	% max deviation percentage in each non-plotted dimension's interval, from the value in that dimension
	'scalePoints',	true,...	% toggle for letting the point size depend on the distance to the current slice
	'lighting',		false,...	% toggle for enabling lighting
	'lightPos',		[0 0 50],...
	'lightStyle',	'infinite',...
	'keepCamera',	false,...	% toggle for copying the camera position of the previous plot
	'title',		'__auto__',... % set to '__auto__' to automatically generate a proper title
	'grayScale',	false,...
	'meshSize',		51,...		% size of evaluation grid
	'outputAxisRange',	[-1,1],... % range to clip the output axis to (enabled by clipOutput)
	'clipOutput',	false,...	% enabler for outputAxisRange
	'complexFix',	'real',...	% 'real', 'imaginary', 'modulus' or 'angle' % part of output to plot if it's complex
	'fontSize',		14,...		% size of title and axis labels
	'logScale',		false,...
	'contourLines',	true,...	% enabler for contour at bottom of 2D plot
	'plotType',		'1D', ...	% '1D', '2D' or 'contour' (1D, 2D: plot 1 or 2 inputs)
	'postFunction', [],...		% handle of a function with a figure handle as parameter, to call after each plot
	'showAllOutputs', false,... % enabler for showing all of the model's outputs, each in a separate plot window
	'elevationLabels',	false... % enabler for showing elevation labels on contour plot
);

if ((nargout == 3) && (nargin == 0))
	minOut = [];
	maxOut = [];
	options = defaults;
	return;
end

switch (nargin)
	case 1
		outputIndex = 1;
		inputs = defaultInputSettings(model);
		options = defaults;
		fighandles = gcf; % default is to plot only 1 output
	case 2
		inputs = defaultInputSettings(model);
		options = defaults;
		fighandles = gcf;
	case 3
		options = defaults;
		fighandles = gcf;
	case 4
		fighandles = gcf;
	case 5
		% everything is set
	otherwise
		error('Invalid number of arguments.');
end

if options.showAllOutputs
	[numInputs numOutputs] = getDimensions(model);
	% All outputs must be plotted, so the number of figure handles must match.
	assert(length(fighandles) == numOutputs,...
		'You must provide %i figure handles for plotting all outputs.',	numOutputs);
else
	assert(isscalar(fighandles), 'You must provide 1 figure handle for plotting 1 output.');
	fighandle = fighandles;
end
%set( fighandle, 'RendererMode', 'manual' );
%set( fighandle, 'Renderer', 'painters' );

% Do all processing that only depends on the inputs (and can be done for all outputs at once) here.
% linspace, evaluate, filterPoints, complexFix

% get the samples in simulator space
samples = getSamples(model);
vals = getValues(model);
steps = options.meshSize;

bounds = inputs.bounds;
values = inputs.values;
xIndex = inputs.xIndex;
yIndex = inputs.yIndex;
zIndex = inputs.zIndex;

plotData = struct;
switch options.plotType
	case '1D'
		if options.plotModel
			plotData.x = linspace(bounds(xIndex,1), bounds(xIndex,2), steps) .';
			plotData.y = model.evaluate(getInputMatrix(values, xIndex, plotData.x));
			plotData.y = complexFix(plotData.y, options.complexFix);
			
			% output matrix should be reshaped to this size, after
			% selecting which output to plot
			plotData.targetSize = size(plotData.x);
		end
		
		if(options.plotUncertainty)
				plotData.sigma = model.evaluateMSE(getInputMatrix(values, xIndex, plotData.x));
				plotData.sigma = complexFix(plotData.sigma, options.complexFix);
		end
		if options.plotDerivatives
			gridx = getInputMatrix(values, xIndex, plotData.x);
			
			plotData.dy = evaluateDerivative(model, gridx, outputIndex);
			plotData.dy = plotData.dy(:,xIndex);
			plotData.gridx = gridx(:,xIndex);
			
			if(options.plotUncertainty)
				plotData.dsigma = model.evaluateMSEDerivative(getInputMatrix(values, xIndex, plotData.x));
				plotData.dsigma = complexFix(plotData.sigma, options.complexFix);
			end
		end
			
		if options.plotPoints
			[samples vals sizes] = filterPoints(samples, vals, options.pointsDeviation,...
					options.scalePoints, bounds, values, xIndex);
			plotData.vals = complexFix(vals, options.complexFix);
			plotData.samples = samples;
			plotData.sizes = sizes;
		end
	case {'3D'}
		% Don't take it too fine, volumetric plot requires lots of data
		% 10*10*10 = 1000
		if options.meshSize > 10
			options.meshSize = 10;
			steps = 10;
		end
		if options.plotModel
			plotData.x1 = linspace(bounds(xIndex,1), bounds(xIndex,2),steps) .';
			plotData.x2 = linspace(bounds(yIndex,1), bounds(yIndex,2),steps) .';
			plotData.x3 = linspace(bounds(zIndex,1), bounds(zIndex,2),steps) .';
			[x1g,x2g x3g] = meshgrid(plotData.x1, plotData.x2, plotData.x3);

			plotData.y = evaluate(model, getInputMatrix(values, xIndex, x1g(:), ...
																yIndex, x2g(:), ...
																zIndex, x3g(:)));
			plotData.y = complexFix(plotData.y, options.complexFix);
			
			% output matrix should be reshaped to this size, after
			% selecting which output to plot
			plotData.targetSize = size(x1g);
		end
		if options.plotPoints
			[samples vals sizes] = filterPoints(samples, vals, options.pointsDeviation,...
					options.scalePoints, bounds, values, xIndex, yIndex);
			plotData.vals = complexFix(vals, options.complexFix);
			plotData.samples = samples;
			plotData.sizes = sizes;
		end
	case {'2D','contour'}
		plotData.x1 = linspace(bounds(xIndex,1), bounds(xIndex,2),steps) .';
		plotData.x2 = linspace(bounds(yIndex,1), bounds(yIndex,2),steps) .';
		[x1g,x2g] = meshgrid(plotData.x1, plotData.x2);
		
		if options.plotModel
			if ~options.plotUncertainty % prediction mean
				plotData.y = model.evaluate(getInputMatrix(values, xIndex, x1g(:), yIndex, x2g(:)));
			else % prediction variance
				plotData.y = model.evaluateMSE(getInputMatrix(values, xIndex, x1g(:), yIndex, x2g(:)));
			end
			plotData.y = complexFix(plotData.y, options.complexFix);
			
			% output matrix should be reshaped to this size, after
			% selecting which output to plot
			plotData.targetSize = size(x1g);
		end
			
		if options.plotPoints
			if options.plotUncertainty % prediction variance
				vals = model.evaluateMSE(samples);
			end
			
			[samples vals sizes] = filterPoints(samples, vals, options.pointsDeviation,...
						options.scalePoints, bounds, values, xIndex, yIndex);
			plotData.vals = complexFix(vals, options.complexFix);
			plotData.samples = samples;
			plotData.sizes = sizes;
		end
		if options.plotDerivatives
			gridx = getInputMatrix(values, xIndex, x1g(:), yIndex, x2g(:));
			
			if ~options.plotUncertainty % prediction mean
				plotData.dy = model.evaluateDerivative(gridx, outputIndex);
			else % prediction variance
				plotData.dy = model.evaluateMSEDerivative(gridx, outputIndex);
			end
			plotData.dy = plotData.dy(:,[xIndex yIndex]);
			plotData.gridx = gridx(:,[xIndex yIndex]);
		end
	otherwise
		error('Unknown plot type (%s)', options.plotType);
end

if options.showAllOutputs
	minOut = zeros(numOutputs,1);
	maxOut = zeros(numOutputs,1);
	for i=1:numOutputs
		% get the correct title
		options.title = options.titles{i};
		[minOut(i) maxOut(i)] = singlePlotModel(model, xIndex, yIndex, i,...
				options, fighandles(i), plotData);
	end
else
	% use the current title
	[minOut maxOut] = singlePlotModel(model, xIndex, yIndex, zIndex, outputIndex,...
			options, fighandle, plotData);
end

% Only call drawnow once for all outputs, this should make all plots
% refresh at once.
drawnow;


%--- Plot a single output of a model, in a single figure window.
function [minOut maxOut] = singlePlotModel(model, xIndex, yIndex, zIndex, outputIndex, options, fighandle, plotData)

%global fighandle_uncertainty

inputNames = getInputNames(model);
outputNames = getOutputNames(model);
outputName = outputNames{outputIndex};
prevAxes = get(fighandle, 'CurrentAxes');
camSettings = {};
lightSettings = {};

% only get the settings if there was an axis in the current figure, and
% the figure must not reset it's camera and light
if ishandle(prevAxes)
	if (strcmp(options.plotType,'2D') && options.lighting)
		% remember current light settings
		lights = findobj(get(prevAxes, 'Children'), 'flat', 'Type', 'light');
		numLights = length(lights);
		lightSettings = cell(numLights,1);
		for i = 1:numLights
			lightSettings{i} = struct(...
				'color', get(lights(i), 'Color'),...
				'style', get(lights(i), 'Style'),...
				'position', get(lights(i), 'Position'));
		end
	end
	if options.keepCamera
		% remember current camera settings
		camSettings = struct(...
			'up', camup(prevAxes),...
			'pos', campos(prevAxes),...
			'proj', camproj(prevAxes));
		if strcmp(camva(prevAxes, 'mode'), 'manual')
			% only set va if it is user specified (to preserve stretchToFill)
			camSettings.va = camva(prevAxes);
		end
		if strcmp(camtarget(prevAxes, 'mode'), 'manual')
			% only set target if it is user specified (to preserve centering)
			camSettings.target = camtarget(prevAxes);
		end
	end
end

clf(fighandle);

complexType = options.complexFix;
% add suffix to outputname if output is complex
if ~isreal(getValues(model))
	switch (complexType)
		case 'real'
			outputName = [outputName '_REAL'];
		case 'imaginary'
			outputName = [outputName '_IMAG'];
		case 'modulus'
			outputName = [outputName '_MOD'];
		case 'angle'
			outputName = [outputName '_ANGLE'];
		otherwise
			% shouldn't occur, show a warning
			warning('quickPlotModel:UnknownComplexType',...
					'Unknown complex type (%s), assuming real.', complexType);
			outputName = [outputName '_REAL'];
	end
end

%Plot title
if strcmp(options.title, '__auto__')
	plotTitle = sprintf('Plot of %s using %s\n(built with %d samples)',...
			outputName, class(model), size(getSamples(model),1));
else
	plotTitle = options.title;
end

% set some data regarding this model
if (strcmp(options.plotType, '1D'))
	data = struct( ...
		'model', model, ...
		'x1label', inputNames{xIndex}, 'x2label', outputName, ...
		'zlabel', '', ...
		'title', plotTitle ...
	);
else
	data = struct( ...
		'model', model, ...
		'x1label', inputNames{xIndex}, 'x2label', inputNames{yIndex}, ...
		'zlabel', outputName, ...
		'title', plotTitle ...
	);
end

% set the variables for plotting
if options.plotModel
	% select the correct output and reshape
	y = reshape(plotData.y(:,outputIndex),plotData.targetSize);
	
	if strcmp('1D', options.plotType)
		x = plotData.x;
	elseif strcmp('3D', options.plotType)
		x1 = plotData.x1;
		x2 = plotData.x2;
		x3 = plotData.x3;
	else
		x1 = plotData.x1;
		x2 = plotData.x2;
	end
end

if options.plotPoints
	% select the correct output
	vals = plotData.vals(:,outputIndex);
	samples = plotData.samples;
	sizes = plotData.sizes;
end

switch (options.plotType)
	case '1D'
		text = {};
		if options.plotModel
			plot(gca(fighandle),x,y, 'r-');
			text{end+1} = 'Surrogate model';
			
			% also plot the uncertainty if needed
			if(options.plotUncertainty)
				sigma = reshape(plotData.sigma(:,outputIndex),plotData.targetSize);
				
				hold(gca(fighandle), 'on');
				plot(gca(fighandle),x,y+sigma,'k-');
				plot(gca(fighandle),x,y-sigma,'k-');
				hold(gca(fighandle), 'off');
				
				text{end+1} = 'Prediction variance (upper)';
				text{end+1} = 'Prediction variance (lower)';
			end
		end
		if (options.plotPoints && (~isempty(samples)))
			hold(gca(fighandle), 'on'); % to prevent this scatterplot from replacing the model plot
			scatter(gca(fighandle),samples(:,xIndex), vals, sizes, 'o',...
					'filled', 'MarkerEdgeColor', 'k');
			hold(gca(fighandle), 'off');
			
			text{end+1} = 'Samples';
		end
		
		if options.plotDerivatives
			hold( gca(fighandle), 'on' );
			plot( gca(fighandle), plotData.gridx, plotData.dy, 'r--' );
			text{end+1} = 'Derivative of surrogate model';
			
			% also plot the derivatives of the uncertainty if needed
			if(options.plotUncertainty)
				dsigma = reshape(plotData.dsigma(:,outputIndex),plotData.targetSize);
				
				hold(gca(fighandle), 'on');
				plot(gca(fighandle),x,dsigma,'k--');
				hold(gca(fighandle), 'off');
				text{end+1} = 'Derivative of prediction variance';
			end
		end
		legend( gca(fighandle), text, 'Location', 'NorthEast' );
		
		%Set the range on the output axis
		if (options.clipOutput)
			set(fighandle,'Clipping','on');
			v = axis(gca(fighandle));
			axis(gca(fighandle), [v(1) v(2) options.outputAxisRange(1) options.outputAxisRange(2)]);
		end
		
		if(options.logScale)
			set(gca(fighandle),'YScale','log');
		end
		
	case 'contour'
		% mean of model
		if options.plotModel
			if options.elevationLabels
				% show the elevation labels
				[C,h] = contourf(gca(fighandle),x1,x2,y);
				clabel(C,h);
			else % don't show elevation labels
				%{
				lambda = 10.^model.getLambda()
				sigma2 = model.getProcessVariance()
				rho = sigma2 * lambda; % weight [0, 1] = sigma2_error
				rho = sqrt(rho); % = sigma_error
				l1 = min(model.getValues()) + 2.*rho % upper bound ?
				l2 = prctile( model.getValues(), 25 )
				l3 = prctile( model.getValues(), 50 )
				l4 = prctile( model.getValues(), 75 )
				[C h] = contour(gca(fighandle),x1,x2,y, [l1 l2 l3 l4]);
				clabel(C,h);
				%}
				contourf(gca(fighandle),x1,x2,y);
			end
		end
		if options.plotDerivatives
			hold( gca(fighandle), 'on' );
			quiver( gca(fighandle), plotData.gridx(:,1), plotData.gridx(:,2), plotData.dy(:,1), plotData.dy(:,2) );
		end
		if (options.plotPoints && (~isempty(samples)))
			hold(gca(fighandle), 'on');
			%scatter(gca(fighandle),samples(:,xIndex), samples(:,yIndex),...
			%		sizes, vals, 'o', 'filled', 'MarkerEdgeColor', 'k');
			scatter(gca(fighandle),samples(:,xIndex), samples(:,yIndex),...
					sizes,'k', 'o', 'filled', 'MarkerEdgeColor', 'k' );
			hold(gca(fighandle), 'off');
		end
		%Clip the colourmap
		if (options.clipOutput)
			caxis(gca(fighandle),options.outputAxisRange);
		end
        colorbar('peer', gca(fighandle));
	case '2D'
		% mean of model
		if options.plotModel
			if options.contourLines
				surfc(gca(fighandle),x1,x2,y);
			else
				surf(gca(fighandle),x1,x2,y);
			end
		end
		
		% Lighting only applies in '2D' plot mode.
		% Adding the light before plotting the points also avoids the bug
		% were the points become interconnected with lines.
		if options.lighting
			% Add some fancy lighting
			if isempty(lightSettings)
				light('Parent',gca(fighandle),'Position', options.lightPos, 'Style', options.lightStyle);
			else
				for i = 1:length(lightSettings)
					light('Parent',gca(fighandle),'Position', lightSettings{i}.position,...
							'Style', lightSettings{i}.style, 'Color', lightSettings{i}.color);
				end
			end
			lighting(gca(fighandle),'phong');
			shading(gca(fighandle),'interp');
		end
		
		if (options.plotPoints && (~isempty(samples)))
			hold(gca(fighandle), 'on');

			% with dynamic colour (visible when light is on, possibly
			% with a raytrace effect between the points)
			scatter3(gca(fighandle), samples(:,xIndex), samples(:,yIndex),...
					vals, sizes, 'k', 'o', 'filled', 'MarkerEdgeColor','k');

			% with fixed colour (invisible when light is on)
			%scatter3(gca(fighandle), samples(:,xIndex), samples(:,yIndex),...
			%		vals, sizes, 'ok', 'filled', 'MarkerEdgeColor','k');
			hold(gca(fighandle), 'off');
		end
		
		%Set the range on the output axis
		if (options.clipOutput)
			set(fighandle,'Clipping','on');
			v = axis(gca(fighandle));
			axis(gca(fighandle), [v(1) v(2) v(3) v(4) options.outputAxisRange(1) options.outputAxisRange(2) options.outputAxisRange(1) options.outputAxisRange(2)]);
		end

		if(options.logScale)
			set(gca(fighandle),'ZScale','log');
		end
	case '3D'
		figure(fighandle);
		hold off;
		% TODO: Doesn't plot the right coordinates on the axis yet...
		middle = round(options.meshSize./2);
		slice( gca(fighandle), x1, x2, x3, y, x1(middle), x2(middle), x3(middle) );
		colorbar;
		%slice( gca(fighandle), y, options.meshSize./2, options.meshSize./2, options.meshSize./2 );
		
		if (options.plotPoints && (~isempty(samples)))
			hold(gca(fighandle), 'on');

			% with dynamic colour (visible when light is on, possibly
			% with a raytrace effect between the points)
			scatter3(gca(fighandle), samples(:,xIndex), samples(:,yIndex),...
					samples(:,zIndex), sizes, sizes, 'o', 'filled', 'MarkerEdgeColor','k');

			% with fixed colour (invisible when light is on)
			%scatter3(gca(fighandle), samples(:,xIndex), samples(:,yIndex),...
			%		vals, sizes, 'ok', 'filled', 'MarkerEdgeColor','k');
			hold(gca(fighandle), 'off');
		end
	otherwise
		error('Unknown plot type (%s)', options.plotType);
end

% set the camera position
if (~isempty(camSettings))
	camup(gca(fighandle),camSettings.up);
	campos(gca(fighandle),camSettings.pos);
	if isfield(camSettings, 'va')
		camva(gca(fighandle),camSettings.va);
	end
	if isfield(camSettings, 'target')
		camtarget(gca(fighandle),camSettings.target);
	end
	camproj(gca(fighandle),camSettings.proj);
end

if (nargout == 2)
	if (options.plotModel)
		maxOut = max(y(:));
		minOut = min(y(:));
	else % no model plotted, so no model limits available
		maxOut = -Inf;
		minOut = Inf;
	end
	if (options.plotPoints && (~isempty(plotData.vals)))
		maxOut = max(maxOut,max(vals(:)));
		minOut = min(minOut,min(vals(:)));
	end
	% If nothing is plotted at all, the limits will stay [Inf,-Inf], so
	% check this if you have to!
end
set(gca(fighandle),'FontSize', options.fontSize);
title(gca(fighandle),plotTitle,'FontSize', options.fontSize,'interpreter','none');
xlabel(gca(fighandle),data.x1label, 'FontSize', options.fontSize,'interpreter','none');
ylabel(gca(fighandle),data.x2label, 'FontSize', options.fontSize,'interpreter','none');
zlabel(gca(fighandle),data.zlabel, 'FontSize', options.fontSize,'interpreter','none');

% set the color map (get the number of colors from the figure handle)
if(options.grayScale)
	colormap(gca(fighandle),gray(size(get(fighandle,'colormap'),1)));
else
	colormap(gca(fighandle),jet(size(get(fighandle,'colormap'),1)));
end

% Remove surrounding whitespace (TODO: not perfect yet)
%set(gca(fighandle), 'Position', get(gca(fighandle), 'OuterPosition')...
%		- get(gca(fighandle), 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

% call a user defined function that works on the plot figure
if isa(options.postFunction, 'function_handle')
	options.postFunction(fighandle); % pass the current figure as a parameter
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creates a matrix for evaluating the model
function res = getInputMatrix(varargin)
if (nargin ~= 3 && nargin ~= 5 && nargin ~= 7)
	error('getInputMatrix: invalid number of parameters (%i)', nargin);
end

values = varargin{1};
xAxis = varargin{2};
x = varargin{3};
res = values.';
res = repmat( res, length(x), 1 );
res(:,xAxis) = x(:);
if (nargin >= 5)
	yAxis = varargin{4};
	y = varargin{5};
	res(:,yAxis) = y(:);
end
if (nargin == 7)
	zAxis = varargin{6};
	z = varargin{7};
	res(:,zAxis) = z(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Filter the points by clipping along x and (optionally) y axis, and by
% comparing their value in the unplotted dimensions to the current value
% in those dimensions. The deviation percentage corresponds to the current
% interval size in each unplotted dimension.
function [samples vals sizes] = filterPoints(samples, vals, deviation, scalePoints, bounds, values, xIndex, yIndex)

% preallocate deviation vector (probably way too large, but it's better
% like this than growing by one each time a point is added)
deviations = zeros(1,size(samples,1));

% precalculate the max deviation in each dimension
devByDim = abs(bounds(:,2)-bounds(:,1))*deviation/100; % 100% == entire interval

j = 0;
for i=1:size(samples,1)
	keep = true;
	currDev = 0;
	for dim=1:size(values,1)
		x = samples(i,dim);
		if (dim == xIndex)
			if (x < bounds(xIndex,1)) || (x > bounds(xIndex,2))
				% outside current X-axis limits
				% fprintf(1, 'Outside X-axis: %d\n', x); % DEBUG
				keep = false;
				break;
			end
		% check y axis only when specified
		elseif (nargin == 8) && (dim == yIndex)
			if (x < bounds(yIndex,1)) || (x > bounds(yIndex,2))
				% outside current Y-axis limits
				% fprintf(1, 'Outside Y-axis: %d\n', x); % DEBUG
				keep = false;
				break;
			end
		elseif (abs(x-values(dim)) > devByDim(dim))
			keep = false;
			% fprintf(1, 'Outside dim %i: %d\n', dim, x); % DEBUG
			break;
		else
			% point not discarded yet, keep track of the total deviation
			% (relative to the allowed deviation in each interval)
			currDev = currDev + abs(x-values(dim))/devByDim(dim);
		end
	end
	if keep
		j = j+1;
		samples(j,:) = samples(i,:);
		vals(j,:) = vals(i,:);
		deviations(j) = currDev;
	end
end

samples = samples(1:j,:);
vals = vals(1:j,:);

% min and max point sizes (in points^2, for scatter and scatter3)
smallest = 3;
largest = 169;

% check how many dimensions are used for the deviations
if (nargin == 8)
	numDeviations = size(values,1) - 2;
else
	numDeviations = size(values,1) - 1;
end
% an exact match results in the largest size, the furthest away results in
% the smallest size
if ((numDeviations > 0) && scalePoints)
	sizes = largest - deviations(1:j)*((largest-smallest)/numDeviations);
else
	% no unplotted dimensions or no scaling
	sizes = 28; % all points are the same size
end

% fprintf(1, 'Kept %i points.\n', size(samples,1)); % DEBUG

