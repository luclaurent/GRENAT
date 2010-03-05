function varargout = guiConsole(varargin)

% guiConsole (SUMO)
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
%	varargout = guiConsole(varargin)
%
% Description:
%	GUI source file with callback definitions and other functions.
%	Normally you would not call this file directly, but use guiPlotModel
%	instead. This function requires valid parameters, as checked by
%	guiPlotModel.

% GUICONSOLE M-file for guiConsole.fig
%      GUICONSOLE, by itself, creates a new GUICONSOLE or raises the existing
%      singleton*.
%
%      H = GUICONSOLE returns the handle to a new GUICONSOLE or the handle to
%      the existing singleton*.
%
%      GUICONSOLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUICONSOLE.M with the given input arguments.
%
%      GUICONSOLE('Property','Value',...) creates a new GUICONSOLE or
%      raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiConsole_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiConsole_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiConsole

% Last Modified by GUIDE v2.5 07-Dec-2009 16:00:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiConsole_OpeningFcn, ...
                   'gui_OutputFcn',  @guiConsole_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end
% End initialization code - DO NOT EDIT

%--- Add all gui objects for managing the model input parameters
% everything is already present for 1D input
function setModelInputGUI(handles)
	% all units should be the same

	userdata = get(handles.output, 'UserData');
	dim = getDimensions(userdata.model);

	% create lists to accomodate each val, min, max, slider, text object
	userdata.handles = struct;
	userdata.handles.labels = zeros(dim,1);
	userdata.handles.values = zeros(dim,1);
	userdata.handles.min = zeros(dim,1);
	userdata.handles.max = zeros(dim,1);
	userdata.handles.sliders = zeros(dim,1);
	userdata.handles.radioX = zeros(dim,1);
	userdata.handles.radioY = zeros(dim,1);

	% add the already present dimension to the list (last position)
	userdata.handles.labels(dim) = handles.labelX1;
	userdata.handles.values(dim) = handles.valueX1;
	userdata.handles.min(dim) = handles.minX1;
	userdata.handles.max(dim) = handles.maxX1;
	userdata.handles.sliders(dim) = handles.sliderX1;
	userdata.handles.radioX(dim) = handles.radioX1;
	userdata.handles.radioY(dim) = handles.radioY1;

	inputNames = getInputNames(userdata.model);
	% set the label of the already present slider
	set(handles.labelX1, 'String',inputNames{dim});
	if (dim < 2)
		set(handles.plotTypePopup, 'Enable', 'off');
		% rest is already disabled later on
		% no further action needed
	else
		% remember the default GUI units
		oldUnits = get(handles.maxX1, 'Units');
		units = 'characters'; % units used here
		usedHandles = [handles.maxX1 handles.labelX1 handles.valueX1 handles.minX1...
				handles.sliderX1 handles.output handles.modelinput handles.radioX...
				handles.radioY handles.labelheader handles.valueheader...
				handles.minheader handles.maxheader handles.radioX1 handles.radioY1];
		topLevelHandles = [handles.modeloutput handles.plotoptions...
				handles.createmoviebutton handles.modelinfobutton...
				handles.loadbutton];
		% set units of all used handles to the units used in this function
		% (to make sure the units are not normalized)
		set(usedHandles, 'Units', units);
		% also set the units of all top-level objects to those units
		% (we must make sure they are not normalized when resizing the figure)
		set(topLevelHandles, 'Units', units);
		position = get(handles.maxX1, 'Position'); % maybe a little wider?
		heightPerDim = position(4);
		extraHeight = (dim-1)*heightPerDim; % height needed per input dimension

		% enlarge panels
		list = [handles.output handles.modelinput handles.radioX handles.radioY];
		for i=1:length(list)
			position = get(list(i), 'Position');
			position(4) = position(4) + extraHeight;
			set(list(i), 'Position', position);
		end

		% move label, value, min and max texts up
		list = [handles.labelheader handles.valueheader handles.minheader handles.maxheader];
		for i=1:length(list)
			position = get(list(i), 'Position');
			position(2) = position(2) + extraHeight;
			set(list(i), 'Position', position);
		end

		% add correct number of radio buttons
		position = get(handles.radioX1, 'Position');
		position(2) = position(2) + extraHeight; % start at the top
		for i=1:dim-1
			userdata.handles.radioX(i) = uicontrol(handles.radioX, 'Style','radiobutton',...
					'String','', 'Value',0, 'Units',units, 'Position',position,...
					'Interruptible','off');
			position(2) = position(2) - heightPerDim;
		end

		position = get(handles.radioY1, 'Position');
		position(2) = position(2) + extraHeight; % start at the top
		for i=1:dim-1
			userdata.handles.radioY(i) = uicontrol(handles.radioY, 'Style','radiobutton',...
					'String','', 'Value',0, 'Units',units, 'Position',position,...
					'Interruptible','off');
			position(2) = position(2) - heightPerDim;
		end

		% create all the panels, sliders... in a top-down way

		bgColour = get(handles.labelX1, 'BackgroundColor');

		labelpos = get(handles.labelX1, 'Position');
		labelpos(2) = labelpos(2) + extraHeight; % start at the top
		labelCreateFcn = get(handles.labelX1, 'CreateFcn');
		labelCallback = get(handles.labelX1, 'Callback');

		valuepos = get(handles.valueX1, 'Position');
		valuepos(2) = valuepos(2) + extraHeight; % start at the top
		valueCreateFcn = get(handles.valueX1, 'CreateFcn');
		valueCallback = get(handles.valueX1, 'Callback');

		minpos = get(handles.minX1, 'Position');
		minpos(2) = minpos(2) + extraHeight; % start at the top
		minCreateFcn = get(handles.minX1, 'CreateFcn');
		minCallback = get(handles.minX1, 'Callback');

		maxpos = get(handles.maxX1, 'Position');
		maxpos(2) = maxpos(2) + extraHeight; % start at the top
		maxCreateFcn = get(handles.maxX1, 'CreateFcn');
		maxCallback = get(handles.maxX1, 'Callback');

		sliderpos = get(handles.sliderX1, 'Position');
		sliderpos(2) = sliderpos(2) + extraHeight; % start at the top
		sliderCreateFcn = get(handles.sliderX1, 'CreateFcn');
		sliderCallback = get(handles.sliderX1, 'Callback');
		sliderStep = get(handles.sliderX1, 'SliderStep');

		for i=1:dim-1
			userdata.handles.labels(i) = uicontrol(handles.modelinput, 'Style','edit',...
					'BackgroundColor',bgColour, 'String',inputNames{i},...
					'Units',units, 'Position',labelpos, 'CreateFcn',labelCreateFcn,...
					'Callback', labelCallback, 'Interruptible','off');
			userdata.handles.values(i) = uicontrol(handles.modelinput, 'Style','edit',...
					'BackgroundColor',bgColour,'Units',units, 'Position',valuepos,'String','0',...
					'CreateFcn', valueCreateFcn,...
					'Callback', valueCallback, 'Interruptible', 'off');
			userdata.handles.min(i) = uicontrol(handles.modelinput, 'Style','edit',...
					'BackgroundColor',bgColour, 'Units',units, 'Position',minpos,'String','-1',...
					'CreateFcn',minCreateFcn,'Callback',minCallback,...
					'Interruptible','off');
			userdata.handles.max(i) = uicontrol(handles.modelinput, 'Style','edit',...
					'BackgroundColor',bgColour, 'Units',units, 'Position',maxpos,'String','1',...
					'CreateFcn',maxCreateFcn,...
					'Callback',maxCallback, 'Interruptible', 'off');
			userdata.handles.sliders(i) = uicontrol(handles.modelinput, 'Style','slider',...
					'Max',1, 'Min',-1, 'Value',0, 'SliderStep', sliderStep,...
					'Units',units, 'Position',sliderpos, 'CreateFcn',sliderCreateFcn,...
					'Callback',sliderCallback, 'Interruptible','off', 'BusyAction','cancel');

			% go one position lower
			labelpos(2) = labelpos(2) - heightPerDim;
			valuepos(2) = valuepos(2) - heightPerDim;
			minpos(2) = minpos(2) - heightPerDim;
			maxpos(2) = maxpos(2) - heightPerDim;
			sliderpos(2) = sliderpos(2) - heightPerDim;
		end

		% set all used handles and new handles to the correct units
		set(usedHandles, 'Units', oldUnits);
		set(userdata.handles.radioX, 'Units', oldUnits);
		set(userdata.handles.radioY, 'Units', oldUnits);
		set(userdata.handles.labels, 'Units', oldUnits);
		set(userdata.handles.values, 'Units', oldUnits);
		set(userdata.handles.min, 'Units', oldUnits);
		set(userdata.handles.max, 'Units', oldUnits);
		set(userdata.handles.sliders, 'Units', oldUnits);
		% also set the top-level handles back to normal
		set(topLevelHandles, 'Units', oldUnits);	
	end

	% save user data structure
	set(handles.output, 'UserData', userdata);
