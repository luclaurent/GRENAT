function [model filename] = guiLoadModel(defaultFilename)

% guiLoadModel (SUMO)
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
%	[model filename] = guiLoadModel(defaultFilename)
%
% Description:
%	Load a model from file, by showing the user a dialog for selecting
%	the file to open.
%	* The dialog will open in the directory specified, if it exists.
%	* If the specified path also contains a filename, that name will be
%	  entered in the name field.
%	* If the specified path is invalid, the current directory will be shown.
%	* If the load fails (e.g. user closes the dialog), the return
%	  parameters will be empty.
%	@param filename	default name of the file to load
%	@return model		the loaded model, or [] if load failed
%	@return filename	the file path of the loaded file containing the model
%	Examples:
%	model = guiLoadModel('/home/')
%	[model filename] = guiLoadModel('D:\Workspace')

if (nargin == 0)
	% no default name -> leave it empty
	defaultFilename = '';
end

[filename, pathname] = uigetfile('*.mat', 'Load model from file', defaultFilename);
if (filename ~= 0)
	filename = sprintf('%s%s',pathname,filename);
	model = loadModel(filename);
elseif (nargout > 0)
	% opening failed, return empty model and filename
	model = [];
	filename = [];
end
