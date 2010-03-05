function varargout = guiCreateMovie(varargin)

% guiCreateMovie (SUMO)
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
%	varargout = guiCreateMovie(varargin)
%
% Description:
%	Show a GUI for creating a movie. You can select which input should
%	vary over time, set the fps, quality, compression...
%	All parameters are optional. The plot options will be merged with the
%	default options, so you need not specify all fields.
%	@param model			model to plot
%	@param outputIndex	index of the output to plot
%	@param inputSettings	axis indices, bounds and values for the model's inputs
%	@param plotOptions	options for plotting
%	@param fighandle		handle of the figure to plot in
%	Example:
%	guiCreateMovie

% GUICREATEMOVIE M-file for guiCreateMovie.fig
%      GUICREATEMOVIE, by itself, creates a new GUICREATEMOVIE or raises the existing
%      singleton*.
%
%      H = GUICREATEMOVIE returns the handle to a new GUICREATEMOVIE or the handle to
%      the existing singleton*.
%
%      GUICREATEMOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUICREATEMOVIE.M with the given input arguments.
%
%      GUICREATEMOVIE('Property','Value',...) creates a new GUICREATEMOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiCreateMovie_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiCreateMovie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiCreateMovie

% Last Modified by GUIDE v2.5 07-Jun-2008 15:30:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiCreateMovie_OpeningFcn, ...
                   'gui_OutputFcn',  @guiCreateMovie_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Get the shorthand for the compression matching an index value.
function compression = getCompressionType(int)
switch(int)
	case 1
		compression = 'matlab';
	case 2
		compression = 'quicktime';
	otherwise
		warning('guiCreateMovie:getCompressionType:UnknownValue',...
				'Unknown compression index value (%i), assuming matlab default.',int);
		compression = 'quicktime';
end


% --- Reset the GUI to it's default settings
function resetToDefaults(handles)

userdata = get(handles.output, 'UserData');
set(handles.dimensionpopup, 'Value', 1);
set(handles.fixaxischeck, 'Value', 1);
set(handles.slicetitlecheck, 'Value', 1);
set(handles.slicesfield, 'String', 51);
set(handles.fpsfield, 'String', '3 fps');
set(handles.fpspopup, 'Value', 2);
set(handles.fpspopup, 'String', userdata.defaultFpsPopup);
set(handles.compressionpopup, 'Value', 1);
set(handles.qualityfield, 'String', '100 %');
set(handles.qualitypopup, 'Value', 5);
set(handles.qualitypopup, 'String', userdata.defaultQualityPopup);
set(handles.outputfilefield, 'String', 'movie.avi');



% --- Correct the file extension in the output file field
function correctExtension(handles)
% handles	gui handles structure

switch getCompressionType(get(handles.compressionpopup, 'Value'))
	case 'matlab'
		extension = '.avi';
	case 'quicktime'
		extension = '.mov';
	otherwise
		% shouldn't occur
		warning('guiCreateMovie:correctExtension:UnknownCompression',...
				'Unknown compression selected. Assuming avi for file extension.');
		extension = '.avi';