end


%--- Update the settings of all uicontrols according to the current options
function updateControls(handles)
	userdata = get(handles.output, 'UserData');

	% check box'es
	set(handles.pointscheck, 'Value', userdata.options.plotPoints);
	set(handles.clipcheck, 'Value', userdata.options.clipOutput);
	set(handles.keepcameracheck, 'Value', userdata.options.keepCamera);
	set(handles.showallcheck, 'Value', userdata.options.showAllOutputs);

	set(handles.msecheck, 'Value', userdata.options.plotUncertainty);
	try
		userdata.model.evaluateMSE( zeros(1, length(userdata.defaultInputNames) ) );			
	catch e
		% MSE not supported by model
		set(handles.msecheck,'Value', false);
		set(handles.msecheck,'Enable', 'off');
	end
		
	% menu check items (some may be duplicate of above)
	set(handles.menu_plotsamples, 'Checked', menuItemCheck(userdata.options.plotPoints ) );
	set(handles.menu_plotderivatives, 'Checked', menuItemCheck(userdata.options.plotDerivatives) );
	set(handles.menu_lighting, 'Checked', menuItemCheck(userdata.options.lighting) );
	set(handles.menu_grayscale, 'Checked', menuItemCheck(userdata.options.grayScale) );
	set(handles.menu_contourlines, 'Checked', menuItemCheck(userdata.options.contourLines) );
	set(handles.menu_scalepoints, 'Checked', menuItemCheck(userdata.options.scalePoints) );
	set(handles.menu_logscale, 'Checked', menuItemCheck(userdata.options.logScale) );


	set(handles.cliplower, 'String', userdata.options.outputAxisRange(1));
	set(handles.clipupper, 'String', userdata.options.outputAxisRange(2));
	set(handles.meshfield, 'String', userdata.options.meshSize);

	outputNames = getOutputNames(userdata.model);
	set(handles.outputpopup, 'String', outputNames);
	set(handles.outputpopup, 'Value', userdata.outputIndex);

	% set the points deviation percentage edit and popup boxes
	devStr = [num2str(userdata.options.pointsDeviation) ' %'];
	% add or find the percentage in the popup, starting from the default options
	[devList devIndex] = matchString(devStr, userdata.defaultPointspopup);
	set(handles.pointspopup, 'String', devList);
	set(handles.pointspopup, 'Value', devIndex);

	if (length(outputNames) == 1)
		set(handles.outputpopup, 'Enable', 'off');
	else
		set(handles.outputpopup, 'Enable', 'on');
	end

	inputNames = getInputNames(userdata.model);
	for i=1:length(inputNames)
		set(userdata.handles.labels(i), 'String', inputNames{i});
	end

	for i=1:size(userdata.inputs.bounds,1)
		set(userdata.handles.min(i), 'String', userdata.inputs.bounds(i,1));
		set(userdata.handles.max(i), 'String', userdata.inputs.bounds(i,2));
		set(userdata.handles.values(i), 'String', userdata.inputs.values(i));
		set(userdata.handles.sliders(i), 'Min', userdata.inputs.bounds(i,1));
		set(userdata.handles.sliders(i), 'Max', userdata.inputs.bounds(i,2));
		set(userdata.handles.sliders(i), 'Value', userdata.inputs.values(i));
	end

	set(handles.radioX, 'SelectedObject', userdata.handles.radioX(userdata.inputs.xIndex));
	if (getDimensions(userdata.model) > 1)
		set(handles.radioY, 'SelectedObject', userdata.handles.radioY(userdata.inputs.yIndex));
		set(handles.plotTypePopup, 'Enable', 'on');
		set(userdata.handles.radioX, 'Enable', 'on'); % enable all radioX handles at once
	else
		set(handles.radioY, 'SelectedObject', []);
		set(handles.plotTypePopup, 'Enable', 'off');
		%set(handles.radioX, 'Enable', 'off');
	end

	correctEnabled(handles);

	setPlotType(handles);
	setComplexFix(handles);
	setWindowName(handles.output,userdata.figures,userdata.model,userdata.options);
	setPlotVisibility(userdata.figures, userdata.outputIndex, userdata.options.showAllOutputs);
	toggleReload(handles.reloadmenu, userdata.options);
