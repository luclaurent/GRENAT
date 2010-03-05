function [fixedInputValues] = filterInputs(s, inputValues)

% filterInputs (SUMO)
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
%	[fixedInputValues] = filterInputs(s, inputValues)
%
% Description:
%	Transforms the sample from the simulator configuration to the modeller
%	setup, by filtering out inputs that were not selected.
%	Also transforms the samples from simulator space to M3 space.

% Create fixed array, initialized to zero (do allocation here)
fixedInputValues = zeros(size(inputValues,1), s.dimension);

% walk all inputs
for m=1:length(s.inputs)
	
	% get input
	input = s.inputs(m);
	index = input.getInputSelect() + 1;
	
	% transform to simulator space
	fixedInputValues(:,m) = (inputValues(:,index) - s.translate(m)) ./ s.scale(m);
end
