function settings = defaultInputSettings(model)

% defaultInputSettings (SUMO)
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
%	settings = defaultInputSettings(model)
%
% Description:
%	Get the default bounds and values in each input dimension, and
%	default indices for 3 axes. All indices will be in range of the
%	model's inputs.
%	Example:
%	% model has 5 inputs
%	settings = defaultInputSettings(model)
%	settings =
%	 xIndex: 1
%	 yIndex: 2
%	 zIndex: 3
%	 bounds: [5x2 double]
%	 values: [5x1 double]

settings = struct;
numInputs = model.getDimensions();
if (numInputs < 1)
	error('Can''t get input settings for model without inputs');
end
switch numInputs
	case 1
		settings.xIndex = 1;
		settings.yIndex = 1;
		settings.zIndex = 1;
	case 2
		settings.xIndex = 1;
		settings.yIndex = 2;
		settings.zIndex = 2;
	otherwise
		settings.xIndex = 1;
		settings.yIndex = 2;
		settings.zIndex = 3;
end

[inFunc outFunc] = getTransformationFunctions(model);

% calculate the min/max range in each dimension
minRange = outFunc(-ones(1,numInputs));
maxRange = outFunc(ones(1,numInputs));
settings.bounds = [minRange' maxRange'];

% default value is the center of each interval
settings.values = mean(settings.bounds, 2);
