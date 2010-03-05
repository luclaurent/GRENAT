function varargout = guiModelInfo(varargin)

% guiModelInfo (SUMO)
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
%	varargout = guiModelInfo(varargin)
%
% Description:
%	Show information about a model. The GUI also enables the user to
%	specify validation data for model error statistics.
%	All parameters are optional. The options parameter will be merged
%	with the default options, so you need not specify all fields.
%	@param model			the model
%	@param outpedit conutIndex	output index for error statistics
%	@param validationData validation matrix or function handle
%	@param filename		file to reload the model from
%	@param options		error plotting options
%	Examples:
%	guiModelInfo
%	guiModelInfo(model,2,@my_function)

% GUIMODELINFO M-file for guiModelInfo.fig
%      GUIMODELINFO, by itself, creates a new GUIMODELINFO or raises the existing
%      singleton*.
%
%      H = GUIMODELINFO returns the handle to a new GUIMODELINFO or the handle to
%      the existing singleton*.
%
%      GUIMODELINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIMODELINFO.M with the given input arguments.
%
%      GUIMODELINFO('Property','Value',...) creates a new GUIMODELINFO or
%      raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before guiModelInfo_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiModelInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiModelInfo

% Last Modified by GUIDE v2.5 02-Oct-2009 13:54:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiModelInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @guiModelInfo_OutputFcn, ...
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


% --- Update the GUI with the current settings. Reset the validation data
% to the empty matrix.
function updateContent(handles)

userdata = get(handles.output, 'UserData');
% Note: to have multiline edit boxes, Max-Min > 1.0 must hold
set(handles.descriptionfield, 'String', sprintf('%s\n(Model version: %s)',getDescription(userdata.model),getVersion(userdata.model)));
set(handles.relativecheck, 'Value', userdata.options.relativeErrors);
set(handles.dbcheck, 'Value', userdata.options.db);
set(handles.maxvalidationfield, 'String', userdata.options.maxValPoints);

[inDim outDim] = getDimensions(userdata.model);
set(handles.dimensionsfield, 'String', sprintf('%ix%i', inDim, outDim));
set(handles.freeparamsfield, 'String', complexity(userdata.model));

outputNames = getOutputNames(userdata.model);

mdata = getMeasureScores(userdata.model);

%get the table data
tableData = get(handles.scorestable,'data');

if(isempty(mdata))
    %could happen, for example with ComplexWrapper model
    tableData{1,1} = sprintf( 'No measure data available' );
else
    % TODO: backwards compatability check
    if(iscell(mdata))
        measurescores = mdata;
    else
        measurescores = mdata.measureInfo;
    end

    score = getScore(userdata.model);
    
    tableData{1,1} = 'ALL';
    tableData{1,2} = 'Global score';
    %tableData{1,3} = sprintf('%.2e', score);
    tableData{1,3} = score;
    
    for i=1:length(measurescores) % outputs

        for j=1:length(measurescores{i})
            tableData{i*j+1,1} = outputNames{i};
            
            ms = measurescores{i}{j};
            
            % TODO: backwards compatability workarounds
            if(isfield(ms,'enabled'))
                enabled = ms.enabled;
                efun = ms.errorFcn;
            elseif(isfield(ms,'on'))
                enabled = ms.on;
                efun = ms.errorFnc;
            else
               % assume true
               enabled = true;
               efun = 'unknown error function';
            end
            
            if enabled
                tableData{i*j+1,2} = sprintf( '%s (%s)', ms.type, efun );
            else
                tableData{i*j+1,2} = sprintf( '%s (%s) (not used)', ms.type, efun);
            end
            %tableData{i*j+1,3} = sprintf( '%.2e', measurescores{i}{j}.score );
            tableData{i*j+1,3} = measurescores{i}{j}.score;
        end
    end
    
end

%update the table
set(handles.scorestable,'data',tableData);
set(handles.outputpopup, 'String', outputNames);
set(handles.outputpopup, 'Value', userdata.outputIndex);
if (outDim == 1)
	set(handles.outputpopup, 'Enable', 'off');
else
	set(handles.outputpopup, 'Enable', 'on');
end