end

%-- Enable or disable the reload gui object(s)
function toggleReload(reloadHandle, options)
	if isempty(options.modelFilename)
		set(reloadHandle, 'Enable', 'off');
	else
		set(reloadHandle, 'Enable', 'on');
	end
end

%--- Correctly set the complexFix popup
function setComplexFix(handles)
	userdata = get(handles.output, 'UserData');

	switch (userdata.options.complexFix)
		case 'real'
			set(handles.complexFixPopup, 'Value', 1);
		case 'imaginary'
			set(handles.complexFixPopup, 'Value', 2);
		case 'modulus'
			set(handles.complexFixPopup, 'Value', 3);
		case 'angle'
			set(handles.complexFixPopup, 'Value', 4);
		otherwise
			warning('guiConsole:setComplexFix:UnknownComplexFix',...
					'Unknown complex fix (%s), assuming real.', options.complexFix);
			set(handles.complexFixPopup, 'Value', 1);
	end

	% reset the title, the complex fix setting affects it by default
	userdata.keepTitle = userdata.keepTitle * false;
	set(handles.output, 'UserData', userdata);
end

%--- Set the window name of the console and all figure windows
% The console name will include the model file name, the figure windows
% will include the output name.
function setWindowName(consoleHandle, plotHandles, model, options)
	commonName = class(model);

	if isempty(options.modelFilename)
		fileSuffix = '';
	else
		fileSuffix = [' - ' options.modelFilename];
	end

	% Console doesn't have NumberTitle, Figure (plot) window does have it.
	% Use mat2str to convert a vector of figure handles to a matlab style
	% matrix string, e.g. [2 3 4].
	set(consoleHandle, 'Name', sprintf('Console %s - %s%s', mat2str(plotHandles), commonName, fileSuffix));
	outputNames = getOutputNames(model);
	for outputIndex=1:length(plotHandles)
		set(plotHandles(outputIndex), 'Name', sprintf('%s - %s', commonName, outputNames{outputIndex}));
	end
end

%--- Set the plot type and adjust gui
function setPlotType(handles)
	userdata = get(handles.output, 'UserData');
	switch (userdata.options.plotType)
		case '1D'
			set(handles.plotTypePopup, 'Value', 1);
			yAxisStatus = 'off';		
			ySliderStatus = 'on';
			zAxisStatus = 'off';
			zSliderStatus = 'on';
			nrDimPlotted = 1;
			set(handles.menu_contourlines, 'Enable', 'off');
			set(handles.menu_lighting, 'Enable', 'off');
			set(handles.menu_grayscale, 'Enable', 'off');
			set(handles.menu_logscale, 'Enable', 'on');
			set(handles.menu_plotderivatives, 'Enable', 'on');
		case '2D'
			set(handles.plotTypePopup, 'Value', 2);
			yAxisStatus = 'on';
			ySliderStatus = 'off';
			zAxisStatus = 'off';
			zSliderStatus = 'on';
			nrDimPlotted = 2;
			set(handles.menu_contourlines, 'Enable', 'on');
			set(handles.menu_lighting, 'Enable', 'on');
			set(handles.menu_grayscale, 'Enable', 'on');
			set(handles.menu_logscale, 'Enable', 'on');
			set(handles.menu_plotderivatives, 'Enable', 'off');
		case '3D'
			set(handles.plotTypePopup, 'Value', 3);
			yAxisStatus = 'on';
			ySliderStatus = 'off';
			zAxisStatus = 'on';
			zSliderStatus = 'off';
			nrDimPlotted = 3;		
			set(handles.menu_contourlines, 'Enable', 'off');
			set(handles.menu_lighting, 'Enable', 'off');
			set(handles.menu_grayscale, 'Enable', 'off');
			set(handles.menu_logscale, 'Enable', 'off');
			set(handles.menu_plotderivatives, 'Enable', 'off');
		case 'contour'
			set(handles.plotTypePopup, 'Value', 3);
			yAxisStatus = 'on';
			ySliderStatus = 'off';
			zAxisStatus = 'off';
			zSliderStatus = 'on';
			nrDimPlotted = 2;
			set(handles.menu_contourlines, 'Enable', 'off');
			set(handles.menu_lighting, 'Enable', 'off');
			set(handles.menu_grayscale, 'Enable', 'on');
			set(handles.menu_logscale, 'Enable', 'off');
			set(handles.menu_plotderivatives, 'Enable', 'on');
		otherwise
			warning('guiConsole:setPlotType:UnknownPlotType',...
					'Unknown plot type (%s), assuming 1D', userdata.options.plotType);
			set(handles.plotTypePopup, 'Value', 1);
			yAxisStatus = 'off';
			ySliderStatus = 'on';
			zAxisStatus = 'off';
			zSliderStatus = 'on';
			nrDimPlotted = -1;
			set(handles.menu_contourlines, 'Enable', 'off');
			set(handles.menu_lighting, 'Enable', 'off');
			set(handles.menu_grayscale, 'Enable', 'off');
			set(handles.menu_logscale, 'Enable', 'on');
			set(handles.menu_plotderivatives, 'Enable', 'off');
    end
    
    set(handles.menu_plotderivatives, 'Checked', 'off');
    userdata.options.plotDerivatives = false;

	for i=1:length(userdata.handles.radioY)
		set(userdata.handles.radioY(i), 'Enable', yAxisStatus);
		if get(userdata.handles.radioY(i), 'Value') % or get selected from radioY handle, compare to matrix, get the nonzero index of the result
			set(userdata.handles.values(i), 'Enable', ySliderStatus);
			set(userdata.handles.sliders(i), 'Enable', ySliderStatus);
		end
	end

	dimension = getDimensions(userdata.model);
	% enable the following GUI objects only when there are unplotted dimensions
	if dimension > nrDimPlotted
		toggle = 'on';
	else
		toggle = 'off';
	end
	set(handles.pointspopup, 'Enable', toggle);
	set(handles.menu_scalepoints, 'Enable', toggle);
	set(handles.createmoviebutton, 'Enable', toggle);
	set(handles.createmoviemenu, 'Enable', toggle);
    
    set(handles.output, 'UserData', userdata);
end

%-- get the current bounds and values from the sliders
function [bounds values] = getBoundsValues(model, sliderHandles)
	dim = getDimensions(model);
	bounds = zeros(dim,2);
	values = zeros(dim,1);
	for i=1:dim
		bounds(i,1) = get(sliderHandles(i), 'Min');
		values(i) = get(sliderHandles(i), 'Value');
		bounds(i,2) = get(sliderHandles(i), 'Max');
	end
