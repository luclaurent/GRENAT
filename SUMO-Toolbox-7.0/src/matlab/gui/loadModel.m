function model = loadModel(filename)

% loadModel (SUMO)
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
%	model = loadModel(filename)
%
% Description:
%	Load the model from the specified MAT file. Throws an error when the
%	file doesn't contain a model.
%	@param filename	name of the file to load
%	Example:
%	loadModel('model.mat')

model = load(filename, '-mat', 'model');
if isfield(model, 'model')
	model = model.model;
else
	error('MAT file "%s" does not contain a model!', filename);
end