if (isfield(userdata, 'filename') && (~isempty(userdata.filename)))
	set(handles.reloadmenu, 'Enable', 'on');
	fileSuffix = [' - ' userdata.filename]; % for window title
else
	set(handles.reloadmenu, 'Enable', 'off');
	fileSuffix = ''; % for window title
end

% set the window name (model type + filename)
set(handles.output, 'Name', sprintf('Model info - %s%s',...
		class(userdata.model), fileSuffix));
setValidationPopup(handles);
% now do all updates that depend on the output index
updateByOutputIndex(handles);


%-- Update the pieces that depend on the output index, including the fields
% for external validation data.
function updateByOutputIndex(handles)

userdata = get(handles.output, 'UserData');
[fighandle options trainingStats validationStats] = guiPlotModelErrors(...
		userdata.model, userdata.outputIndex, userdata.validationData,...
		userdata.options, handles.errorplotpanel);
% Note: to have multiline edit boxes, Max-Min > 1.0 must hold
set(handles.trainingstatstable, 'data', trainingStats);
set(handles.validationstatstable, 'data', validationStats);
outputNames = getOutputNames(userdata.model);
	
%--- Set the contents of the validation popup and select the empty matrix
% as the current validation data.
function setValidationPopup(handles)

userdata = get(handles.output, 'UserData');

goodVars = {'[]'}; % no validation or loading one is always an option
if ~isempty(userdata.defaults.validationData)
	% the validation data specified at command line is also an option
	goodVars{end+1} = 'command line';
end

% all function handles and doubles from the workspace are also options
vars = evalin('base', 'whos');
for i=1:length(vars)
	if strcmp(vars(i).class, 'function_handle') || strcmp(vars(i).class, 'double')
		goodVars{end+1} = vars(i).name;
	end
end

set(handles.validationpopup, 'String', goodVars);

% set the empty validation data as default
set(handles.validationpopup, 'Value', 1);
userdata.validationData = [];

set(handles.output, 'UserData', userdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before guiModelInfo is made visible.
function guiModelInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiModelInfo (see VARARGIN)

% Choose default command line output for guiModelInfo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiModelInfo wait for user response (see UIRESUME)
% uiwait(handles.modelinfofigure);

[fighandle defaults] = guiPlotModelErrors();

userdata = struct();
nargin = length(varargin);
switch nargin
	case 0
		userdata.outputIndex = 1;
		userdata.validationData = [];
		userdata.options = defaults;
		
		% show a load model dialog
		[userdata.model userdata.filename] = guiLoadModel();
		if isempty(userdata.model)
			% load failed, show an error message and exit
			errordlg('You must select a model for viewing it''s information.');
			error('You must select a model for viewing it''s information.');
		end
	case 1
		userdata.model = varargin{1};
		userdata.outputIndex = 1;
		userdata.validationData = [];
		userdata.filename = [];
		userdata.options = defaults;
	case 2
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.validationData = [];
		userdata.filename = [];
		userdata.options = defaults;
	case 3
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.validationData = varargin{3};
		userdata.filename = [];
		userdata.options = defaults;
	case 4
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.validationData = varargin{3};
		userdata.filename = varargin{4};
		userdata.options = defaults;
	case 5
		userdata.model = varargin{1};
		userdata.outputIndex = varargin{2};
		userdata.validationData = varargin{3};
		userdata.filename = varargin{4};
		% fill out the options parameter with the default options
		userdata.options = structMerge(varargin{5}, defaults);
	otherwise
		error('Invalid number of parameters given!');
end
% remember initial settings
userdata.defaults = userdata;
set(handles.output, 'UserData', userdata);
updateContent(handles);


% --- Outputs from this function are returned to the command line.
function varargout = guiModelInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function expressionfield_Callback(hObject, eventdata, handles)
% hObject    handle to expressionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expressionfield as text
%        str2double(get(hObject,'String')) returns contents of expressionfield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function expressionfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expressionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function descriptionfield_Callback(hObject, eventdata, handles)
% hObject    handle to descriptionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of descriptionfield as text
%        str2double(get(hObject,'String')) returns contents of descriptionfield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function descriptionfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to descriptionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freeparamsfield_Callback(hObject, eventdata, handles)
% hObject    handle to freeparamsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freeparamsfield as text
%        str2double(get(hObject,'String')) returns contents of freeparamsfield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function freeparamsfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freeparamsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function modelinfofield_Callback(hObject, eventdata, handles)
% hObject    handle to modelinfofield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modelinfofield as text
%        str2double(get(hObject,'String')) returns contents of modelinfofield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function modelinfofield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modelinfofield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dimensionsfield_Callback(hObject, eventdata, handles)
% hObject    handle to dimensionsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dimensionsfield as text
%        str2double(get(hObject,'String')) returns contents of dimensionsfield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function dimensionsfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dimensionsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
set(handles.output, 'UserData', userdata);
updateByOutputIndex(handles);


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





function trainingstatsfield_Callback(hObject, eventdata, handles)
% hObject    handle to trainingstatsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trainingstatsfield as text
%        str2double(get(hObject,'String')) returns contents of trainingstatsfield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function trainingstatsfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainingstatsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function openmenu_Callback(hObject, eventdata, handles)
% hObject    handle to openmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata = get(handles.output, 'UserData');
[userdata.model userdata.filename] = guiLoadModel(userdata.filename);
if ~isempty(model) % make sure a model was loaded
	% update the defaults too, a reset shouldn't return to the old model
	userdata.defaults.model = userdata.model;
	userdata.defaults.filename = userdata.filename;
	set(handles.output, 'UserData', userdata);
	updateContent(handles);
end


% --------------------------------------------------------------------
function reloadmenu_Callback(hObject, eventdata, handles)
% hObject    handle to reloadmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userdata = get(handles.output, 'UserData');
if (isempty(userdata.filename))
	warning('guiModelInfo:reloadmenu_Callback:NoOpenendFile',...
			'Tried to reload while no file has been opened yet. Showing open file dialog.');
	% (normally the button should be disabled when this is the case)
	loadmenu_Callback(hObject, eventdata, handles);
else
	userdata.model = loadModel(userdata.filename);
	if ~isempty(model)
		set(handles.output, 'UserData', userdata);
		updateContent(handles);
	end
end

% --------------------------------------------------------------------
function closemenu_Callback(hObject, eventdata, handles)
% hObject    handle to closemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.output);