end

%--- Save the current plot title in the plot options,
% if specified by userdata.keepTitle. Otherwise return to the default
% title.
function updateTitles(handles)
	userdata = get(handles.output, 'UserData');
	for i=1:length(userdata.figures)
		if (userdata.keepTitle(i))
			% remember title
			prevAxes = get(userdata.figures(i), 'CurrentAxes');
			titleHandle = get(prevAxes, 'Title');
			if ishandle(titleHandle)
				userdata.options.titles{i} = vectorizeString(get(titleHandle, 'String'));
			else
				userdata.options.titles{i} = '';
			end
		else
			userdata.options.titles{i} = userdata.defaultOptions.titles{i};
		end
	end
	set(handles.output, 'UserData', userdata);
end

%--- Replot the model according to current settings
function replot(handles)
	updateTitles(handles);
	userdata = get(handles.output, 'UserData');
	options = userdata.options;
	if userdata.resetCamera
		% force a single reset of the camera, don't change userdata setting
		options.keepCamera = false;
		% only force a single camera reset
		userdata.resetCamera = false;
	end

	% Keep bounds, values and indexes updated in callbacks?
	% It's easier to get them here, because they are changed in many callbacks.
	[userdata.inputs.bounds userdata.inputs.values] = getBoundsValues(userdata.model,userdata.handles.sliders);

	if (userdata.options.showAllOutputs)
		for outputIndex = 1:length(userdata.figures)
			% make sure all plots are visible
			if strcmp('off', get(userdata.figures(outputIndex), 'Visible'))
				% use this check because setting this property also makes the
				% figure the current figure, we don't always want that
				set(userdata.figures(outputIndex), 'Visible', 'on');
			end
			% remember the title
			userdata.keepTitle(outputIndex) = true;
		end

		quickPlotModel(userdata.model, userdata.outputIndex, userdata.inputs,...
				options, userdata.figures);
	else
		% make sure plot is visible
		if strcmp('off', get(userdata.figures(userdata.outputIndex), 'Visible'))
			% use this check because setting this property also makes the
			% figure the current figure, we don't always want that
			set(userdata.figures(userdata.outputIndex), 'Visible', 'on');
		end

		options.title = userdata.options.titles{userdata.outputIndex};
		quickPlotModel(userdata.model, userdata.outputIndex, userdata.inputs,...
				options, userdata.figures(userdata.outputIndex));
		% remember the title
		userdata.keepTitle(userdata.outputIndex) = true;
	end
	% make sure the console has focus
	figure(handles.output);
	set(handles.output, 'UserData', userdata);
end

% check all value and sliders and correct enabledness
function correctEnabled(handles)
	userdata = get(handles.output, 'UserData');

	for i=1:length(userdata.handles.radioX)
		if (get(userdata.handles.radioX(i), 'Value') || ...
				(get(userdata.handles.radioY(i),'Value') && strcmp('on', get(userdata.handles.radioY(i), 'Enable'))))
			enable = 'off';
		else
			enable = 'on';
		end
		set(userdata.handles.values(i), 'Enable', enable);
		set(userdata.handles.sliders(i), 'Enable', enable);
	end
end

% correct plot window visiblity
function setPlotVisibility(fighandles, outputIndex, showAllOutputs)
	if (showAllOutputs)
		set(fighandles, 'Visible', 'on');
	else
		% hide plots, except the one with the currently selected output
		for i = 1:length(fighandles)
			if (i == outputIndex)
				set(fighandles(i), 'Visible', 'on');
			else
				set(fighandles(i), 'Visible', 'off');
			end
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Call this function if you want to update an existing Console with a
% model with the same input and output dimensions (including names)
function guiConsole_UpdateModel(hObject, eventdata, handles, varargin)
	userdata = get(hObject, 'UserData');
	if (length(varargin) == 4)
		model = varargin{1};
		outputIndex = varargin{2};
		inputs = varargin{3};
		options = varargin{4};
	else
		error('Specify the model, output index, input settings and options to update, or use guiPlotModel.');
	end

	[inDim1 outDim1] = getDimensions(userdata.model);
	[inDim2 outDim2] = getDimensions(model);
	if ~(inDim1 == inDim2 && outDim1 == outDim2)
		error('Updated model has wrong number of dimensions (%ix%i instead of %ix%i).',...
				inDim2, outDim2, inDim1, outDim1);
	end

	% store the new input and output names as defaults and set the previous
	% ones in the new model
	newInputNames = getInputNames(model);
	newOutputNames = getOutputNames(model);
	model = setInputNames(model, getInputNames(userdata.model));
	model = setOutputNames(model, getOutputNames(userdata.model));
	userdata.defaultInputNames = newInputNames;
	userdata.defaultOutputNames = newOutputNames;

	userdata.model = model;
	userdata.defaultOutputIndex = outputIndex;
	userdata.defaultInputs = inputs;
	userdata.defaultOptions = options;
	userdata.options.modelFilename = options.modelFilename; % take the new filename
	% reset the title (because model class might be different)
	userdata.keepTitle = userdata.keepTitle * false;
	set(hObject, 'UserData', userdata);
	toggleReload(handles.reloadmenu, userdata.options);

	 % Figure number stays the same, but model class and file name might be different.
	setWindowName(handles.output, userdata.figures, userdata.model, userdata.options);

	replot(handles);
end

% --- Executes just before guiConsole is made visible.
function guiConsole_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiConsole (see VARARGIN)
	% Choose default command line output for guiConsole
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);

	% UIWAIT makes guiConsole wait for user response (see UIRESUME)
	% uiwait(handles.figure1);

	userdata = struct;
	if (length(varargin) == 6)
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.inputs	= varargin{3};
		userdata.options = varargin{4};
		userdata.figures = varargin{5};
		% close function handle, called when the console is closed
		userdata.closeConsole = varargin{6};
	else
		error('Invalid argument count.');
	end

	[inDim outDim] = getDimensions(userdata.model);

	% Enable the 'menu_show all outputs' checkbox when there is more than 1 output.
	if (outDim > 1)
		showAllEnable = 'on';
	else
		showAllEnable = 'off';
	end
	set(handles.showallcheck, 'Enable', showAllEnable);

	% don't get the initial title(s) from the figures, but use the titles
	% provided in options
	userdata.keepTitle = zeros(outDim,1);
	userdata.resetCamera = false; % don't force a reset of the camera yet

	% set all defaults (for reset functionality)
	userdata.defaultOutputIndex = userdata.outputIndex;
	userdata.defaultOptions = userdata.options;
	userdata.defaultInputs = userdata.inputs;
	userdata.defaultOutputNames = getOutputNames(userdata.model);
	userdata.defaultInputNames = getInputNames(userdata.model);
	userdata.defaultPointspopup = get(handles.pointspopup, 'String');

	set(hObject, 'UserData', userdata, 'HandleVisibility', 'callback');

	setModelInputGUI(handles);
	updateControls(handles);
	replot(handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = guiConsole_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Return the console handle
	varargout{1} = handles.output;
end

% --- Executes on slider movement.
function sliderX1_Callback(hObject, eventdata, handles)
% hObject    handle to sliderX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'Value') returns position of slider
	%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

	userdata = get(handles.output, 'UserData');
	index = find(hObject == userdata.handles.sliders, 1);

	newSliderVal = get(hObject, 'Value');
	if ~(isfinite(newSliderVal) && isreal(newSliderVal))
		newSliderVal = userdata.defaultInputs.values(index);
		set(hObject,'Value',newSliderVal);
	end
	set(userdata.handles.values(index), 'String', newSliderVal);
	replot(handles);
