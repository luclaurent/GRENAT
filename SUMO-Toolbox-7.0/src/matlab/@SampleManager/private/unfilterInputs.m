function [sample] = unfilterInputs(s, sample)

% unfilterInputs (SUMO)
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
%	[sample] = unfilterInputs(s, sample)
%
% Description:
%	Transforms the sample from the modeller configuration to the simulator
%	setup, by by adding default values for inputs that were not selected.

% input values provided by M3, must be of same dimension as s.inputs
inputValues = sample.getInputParameters();

% real input values, to be used by the simulator
% initialized to the constant mask, so that only the real inputs have to be set
realInputValues = s.constantInputMask;

%% walk all inputs
for m = 1 : length(s.inputs)
	
	% get input & index
	input = s.inputs(m);
	index = input.getInputSelect() + 1;
	
	% transform input
	transformedSample = (inputValues(m) .* s.scale(m)) + s.translate(m);
	
	% assign to correct dimension
	realInputValues(index) = transformedSample;
	
end

% store new inputs
sample.setInputParameters(realInputValues);

