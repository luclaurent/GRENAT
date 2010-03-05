function res = createInitialModels(s, number, wantModels);

% createInitialModels (SUMO)
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
%	res = createInitialModels(s, number, wantModels);
%
% Description:
%	Return 'number' individuals.  If wantModels is false only return a parameter matrix where each row
%	uniquely represents one model.  If wantModels is true a row vector model objects is returned.

res = [];
params = [];
[samples values] = getSamples(s);

if(number == 1)
	%TODO intelligent guess based on the data (now we just take the middle)
	params = [s.kernelParamBounds(1) + ((s.kernelParamBounds(2) - s.kernelParamBounds(1)) / 2) ...
		  s.regParamBounds(1) + ((s.regParamBounds(2) - s.regParamBounds(1)) / 2)];
else
	%Create a 2D latin hypercube space filling design
	d = LatinHypercubeDesign(2,number);
	[smp dummy] = generate(d);

	%Scale to the correct bounds
	kernelParams = scaleColumns(smp(:,1),s.kernelParamBounds(1),s.kernelParamBounds(2));
	gammas = scaleColumns(smp(:,2),s.regParamBounds(1),s.regParamBounds(2));
	
	params = [kernelParams gammas];
end

if(wantModels)
	%Pre-allocate the models
	res = repmat(SVMModel(),number,1);

	for i=1:size(params,1)
		res(i,1) = s.createModel(params(i,:));
	end

else
	res = params;	
end