% --------------------------------------------------------------------
function filemenu_Callback(hObject, eventdata, handles)
% hObject    handle to filemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% No action required.

% --- Executes on button press in relativecheck.
function relativecheck_Callback(hObject, eventdata, handles)
% hObject    handle to relativecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of relativecheck

userdata = get(handles.output, 'UserData');
userdata.options.relativeErrors = get(hObject, 'Value');
set(handles.output, 'UserData', userdata);
updateByOutputIndex(handles); % only the error plots will change

function maxvalidationfield_Callback(hObject, eventdata, handles)
% hObject    handle to maxvalidationfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxvalidationfield as text
%        str2double(get(hObject,'String')) returns contents of maxvalidationfield as a double

userdata = get(handles.output, 'UserData');
userdata.options.maxValPoints = round(str2double(get(hObject, 'String')));
if ~(isreal(userdata.options.maxValPoints) && (userdata.options.maxValPoints > 1)...
		&& isfinite(userdata.options.maxValPoints))
	% restore default setting
	userdata.options.maxValPoints = userdata.defaults.maxValPoints;
end
set(hObject, 'String', userdata.options.maxValPoints);
set(handles.output, 'UserData', userdata);

% only the plots will change (if there's validation data)
updateByOutputIndex(handles);


% --- Executes during object creation, after setting all properties.
function maxvalidationfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxvalidationfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function validationstatsfield_Callback(hObject, eventdata, handles)
% hObject    handle to validationstatsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of validationstatsfield as text
%        str2double(get(hObject,'String')) returns contents of validationstatsfield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function validationstatsfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to validationstatsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --------------------------------------------------------------------
function actionmenu_Callback(hObject, eventdata, handles)
% hObject    handle to actionmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% No action required.




% --------------------------------------------------------------------
function resetmenu_Callback(hObject, eventdata, handles)
% hObject    handle to resetmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata = get(handles.output, 'UserData');
% go back to the initial settings
userdata = userdata.defaults;
% restore the reference to the initial settings
userdata.defaults = userdata;
set(handles.output, 'UserData', userdata);
updateContent(handles);



% --- Executes on selection change in validationpopup.
function validationpopup_Callback(hObject, eventdata, handles)
% hObject    handle to validationpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns validationpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from validationpopup
userdata = get(handles.output, 'UserData');
string = get(hObject, 'String');
string = string{get(hObject, 'Value')};

try % try using the validation data as specified
	if strcmp(string, 'command line')
		% restore default value
		userdata.validationData = userdata.defaults.validationData;
	else
		userdata.validationData = evalin('base', string);
	end
	set(handles.output, 'UserData', userdata);
	updateByOutputIndex(handles);
catch err % an error occured: show it and reset validation data
	userdata.validationData = [];
	set(hObject, 'Value', 1);
	set(handles.output, 'UserData', userdata);
	setValidationPopup(handles);
	
	% wait until dialog is closed, otherwise the update might go wrong
	uiwait(errordlg(getReport(err), 'Faulty validation data'));
	figure(handles.output); % make sure the window is current
	updateByOutputIndex(handles);
end

% --- Executes during object creation, after setting all properties.
function validationpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to validationpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scoresfield_Callback(hObject, eventdata, handles)
% hObject    handle to scoresfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scoresfield as text
%        str2double(get(hObject,'String')) returns contents of scoresfield as a double
% This field doesn't do anything, it's just for displaying selectable text.


% --- Executes during object creation, after setting all properties.
function scoresfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scoresfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function extra_plots_Callback(hObject, eventdata, handles)
% hObject    handle to extra_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_qqplot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_qqplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userdata = get(handles.output, 'UserData');

mod = userdata.model;
[dim_in dim_out] = getDimensions(mod);
outputNames = mod.getOutputNames();
idx = userdata.outputIndex;

xval = CrossValidation( 20, dim_in ); % 20 folds
[xval, mod, score] = xval.calculateMeasure(mod, [], idx);
qqdata = getQQPlotData( xval );

figure;
qqplotWrapper( qqdata );
title( sprintf( 'QQPlot Cross Validation (20 folds, output %s)', outputNames{idx} ), 'FontSize', 14);



% --------------------------------------------------------------------
function menu_histvalue_Callback(hObject, eventdata, handles)
% hObject    handle to menu_histvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userdata = get(handles.output, 'UserData');

mod = userdata.model;
values = mod.getValues();
outputNames = mod.getOutputNames();

figure;
plotHist( complexFix( values(:,userdata.outputIndex) ), -1, 'FontSize', userdata.options.fontSize, 'type', 'hist' );
xlabel('values', 'FontSize',userdata.options.fontSize, 'interpreter','none');
title( sprintf( 'Histogram of values (output %s)', outputNames{userdata.outputIndex}), 'FontSize', 14);


% --- Executes on button press in load_testset.
function load_testset_Callback(hObject, eventdata, handles)
% hObject    handle to load_testset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	userdata = get(handles.output, 'UserData');
	
	[filename, pathname] = uigetfile('*.txt;*.m', 'Load scattered dataset from file or matlab function', 'a dataset');
	if (filename ~= 0)
		filename = fullfile( pathname,filename );
		[dummy varname dummy dummy] = fileparts(filename);

		userdata.validationData = load(filename);
		
		%evalin('base', [varname '= load(''' filename ''');']);
		%userdata.validationData = evalin('base', varname);

		%goodVars = get(handles.validationpopup, 'String');
		%goodVars{end+1} = varname;
		%set(handles.validationpopup, 'String', goodVars);
		%set(handles.validationpopup, 'Value', length(goodVars));
	else
		% TODO: msgbox
	end
	
	set(handles.output, 'UserData', userdata);
	updateByOutputIndex(handles);


% --------------------------------------------------------------------
function menu_sampledistr_Callback(hObject, eventdata, handles)
% hObject    handle to menu_sampledistr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userdata = get(handles.output, 'UserData');

% Get the model samples
m = userdata.model;
samples = m.getSamples();

if isempty(userdata.filename)
	fileSuffix = '';
else
	fileSuffix = [' - ' userdata.filename];
end

figure('NumberTitle', 'off', 'Name', sprintf('Sample distribution - %s%s',...
		class(userdata.model), fileSuffix));
plotmatrix( samples,'o');


% --------------------------------------------------------------------
function menu_testsetdistr_Callback(hObject, eventdata, handles)
% hObject    handle to menu_testsetdistr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the model
userdata = get(handles.output, 'UserData');

if ~isempty( userdata.validationData )
	[inDim outDim] = getDimensions(userdata.model);
	samples = userdata.validationData(:, 1:inDim );
	
	if isempty(userdata.filename)
		fileSuffix = '';
	else
		fileSuffix = [' - ' userdata.filename];
	end
	
	figure('NumberTitle', 'off', 'Name', sprintf('Sample distribution test set - %s%s',...
		class(userdata.model), fileSuffix));
	plotmatrix( samples,'o' );
else
	msgbox('Test set unavailable','Failed','error')
end

% --------------------------------------------------------------------
function menu_plotdifference_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotdifference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the model
userdata = get(handles.output, 'UserData');

if ~isempty( userdata.validationData )
	options = userdata.options;
	mod = userdata.model;
	[inDim outDim] = getDimensions(mod);
	inputNames = mod.getInputNames();
	outputNames = mod.getOutputNames();
	
	if isempty(userdata.filename)
		fileSuffix = '';
	else
		fileSuffix = [' - ' userdata.filename];
	end
	
	valSamples = userdata.validationData(:, 1:inDim );
	valValues = userdata.validationData(:,inDim + userdata.outputIndex);
	valValues = complexFix( valValues, options.complexFix);
    
	%Evaluate the model on the validation grid
	modelValValues = mod.evaluate(valSamples);
	modelValValues = complexFix( modelValValues(:,userdata.outputIndex), options.complexFix);

	titleTemplate = '%s difference plot on test set %s- %s%s';
	
	if options.relativeErrors
		validationErrors = relativeError( valValues, modelValValues );
		idx = find( isinf( validationErrors ) );
		validationErrors(idx,:) = []; %sign( validationErrors(idx, :) ) .* 10.^15;
		valSamples(idx,:) = [];
		errorFunc = 'Relative';
	else
		validationErrors = absoluteError( valValues, modelValValues );
		errorFunc = 'Absolute';
	end
	
	% should the errors be plotted in dB scale
	dbScale = '';
	if options.db
		validationErrors = dB(validationErrors);
		dbScale = '(dB) ';
	end
	titleTemplate = sprintf( titleTemplate, ...
		errorFunc, dbScale, class(mod), fileSuffix );
	
	if(inDim == 1)
		figure('NumberTitle', 'off', 'Name', titleTemplate);
	
		plot(valSamples, validationErrors,'b');
		xlabel(inputNames{1},'FontSize', options.fontSize, 'Interpreter','none');
		ylabel([errorFunc ' error for ' outputNames{outputIndex}],'FontSize', options.fontSize, 'Interpreter','none')
		title(titleTemplate,'FontSize', options.fontSize, 'Interpreter','none');
	elseif(inDim == 2)
		figure('NumberTitle', 'off', 'Name', titleTemplate);
	
		o = plotScatteredData();
		o.plotPoints = 0;
		plotScatteredData([valSamples validationErrors],o);
		xlabel(inputNames{1},'FontSize', options.fontSize, 'Interpreter','none');
		ylabel(inputNames{2},'FontSize', options.fontSize, 'Interpreter','none');
		zlabel([errorFunc ' error for ' outputNames{userdata.outputIndex}],'FontSize', options.fontSize, 'Interpreter','none')
		title(titleTemplate,'FontSize', options.fontSize, 'Interpreter','none');
	else
		msgbox('Not supported for this number of dimensions (only 1D and 2D)')
	end
else
	msgbox('No test set available','Failed','error')
end

% --- Executes on button press in dbcheck.
function dbcheck_Callback(hObject, eventdata, handles)
% hObject    handle to dbcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dbcheck

userdata = get(handles.output, 'UserData');
userdata.options.db = get(hObject, 'Value');
set(handles.output, 'UserData', userdata);
updateByOutputIndex(handles); % only the error plots will change