end

% --- Executes during object creation, after setting all properties.
function sliderX1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: slider controls usually have a light gray background.
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
end

function valueX1_Callback(hObject, eventdata, handles)
% hObject    handle to valueX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of valueX1 as text
	%        str2double(get(hObject,'String')) returns contents of valueX1 as a double

	userdata = get(handles.output, 'UserData');
	index = find(hObject == userdata.handles.values, 1);

	sliderHandle = userdata.handles.sliders(index);

	[newVal status] = str2num(get(hObject,'String'));
	enteredValue = newVal; % keep a copy of the entered value
	if ~(status && isscalar(newVal) && isfinite(newVal) && isreal(newVal))
		newVal = userdata.defaultInputs.values(index);
		set(hObject, 'String', newVal);
	end

	minVal = get(sliderHandle, 'Min');
	maxVal = get(sliderHandle, 'Max');
	newVal = max(minVal,newVal);
	newVal = min(maxVal,newVal);
	set(sliderHandle, 'Value', newVal);
	if (newVal ~= enteredValue)
		% only set the field when the entered value isn't the final value
		% this keeps special typesettings like 2^3 or pi in the value field
		set(hObject, 'String', newVal);
	end

	replot(handles);
end

% --- Executes during object creation, after setting all properties.
function valueX1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valueX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

function minX1_Callback(hObject, eventdata, handles)
% hObject    handle to minX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of minX1 as text
	%        str2double(get(hObject,'String')) returns contents of minX1 as a double

	userdata = get(handles.output, 'UserData');
	index = find(hObject == userdata.handles.min, 1);

	maxHandle = userdata.handles.max(index);
	sliderHandle = userdata.handles.sliders(index);
	valueHandle = userdata.handles.values(index);

	[newMinVal status] = str2num(get(hObject,'String'));
	if ~(status && isscalar(newMinVal) && isfinite(newMinVal) && isreal(newMinVal))
		newMinVal = userdata.defaultInputs.bounds(index,1);
		set(hObject,'String',newMinVal);
	end

	maxVal = get(sliderHandle,'Max');
	if (maxVal < newMinVal)
		set(maxHandle, 'String', newMinVal);
		set(sliderHandle, 'Max', newMinVal);
	end

	currVal = get(sliderHandle, 'Value');
	if (currVal < newMinVal)
		set(sliderHandle, 'Value', newMinVal);
		set(valueHandle, 'String', newMinVal);
	end

	set(sliderHandle, 'Min', newMinVal);
	replot(handles); % not needed when only adjusting min/max of free parameter, without adjusting value
end

% --- Executes during object creation, after setting all properties.
function minX1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

function maxX1_Callback(hObject, eventdata, handles)
% hObject    handle to maxX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of maxX1 as text
	%        str2double(get(hObject,'String')) returns contents of maxX1 as a double

	userdata = get(handles.output, 'UserData');
	index = find(hObject == userdata.handles.max, 1);

	minHandle = userdata.handles.min(index);
	sliderHandle = userdata.handles.sliders(index);
	valueHandle = userdata.handles.values(index);

	[newMaxVal status] = str2num(get(hObject,'String'));
	if ~(status && isscalar(newMaxVal) && isfinite(newMaxVal) && isreal(newMaxVal))
		newMaxVal = userdata.defaultInputs.bounds(index,2);
		set(hObject,'String',newMaxVal);
	end

	minVal = get(sliderHandle,'Min');
	if (minVal > newMaxVal)
		set(sliderHandle, 'Min', newMaxVal);
		set(minHandle, 'String', newMaxVal);
	end

	currVal = get(sliderHandle, 'Value');
	if (currVal > newMaxVal)
		set(sliderHandle, 'Value', newMaxVal);
		set(valueHandle, 'String', newMaxVal);
	end

	set(sliderHandle, 'Max', newMaxVal);
	replot(handles); % not needed when only adjusting min/max of free parameter, without adjusting value
end

% --- Executes during object creation, after setting all properties.
function maxX1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');
	[model filename] = guiLoadModel(userdata.options.modelFilename);
	if ~isempty(model) % verify that a model was actually loaded
		% Get the default options from guiPlotModel
		[fighandle options] = guiPlotModel();
		% Add the new filename to those options
		options.modelFilename = filename;
		if (getDimensions(model) > 1)
			% default option for models with more than 1 input
			options.plotType = '2D';
		end
		% let guiPlotModel decide whether a console should be reused
		guiPlotModel(model, 1, defaultInputSettings(model), options);
	end
end

% --- Executes on button press in createmoviebutton.
function createmoviebutton_Callback(hObject, eventdata, handles)
% hObject    handle to createmoviebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% first get the current title from the figure(s), for use in the movie
	updateTitles(handles);
	userdata = get(handles.output, 'UserData');
	% A movie will menu_show only one output.
	userdata.options.showAllOutputs = false;
	userdata.options.title = userdata.options.titles{userdata.outputIndex};
	[userdata.inputs.bounds userdata.inputs.values] = getBoundsValues(userdata.model, userdata.handles.sliders);
	guiCreateMovie(userdata.model, userdata.outputIndex, userdata.inputs,...
			userdata.options, userdata.figures(userdata.outputIndex));
end