end
% first try replacing an incorrect extension
filename = regexprep(get(handles.outputfilefield, 'String'), '\.\w{3}$', extension, 'once');
% if the replace failed, append the extension
if isempty(regexp(filename, ['\' extension '$'], 'once'))
	filename = [filename extension];
end
set(handles.outputfilefield, 'String', filename);


% -- Enable or disable the compression quality popup box
function toggleQuality(handles)
% Does the default matlab encoding support compression?
if (ispc || ismac)
	matlabEnable = 'on';
else
	matlabEnable = 'off';
end

switch getCompressionType(get(handles.compressionpopup, 'Value'))
	case 'matlab'
		enable  = matlabEnable;
	case 'quicktime'
		enable = 'off';
	otherwise
		% shouldn't occur
		warning('guiCreateMovie:compressionpopup_Callback:UnknownSelection',...
				'Unknown compression selected. Assuming avi for file extension.');
		enable = matlabEnable;
end
set(handles.qualityfield, 'Enable', enable);
set(handles.qualitypopup, 'Enable', enable);


% --- Remembers the previous settings.
% Provide a single input parameter to store it as the current settings.
% Provide a single output parameter to get the currently stored settings.
% You can't do both at once.
function settings = settingsHandler(varargin)

global gSettings;
if ((nargin == 0) && (nargout == 1))
	% return the global settings
	settings = gSettings;
elseif ((nargin == 1) && (nargout == 0))
	% save the passed settings in the global
	gSettings = varargin{1};
else
	error('guiCreateMovie:settingsHandler:WrongArgumentCount',...
			'Wrong number of arguments!');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before guiCreateMovie is made visible.
function guiCreateMovie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiCreateMovie (see VARARGIN)

% Choose default command line output for guiCreateMovie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiCreateMovie wait for user response (see UIRESUME)
% uiwait(handles.figure1);

[la lb plotDefaults] = quickPlotModel();

userdata = struct(...
		'defaultQualityPopup', {get(handles.qualitypopup, 'String')},...
		'defaultFpsPopup', {get(handles.fpspopup, 'String')}...
	);

nargin = length(varargin);
switch nargin
	case 0
		% load from file
		userdata.model = guiLoadModel();
		if isempty(userdata.model) % no model was loaded
			% load failed, show an error message and exit
			errordlg('You must select a model for creating a movie.');
			error('You must select a model for creating a movie.');
		end
		userdata.outputIndex = 1;
		userdata.inputs = defaultInputSettings(userdata.model);
		userdata.options = plotDefaults;
		userdata.figure = gcf;
	case 1
		userdata.model = varargin{1};
		userdata.outputIndex = 1;
		userdata.inputs = defaultInputSettings(userdata.model);
		userdata.options = plotDefaults;
		userdata.figure = gcf;
	case 2
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.inputs = defaultInputSettings(userdata.model);
		userdata.options = plotDefaults;
		userdata.figure = gcf;
	case 3
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.inputs = varargin{3};
		userdata.options = plotDefaults;
		userdata.figure = gcf;
	case 4
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.inputs = varargin{3};
		% merge the passed plot options with the default options
		userdata.options = structMerge(varargin{4},plotDefaults);
		userdata.figure = gcf;
	case 5
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.inputs = varargin{3};
		% merge the passed plot options with the default options
		userdata.options = structMerge(varargin{4},plotDefaults);
		userdata.figure = varargin{5};
	otherwise
		error('Invalid parameters given.');
end

modelDim = getDimensions(userdata.model);
if (nargin < 4) && (modelDim > 2)
	% default plot type for movies of models with more than 2 inputs
	userdata.options.plotType = '2D';
end

j = 1;
inputNames = getInputNames(userdata.model);
choiceCount = modelDim;
if strcmp(userdata.options.plotType, '1D')
	% only 1 input plotted
	choiceCount = choiceCount - 1;
else
	% 2 inputs plotted
	choiceCount = choiceCount - 2;
end
labels = cell(choiceCount,1);
for i=1:modelDim
	if ((i ~= userdata.inputs.xIndex) && (i ~= userdata.inputs.yIndex ||...
			strcmp(userdata.options.plotType, '1D')))
		labels{j} = inputNames{i};
		j = j+1;
	end
end

set(handles.dimensionpopup, 'String', labels);
if (choiceCount > 1)
	set(handles.dimensionpopup, 'Enable', 'on');
else
	set(handles.dimensionpopup, 'Enable', 'off');
end
set(hObject, 'UserData', userdata);

% Try to restore settings from a previous time.
prevSettings = settingsHandler();
if ~isempty(prevSettings)
	set(handles.slicesfield, 'String', prevSettings.numSlices);
	fpsString = [num2str(prevSettings.fps) ' fps'];
	set(handles.fpsfield, 'String', fpsString);
	set(handles.outputfilefield, 'String', prevSettings.outputFile);
	set(handles.fixaxischeck, 'Value', prevSettings.fixAxis);
	qualityString = [num2str(prevSettings.quality) ' %'];
	set(handles.qualityfield, 'String', qualityString);
	set(handles.slicetitlecheck, 'Value', prevSettings.showSliceTitle);
	
	if (regexp(prevSettings.outputFile, '.mov$'))
		set(handles.compressionpopup, 'Value', 2); % Quicktime
	else
		set(handles.compressionpopup, 'Value', 1); % Matlab default
	end
	
	[list index] = matchString(fpsString, userdata.defaultFpsPopup);
	set(handles.fpspopup, 'String', list);
	set(handles.fpspopup, 'Value', index);
	
	[list index] = matchString(qualityString, userdata.defaultQualityPopup);
	set(handles.qualitypopup, 'String', list);
	set(handles.qualitypopup, 'Value', index);
end
toggleQuality(handles);


% --- Outputs from this function are returned to the command line.
function varargout = guiCreateMovie_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browsebutton.
function browsebutton_Callback(hObject, eventdata, handles)
% hObject    handle to browsebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch getCompressionType(get(handles.compressionpopup, 'Value'))
	case 'matlab'
		filterSpec = {'*.avi'};
	case 'quicktime'
		filterSpec = {'*.mov'};
	otherwise
		warning('guiCreateMovie:browsebutton_Callback:UnknownCompression',...
				'Unknown compression selected. Assuming avi for file extension.');
		filterSpec = {'*.avi'};
end

[filename, filepath] = uiputfile(filterSpec, '', get(handles.outputfilefield, 'String'));
if (filename ~= 0)
	set(handles.outputfilefield, 'String', sprintf('%s%s', filepath, filename));
	correctExtension(handles);
end


function outputfilefield_Callback(hObject, eventdata, handles)
% hObject    handle to outputfilefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputfilefield as text
%        str2double(get(hObject,'String')) returns contents of outputfilefield as a double
correctExtension(handles);


% --- Executes during object creation, after setting all properties.
function outputfilefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputfilefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in createbutton.
function createbutton_Callback(hObject, eventdata, handles)
% hObject    handle to createbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userdata = get(handles.output, 'UserData');
movieOptions = struct(...
	'numSlices', str2double(get(handles.slicesfield, 'String')),...
	'fps', str2double(strrep(get(handles.fpsfield, 'String'), 'fps', '')),...
	'outputFile', get(handles.outputfilefield, 'String'),...
	'fixAxis', get(handles.fixaxischeck, 'Value'),...
	'quality', str2double(strrep(get(handles.qualityfield,'String'), '%', '')),...
	'showSliceTitle', get(handles.slicetitlecheck, 'Value')...
	);

userdata.inputs.zIndex = get(handles.dimensionpopup, 'Value');
% nothing has to change when the selected index is smaller than the indexes
% of X and Y (if plotted)
if (userdata.inputs.zIndex >= userdata.inputs.xIndex)
	userdata.inputs.zIndex = userdata.inputs.zIndex + 1;
end
if ((userdata.inputs.zIndex >= userdata.inputs.yIndex) && (~strcmp(userdata.options.plotType, '1D')))
	userdata.inputs.zIndex = userdata.inputs.zIndex + 1;
	
	% re-check xIndex after increment (equality only)
	if (userdata.inputs.zIndex == userdata.inputs.xIndex)
		userdata.inputs.zIndex = userdata.inputs.zIndex + 1;
	end
end

% Store the settings in the global variable
settingsHandler(movieOptions);

% Switch to the figure window, by making it modal and then closing the
% create movie dialog. The plot window is not required to be the current
% figure, nor must it be modal, for genMovie. The user should however still
% be prevented from accessing the console while the movie is being created.
try
	set(userdata.figure, 'WindowStyle', 'modal');
	figure(userdata.figure);
	close(handles.output);
	genMovie(userdata.model, userdata.outputIndex, userdata.inputs,...
			userdata.options, userdata.figure, movieOptions);
catch err % make sure the figure window is no longer modal afterwards
	set(userdata.figure, 'WindowStyle', 'normal');
	rethrow(err);
end
set(userdata.figure, 'WindowStyle', 'normal');


function fpsfield_Callback(hObject, eventdata, handles)
% hObject    handle to fpsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fpsfield as text
%        str2double(get(hObject,'String')) returns contents of fpsfield as a double

value = str2double(strrep(get(hObject, 'String'), 'fps', ''));
if (isreal(value) && isfinite(value) && (value > 0))
	valueString = [num2str(value) ' fps'];
	set(hObject, 'String', valueString);
	[list index] = matchString(valueString, get(handles.fpspopup, 'String'));
	set(handles.fpspopup, 'String', list);
	set(handles.fpspopup, 'Value', index);
else % back to default
	set(hObject, 'String', '3 fps');
	set(handles.fpspopup, 'Value', 2);
end


% --- Executes during object creation, after setting all properties.
function fpsfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fpsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slicesfield_Callback(hObject, eventdata, handles)
% hObject    handle to slicesfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slicesfield as text
%        str2double(get(hObject,'String')) returns contents of slicesfield as a double

value = round(str2double(get(hObject, 'String')));
if ~(isreal(value) && isfinite(value) && (value > 0))
	% reset to default
	value = 51;
end
set(hObject, 'String', value);


% --- Executes during object creation, after setting all properties.
function slicesfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicesfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf);


% --- Executes on selection change in dimensionpopup.
function dimensionpopup_Callback(hObject, eventdata, handles)
% hObject    handle to dimensionpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dimensionpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dimensionpopup


% --- Executes during object creation, after setting all properties.
function dimensionpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dimensionpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in fixaxischeck.
function fixaxischeck_Callback(hObject, eventdata, handles)
% hObject    handle to fixaxischeck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixaxischeck




% --- Executes on selection change in compressionpopup.
function compressionpopup_Callback(hObject, eventdata, handles)
% hObject    handle to compressionpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns compressionpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from compressionpopup

toggleQuality(handles);
correctExtension(handles);



% --- Executes during object creation, after setting all properties.
function compressionpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compressionpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function qualityfield_Callback(hObject, eventdata, handles)
% hObject    handle to qualityfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qualityfield as text
%        str2double(get(hObject,'String')) returns contents of qualityfield as a double

percent = str2double(strrep(get(hObject,'String'), '%', ''));
if (isreal(percent) && (percent >= 0) && (percent <= 100))
	percentString = [num2str(percent) ' %'];
	set(hObject,'String', percentString);
	[list index] = matchString(percentString, get(handles.qualitypopup, 'String'));
	set(handles.qualitypopup, 'String', list);
	set(handles.qualitypopup, 'Value', index);
else % back to defaults
	set(hObject, 'String', '100 %');
	set(handles.qualitypopup, 'Value', 5);
end


% --- Executes during object creation, after setting all properties.
function qualityfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qualityfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in slicetitlecheck.
function slicetitlecheck_Callback(hObject, eventdata, handles)
% hObject    handle to slicetitlecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slicetitlecheck




% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

resetToDefaults(handles);




% --- Executes on selection change in qualitypopup.
function qualitypopup_Callback(hObject, eventdata, handles)
% hObject    handle to qualitypopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns qualitypopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from qualitypopup
% set the selected value in the field
contents = get(hObject,'String');
set(handles.qualityfield, 'String', contents{get(hObject,'Value')});


% --- Executes during object creation, after setting all properties.
function qualitypopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qualitypopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fpspopup.
function fpspopup_Callback(hObject, eventdata, handles)
% hObject    handle to fpspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fpspopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fpspopup
% set the selected value in the field
contents = get(hObject,'String');
set(handles.fpsfield, 'String', contents{get(hObject,'Value')});


% --- Executes during object creation, after setting all properties.
function fpspopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fpspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


