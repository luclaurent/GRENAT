function [fighandle options] = guiPlotModel(model, outputIndex, inputs, options)

% guiPlotModel (SUMO)
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
%	[fighandle options] = guiPlotModel(model, outputIndex, inputs, options)
%
% Description:
%	This plotModel implementation visualises the model with a GUI to
%	choose the way the model is plotted.
%	All parameters are optional. If you specify a second output parameter
%	and no input parameters, the default plot options are returned
%	without further action. The options parameter will be merged with the
%	default options, so you need not specify all fields.
%	@param model			the model to plot
%	@param outputIndex	index of the output to plot
%	@param inputs			input settings (axis indices, bounds, values)
%	@param options		plot options (will be merged with defaults)
%	@return fighandle		handle of the plotted figure
%	@return options		the initial plot options
%	Examples:
%	* Show a load model dialog, use all default settings.
%	guiPlotModel
%	* Specify custom plot options, but use the default input settings.
%	guiPlotModel(model,1,defaultInputSettings(model),options)
%	* Just get the default plot options.
%	[dummy options] = guiPlotModel

[ta tb defaults] = quickPlotModel();
defaults.modelFilename = []; % name of the file containing the model
defaults.slices = 3; % number of slices in slice plot

if ((nargout == 2) && (nargin == 0))
	fighandle = [];
	options = defaults;
	return;
end

switch nargin
	case 0
		% load from file
		[model filename] = guiLoadModel();
		if isempty(model) % no model was loaded
			if (nargout > 0)
				fighandle = [];
			end
			return;
		end
		outputIndex = 1;
		inputs = defaultInputSettings(model);
		options = defaults;
		options.modelFilename = filename;
	case 1
		outputIndex = 1;
		inputs = defaultInputSettings(model);
		options = defaults;
	case 2
		inputs = defaultInputSettings(model);
		options = defaults;
	case 3
		options = defaults;
	case 4 % every parameter is set
		% Complete the options struct with the default options.
		options = structMerge(options, defaults);
	otherwise
		error('Invalid parameters given.');
end

%model = WrappedExtraModel(model);

[modelDim modelOutDim] = getDimensions(model);
if (nargin < 4) && (modelDim > 1)
	% default option for models with more than 1 input
	options.plotType = '2D';
end

% check that output index is not out of range
assert(isscalar(outputIndex) && (1 <= outputIndex) && (outputIndex <= modelOutDim),...
		'Error: outputIndex (%d) exceeds number of outputs (%d)',...
		outputIndex, modelOutDim);

% check that x index is in range
assert((1 <= inputs.xIndex) && (inputs.xIndex <= modelDim),...
		'Error: xIndex (%i) out of range for model with %i inputs.',...
		inputs.xIndex, modelDim);

% check that y index is in range
assert((1 <= inputs.yIndex) && (inputs.yIndex <= modelDim),...
		'Error: yIndex (%i) out of range for model with %i inputs.',...
		inputs.yIndex, modelDim);

if ~isfield(options, 'titles')
	% expand the single title to a separate title for each output
	options.titles = cell(modelOutDim,1);
	for i=1:modelOutDim
		options.titles{i} = options.title;
	end
elseif (length(options.titles) ~= modelOutDim)
	% incorrect number of titles
	error('Error: the number of passed plot titles (%d) does not match the number of outputs (%d).',...
			length(options.titles), modelOutDim);
end

% Generate a globally unique name for the model.
% 1) All input and output names are concatenated together.
modelName = '';
inputNames = getInputNames(model);
outputNames = getOutputNames(model);
for i = 1:length(inputNames)
	modelName = strcat(modelName, inputNames{i});
end
for i = 1:length(outputNames)
	modelName = strcat(modelName, outputNames{i});