% --- Executes when selected object is changed in radioX.
function radioX_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in radioX 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');
	index = find(hObject == userdata.handles.radioX, 1);

	% update stored index
	oldIndex = userdata.inputs.xIndex;
	userdata.inputs.xIndex = index;

	% X vs Y
	if (get(handles.radioY, 'SelectedObject') == userdata.handles.radioY(index))
		% Switch
		set(handles.radioY, 'SelectedObject', userdata.handles.radioY(oldIndex))
		userdata.inputs.yIndex = oldIndex;
	end
	set(handles.output, 'UserData', userdata);
	correctEnabled(handles);
	replot(handles);
end

% --- Executes when selected object is changed in radioY.
function radioY_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in radioY 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');
	index = find(hObject == userdata.handles.radioY, 1);

	% update stored index
	oldIndex = userdata.inputs.yIndex;
	userdata.inputs.yIndex = index;

	% Y vs X
	if (get(handles.radioX, 'SelectedObject') == userdata.handles.radioX(index))
		% Switch
		set(handles.radioX, 'SelectedObject', userdata.handles.radioX(oldIndex))
		userdata.inputs.xIndex = oldIndex;
	end
	set(handles.output, 'UserData', userdata);
	correctEnabled(handles);
	replot(handles);
end

% --- Executes on selection change in outputpopup.
function outputpopup_Callback(hObject, eventdata, handles)
% hObject    handle to outputpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: contents = get(hObject,'String') returns outputpopup contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from outputpopup

	userdata = get(handles.output, 'UserData');
	userdata.outputIndex = get(hObject, 'Value');
	outputNames = getOutputNames(userdata.model);
	set(handles.output, 'UserData', userdata);
	setPlotVisibility(userdata.figures, userdata.outputIndex, userdata.options.showAllOutputs);
	% resetting the title is not needed, each output has its own plot window
	replot(handles);
end

% --- Executes during object creation, after setting all properties.
function outputpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

function meshfield_Callback(hObject, eventdata, handles)
% hObject    handle to meshfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of meshfield as text
	%        str2double(get(hObject,'String')) returns contents of meshfield as a double

	userdata = get(handles.output, 'UserData');
	userdata.options.meshSize = round(str2double(get(hObject, 'String')));
	if ~(isreal(userdata.options.meshSize) && (userdata.options.meshSize > 1)...
			&& isfinite(userdata.options.meshSize))
		userdata.options.meshSize = userdata.defaultOptions.meshSize;
	end
	set(hObject, 'String', userdata.options.meshSize);
	set(handles.output, 'UserData', userdata);

	if userdata.options.plotModel
		% mesh size is only applicable when model is plotted
		replot(handles);
	end
end

% --- Executes during object creation, after setting all properties.
function meshfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meshfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

function cliplower_Callback(hObject, eventdata, handles)
% hObject    handle to cliplower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of cliplower as text
	%        str2double(get(hObject,'String')) returns contents of cliplower as a double

	userdata = get(handles.output, 'UserData');
	[newValue status] = str2num(get(hObject, 'String'));
	if ~(status && isscalar(newValue) && isreal(newValue) && isfinite(newValue))
		newValue = userdata.defaultOptions.outputAxisRange(1);
		set(hObject, 'String', newValue);
	end

	% adjust upper limit if it is now too small
	if (newValue >= userdata.options.outputAxisRange(2))
		set(handles.clipupper, 'String', newValue+1); % +1 because limits can't be the same
		userdata.options.outputAxisRange(2) = newValue+1;
	end

	userdata.options.outputAxisRange(1) = newValue;
	set(handles.output, 'UserData', userdata);

	% only replot if clipping is currently enabled
	if (userdata.options.clipOutput)
		replot(handles);
	end
end

% --- Executes during object creation, after setting all properties.
function cliplower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cliplower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

function clipupper_Callback(hObject, eventdata, handles)
% hObject    handle to clipupper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of clipupper as text
	%        str2double(get(hObject,'String')) returns contents of clipupper as a double

	userdata = get(handles.output, 'UserData');
	[newValue status] = str2num(get(hObject, 'String'));
	if ~(status && isscalar(newValue) && isreal(newValue) && isfinite(newValue))
		newValue = userdata.defaultOptions.outputAxisRange(2);
		set(hObject, 'String', newValue);
	end

	% adjust lower limit if it is now too large
	if (newValue <= userdata.options.outputAxisRange(1))
		set(handles.cliplower, 'String', newValue-1); % -1 because values can't be the same
		userdata.options.outputAxisRange(1) = newValue-1;
	end

	userdata.options.outputAxisRange(2) = newValue;
	set(handles.output, 'UserData', userdata);

	% only replot if clipping is currently enabled
	if (userdata.options.clipOutput)
		replot(handles);
	end
end

% --- Executes during object creation, after setting all properties.
function clipupper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clipupper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

% --- Executes on button press in clipcheck.
function clipcheck_Callback(hObject, eventdata, handles)
% hObject    handle to clipcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hint: get(hObject,'Value') returns toggle state of clipcheck
	userdata = get(handles.output, 'UserData');
	if (get(hObject, 'Value'))
		userdata.options.clipOutput = true;
	else
		userdata.options.clipOutput = false;
	end
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --- Executes on selection change in complexFixPopup.
function complexFixPopup_Callback(hObject, eventdata, handles)
% hObject    handle to complexFixPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: contents = get(hObject,'String') returns complexFixPopup contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from complexFixPopup
	userdata = get(handles.output, 'UserData');
	complexFixIndex = get(hObject, 'Value');
	switch (complexFixIndex)
		case 1
			userdata.options.complexFix = 'real';
		case 2
			userdata.options.complexFix = 'imaginary';
		case 3
			userdata.options.complexFix = 'modulus';
		case 4
			userdata.options.complexFix = 'angle';
		otherwise
			warning('guiConsole:complexFixPopup:UnknownComplexFixIndex',...
					'Unknown selected complex fix (%i), assuming real.', complexFixIndex);
			userdata.options.complexFix = 'real';
	end
	% reset the title, it normally contains the outputname
	userdata.keepTitle = userdata.keepTitle * false; % set all fields to false
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --- Executes during object creation, after setting all properties.
function complexFixPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to complexFixPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

% --- Executes on selection change in plotTypePopup.
function plotTypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to plotTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: contents = get(hObject,'String') returns plotTypePopup contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from plotTypePopup

	userdata = get(handles.output, 'UserData');
	plotTypeIndex = get(hObject, 'Value');
	switch (plotTypeIndex)
		case 1
			userdata.options.plotType = '1D';
		case 2
			userdata.options.plotType = '2D';
		%case 3: disabled for release
		%	userdata.options.plotType = '3D';
		case 3
			userdata.options.plotType = 'contour';
		otherwise
			warning('guiConsole:plotTypePopup_Callback:UnknownPlotType',...
					'Unknown plot type selected (%i), Assuming 1D', plotTypeIndex);
			userdata.options.plotType = '1D';
	end

	userdata.resetCamera = true; % force camera reset (ignore user setting)
	set(handles.output, 'UserData', userdata);
	setPlotType(handles);

	replot(handles);
end

% --- Executes during object creation, after setting all properties.
function plotTypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hint: delete(hObject) closes the figure
	userdata = get(hObject, 'UserData');
	userdata.closeConsole(hObject,eventdata);
end

function pointspercent_Callback(hObject, eventdata, handles)
% hObject    handle to pointspercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of pointspercent as text
	%        str2double(get(hObject,'String')) returns contents of pointspercent as a double

	percent = abs(str2double(strrep(get(hObject,'String'), '%', '')));
	userdata = get(handles.output, 'UserData');
	if ((~isreal(percent)) || isnan(percent))
		percent = userdata.defaultOptions.pointsDeviation;
	end
	percentString = [num2str(percent) ' %'];
	set(hObject,'String', percentString);

	[percentList index] = matchString(percentString, get(handles.pointspopup, 'String'));
	set(handles.pointspopup, 'String', percentList);
	set(handles.pointspopup, 'Value', index);

	userdata.options.pointsDeviation = percent;
	set(handles.output, 'UserData', userdata);

	if userdata.options.plotPoints
		% only replot when plotting points is enabled
		replot(handles);
	end
end

% --- Executes during object creation, after setting all properties.
function pointspercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointspercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

% --- Executes on button press in modelinfobutton.
function modelinfobutton_Callback(hObject, eventdata, handles)
% hObject    handle to modelinfobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');
	guiModelInfo(userdata.model, userdata.outputIndex, [], userdata.options.modelFilename);
end

function labelX1_Callback(hObject, eventdata, handles)
% hObject    handle to labelX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of labelX1 as text
	%        str2double(get(hObject,'String')) returns contents of labelX1 as a double

	userdata = get(handles.output, 'UserData');
	index = find(hObject == userdata.handles.labels, 1);

	inputNames = getInputNames(userdata.model);
	newLabel = get(hObject, 'String');
	if isempty(newLabel)
		inputNames{index} = userdata.defaultInputNames{index};
		set(hObject, 'String', inputNames{index});
	else
		inputNames{index} = newLabel;
	end
	userdata.model = setInputNames(userdata.model, inputNames);
	set(handles.output, 'UserData', userdata);
	replot(handles);
end


function outputname_Callback(hObject, eventdata, handles)
% hObject    handle to outputname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hints: get(hObject,'String') returns contents of outputname as text
	%        str2double(get(hObject,'String')) returns contents of outputname as a double

	userdata = get(handles.output, 'UserData');
	% reset the title of the plot with the output that's changed
	userdata.keepTitle(userdata.outputIndex) = false;

	outputNames = getOutputNames(userdata.model);
	newName = get(hObject, 'String');
	if isempty(newName)
		outputNames{userdata.outputIndex} = userdata.defaultOutputNames{userdata.outputIndex};
		set(hObject, 'String', outputNames{userdata.outputIndex});
	else
		outputNames{userdata.outputIndex} = newName;
	end
	userdata.model = setOutputNames(userdata.model, outputNames);
	set(handles.outputpopup, 'String', outputNames);
	set(handles.output, 'UserData', userdata);
	setWindowName(handles.output, userdata.figures, userdata.model, userdata.options);
	replot(handles);
end

% --- Executes during object creation, after setting all properties.
function outputname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end


% --- Executes on selection change in pointspopup.
function pointspopup_Callback(hObject, eventdata, handles)
	% hObject    handle to pointspopup (see GCBO)
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)

	% Hints: contents = get(hObject,'String') returns pointspopup contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from pointspopup
	percentString = get(hObject, 'String');
	percentString = percentString{get(hObject,'Value')};
	percent = str2double(strrep(percentString, '%', ''));

	userdata = get(handles.output, 'UserData');
	userdata.options.pointsDeviation = percent;
	set(handles.output, 'UserData', userdata);

	if userdata.options.plotPoints
		% only replot when plotting points is enabled
		replot(handles);
	end
end

% --- Executes during object creation, after setting all properties.
function pointspopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end


% --------------------------------------------------------------------
function resetmenu_Callback(hObject, eventdata, handles)
% hObject    handle to resetmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');
	userdata.options = userdata.defaultOptions;
	userdata.model = setInputNames(userdata.model, userdata.defaultInputNames);
	userdata.model = setOutputNames(userdata.model, userdata.defaultOutputNames);
	userdata.inputs = userdata.defaultInputs;
	userdata.outputIndex = userdata.defaultOutputIndex;
	set(handles.output, 'UserData', userdata);

	updateControls(handles);
	replot(handles);
end

% --------------------------------------------------------------------
function filemenu_Callback(hObject, eventdata, handles)
% hObject    handle to filemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% no action required
end

% --------------------------------------------------------------------
function loadmenu_Callback(hObject, eventdata, handles)
% hObject    handle to loadmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	loadbutton_Callback(hObject, eventdata, handles); % just forward
end

% --------------------------------------------------------------------
function modelinfomenu_Callback(hObject, eventdata, handles)
% hObject    handle to modelinfomenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	modelinfobutton_Callback(hObject, eventdata, handles); % just forward
end

% --- Executes on button press in keepcameracheck.
function keepcameracheck_Callback(hObject, eventdata, handles)
% hObject    handle to keepcameracheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hint: get(hObject,'Value') returns toggle state of keepcameracheck
	userdata = get(handles.output, 'UserData');
	userdata.options.keepCamera = get(hObject, 'Value');
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --- Executes on button press in showallcheck.
function showallcheck_Callback(hObject, eventdata, handles)
% hObject    handle to showallcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hint: get(hObject,'Value') returns toggle state of showallcheck
	userdata = get(handles.output, 'UserData');
	userdata.options.showAllOutputs = get(hObject, 'Value');
	set(handles.output, 'UserData', userdata);
	setPlotVisibility(userdata.figures, userdata.outputIndex, userdata.options.showAllOutputs);
	if (userdata.options.showAllOutputs)
		% replot all plots
		replot(handles);
	end % else no replot needed, nothing has changed, only some plots were hidden
end

% --------------------------------------------------------------------
function actionmenu_Callback(hObject, eventdata, handles)
% hObject    handle to actionmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function createmoviemenu_Callback(hObject, eventdata, handles)
% hObject    handle to createmoviemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	createmoviebutton_Callback(hObject, eventdata, handles); % just forward
end