end
% 2) Form the unique name by concatenating input and output dimensions and
% a hash from the concatenated input and output names.
% * Also remove all illegal characters (although there probably aren't any).
modelName = genvarname(sprintf('m%ix%i_%s', modelDim, modelOutDim, hashString(modelName)));

if (~any(strcmp(options.complexFix, {'real','imaginary','modulus','angle'})))
	error('Error: invalid complex fix given (%s)', options.complexFix);
end

if (~any(strcmp(options.plotType, {'1D','2D','contour'})))
	error('Error: invalid plot type given (%s)', options.plotType);
end

if ((length(options.outputAxisRange) ~= 2) || (options.outputAxisRange(1) >= options.outputAxisRange(2)))
	error('Invalid output axis range.');
end

% check bounds dimensions
if ((size(inputs.bounds,1) ~= modelDim) || (size(inputs.bounds,2) ~= 2))
	error('Error: bounds (%dx%d) does not specify all bounds for all input dimensions (%d)',size(inputs.bounds,1),size(inputs.bounds,2),modelDim);
end

% check values dimensions
if ((size(inputs.values,1) ~= modelDim) || (size(inputs.values,2) ~= 1))
	error('Error: wrong number of values (%d) for %d-dimensional model', size(inputs.values, 1), modelDim);
end

% get the correct console handle if it exists
consoleHandle = modelConsoleHandler(modelName);
if ((~isempty(consoleHandle)) && ishandle(consoleHandle))
	guiConsole('guiConsole_UpdateModel',consoleHandle,[],guidata(consoleHandle),model,outputIndex, inputs, options);
else
	% or create a new set of plots (1 per output) and a single console
	plotHandles = zeros(1,modelOutDim);
	for i=1:modelOutDim
		plotHandles(i) = figure('Tag',modelName,'CloseRequestFcn',@closePlot_Callback,...
				'UserData', struct('mustHide', true), 'Visible', 'off');
	end
	
	consoleHandle = guiConsole(model, outputIndex, inputs, options, plotHandles, @closeConsole_Callback);
	set(consoleHandle, 'Tag', modelName);
	modelConsoleHandler(modelName, consoleHandle);
end

if (nargout > 0)
	% return figure handle
	userdata = get(consoleHandle, 'UserData');
	fighandle = userdata.figures(userdata.outputIndex);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Keeps a global variable with the handles to open consoles. Their tags
% should at least be different when the number of input and output
% dimensions is different.
% input: modelName[, handle]
% output: [handle]
function varargout = modelConsoleHandler(varargin)

global modelConsole;
if (nargin == 2)
	% 2 arguments == delete or add handle
	if isempty(varargin{2})
		% delete the console handle from the global variable
		modelConsole = rmfield(modelConsole,varargin{1});
	else
		% add the console handle to the global variable
		modelConsole.(varargin{1}) = varargin{2};
	end
end
if (nargout == 1)
	% find the console handle in the global variable
	if isfield(modelConsole, varargin{1})
		% console exists, return handle
		varargout{1} = modelConsole.(varargin{1});
	else
		% console doesn't exist, return empty matrix
		varargout{1} = [];
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If the console is still open, the plot window will be hidden,
% otherwise it will be deleted.
function closePlot_Callback(hObject, eventdata)

userdata = get(hObject, 'UserData');
if (isfield(userdata, 'mustHide') && userdata.mustHide)
    % console is still open, hide the figure
	set(hObject, 'Visible', 'off');
	% fprintf(1, 'Plot %d hidden.\n', hObject); % DEBUG
else
    % console is already closed, close the figure
	delete(hObject);
	% fprintf(1, 'Plot %d closed.\n', hObject); % DEBUG
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove the console figure from the global variable when the console is
% closed
function closeConsole_Callback(hObject, eventdata)

userdata = get(hObject, 'UserData');
% Try deleting from the global. If it fails, just close the figure.
try
	modelConsoleHandler(get(hObject,'Tag'), []);
catch
	fprintf(2, 'Error: unable to delete console %i. Switching to simple close.\n',...
			hObject);
end

% Check whether the figure references exists before acting on them.
if (isstruct(userdata) && isfield(userdata, 'figures'))
	for fighandle = userdata.figures
		% check each handle separately
		if (ishandle(fighandle))
			if strcmp(get(fighandle, 'Visible'), 'off')
				% plot already invisible -> delete it
				delete(fighandle);
				% fprintf(1, 'Deleted hidden plot %d.\n', fighandle); % DEBUG
			else
				% plot is visible -> tell it to close instead of hide
				figdata = get(fighandle, 'UserData');
				figdata.mustHide = false;
				set(fighandle, 'UserData', figdata);
				% fprintf(1, 'Set plot %d to close instead of hide.\n', fighandle); % DEBUG
			end
		end
	end
end
delete(hObject);
% fprintf(1, 'Console %d closed.\n', hObject); % DEBUG