% --------------------------------------------------------------------
function sliceplotmenu_Callback(hObject, eventdata, handles)
% hObject    handle to sliceplotmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	updateTitles(handles);
	userdata = get(handles.output, 'UserData');
	options = userdata.options;

	% several fields (e.g. slices, fontSize) are already present in options
	% contour lines below plot
	options.withContour = options.contourLines;
	% enable contour if that's the current plot type
	options.plotContour = strcmp(options.plotType, 'contour');
	options.bounds = getBoundsValues(userdata.model,userdata.handles.sliders);
	options.title = options.titles{userdata.outputIndex}; % is currently not used in basicPlotModel
	if ~options.clipOutput
		% clear the clipping range, because the option is deactivated
		options.outputAxisRange = [];
	end
	% set all options that are not present to their default value
	[dummy] = plotModel(userdata.model);
	defaults = Model.getPlotDefaults();
	options = structMerge(options, defaults);
	plotModel(userdata.model, userdata.outputIndex, options);
end

% --------------------------------------------------------------------
function reloadmenu_Callback(hObject, eventdata, handles)
% hObject    handle to reloadmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');
	if (isempty(userdata.options.modelFilename))
		warning('guiConsole:reloadmenu_Callback:NoOpenendFile',...
				'Tried to reload while no file has been opened yet. Showing open file dialog.');
		% (normally the button should be disabled when this is the case)
		loadmenu_Callback(hObject, eventdata, handles);
	else
		% go through guiPlotModel, it will provide an error message if the
		% model dimensions don't match the passed output and input settings
		% (When the model on disk was replaced by a model with different
		% dimensions than the current model)
		guiPlotModel(loadModel(userdata.options.modelFilename), userdata.defaultOutputIndex,...
				userdata.defaultInputs, userdata.defaultOptions);
	end
end

% --------------------------------------------------------------------
function optimizemenu_Callback(hObject, eventdata, handles)
% hObject    handle to optimizemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% userdata contains model, options, outputIndex...
	userdata = get(handles.output, 'UserData');
	mod = userdata.model;
	[indim outdim] = getDimensions( mod );
	try
		samples = mod.getSamples();

		% multiobjective specific fields
		if userdata.options.showAllOutputs && outdim > 1
			func = @(x) evaluate( mod, x );
			%func = @(x) evaluateInModelSpace( mod, x );

			problem.fitnessfcn = func;
			problem.nvars = indim;
			problem.solver = 'gamultiobj';
			problem.options = gaoptimset;
		else % single-objective fields
			idx = userdata.outputIndex;
			filtermod = OutputFilterWrapper( mod, idx );
			func = @(x) evaluate( filtermod, x ); % (userdata.outputIndex);
			%func = @(x) evaluateInModelSpace( filtermod, x ); % (userdata.outputIndex);

			problem.objective = func;
			problem.x0 = mean( samples, 1 );
			problem.nonlcon = [];
			problem.solver = 'fmincon';
			problem.options = optimset;
		end

		% common fields
		problem.Aineq = [];
		problem.bineq = [];
		%problem.Aineq = [0 0 0 1 1];
		%problem.bineq = [50];
		problem.Aeq = [];
		problem.beq = [];

		% Get simulator bounds from model
		[problem.lb problem.ub] = mod.getBounds();

		% call matlab gui
		optimtool( problem );
	catch err
		errordlg(err, 'Optimization toolbox error');
	end
end

% --------------------------------------------------------------------
function exportmenu_Callback(hObject, eventdata, handles)
% hObject    handle to exportmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Get the model
	userdata = get(handles.output, 'UserData');
	m = userdata.model;
	outputIndex = userdata.outputIndex;

	% construct the default filename
	names = getOutputNames(m);
	df = ['SUMO_' class(m) '_' names{outputIndex} '.m'];

	[filename, pathname] = uiputfile(df, 'Select a file to export to');

	if isequal(filename,0) || isequal(pathname,0)
		% do nothing..
	else
		filename = sprintf('%s%s',pathname,filename);
		exportToMFile(m,outputIndex,filename);
	end
end

% --------------------------------------------------------------------
function menu_plotoptions_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotoptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function menu_show_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function menu_lighting_Callback(hObject, eventdata, handles)
% hObject    handle to menu_lighting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.lighting = ~userdata.options.lighting;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --------------------------------------------------------------------
function menu_grayscale_Callback(hObject, eventdata, handles)
% hObject    handle to menu_grayscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.grayScale = ~userdata.options.grayScale;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --------------------------------------------------------------------
function menu_logscale_Callback(hObject, eventdata, handles)
% hObject    handle to menu_logscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.logScale = ~userdata.options.logScale;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --------------------------------------------------------------------
function menu_plotmodel_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.plotModel = ~userdata.options.plotModel;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --------------------------------------------------------------------
function menu_plotsamples_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.plotPoints = ~userdata.options.plotPoints;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --------------------------------------------------------------------
function menu_plotderivatives_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotderivatives (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.plotDerivatives = ~userdata.options.plotDerivatives;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --------------------------------------------------------------------
function menu_scalepoints_Callback(hObject, eventdata, handles)
% hObject    handle to menu_scalepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.scalePoints = ~userdata.options.scalePoints;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --------------------------------------------------------------------
function menu_contourlines_Callback(hObject, eventdata, handles)
% hObject    handle to menu_contourlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	userdata = get(handles.output, 'UserData');

	checked = get(hObject, 'Checked');
	if strcmp(checked,'on')
		set(hObject, 'Checked', 'off');
	else 
		set(hObject, 'Checked', 'on');
	end
	userdata.options.contourLines = ~userdata.options.contourLines;
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --- Executes on button press in pointscheck.
function pointscheck_Callback(hObject, eventdata, handles)
% hObject    handle to pointscheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Hint: get(hObject,'Value') returns toggle state of pointscheck
	userdata = get(handles.output, 'UserData');
	userdata.options.plotPoints = get(hObject, 'Value');
	set(handles.output, 'UserData', userdata);
	replot(handles);
end

% --- Executes on button press in msecheck.
function msecheck_Callback(hObject, eventdata, handles)
% hObject    handle to msecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of msecheck

	userdata = get(handles.output, 'UserData');
	userdata.options.plotUncertainty = get(hObject,'Value');

	set(handles.output, 'UserData', userdata);
	replot(handles);
				
end

%% Utility functions
function out = menuItemCheck( b )
	if b
		out = 'on';
	else
		out = 'off';
	end
end
