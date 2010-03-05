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
%	uniquely represents one model.  If wantModels is true an array of model objects is returned.  If construct is true
%	each model is also trained on the given samples and values.

res = [];
params = [];

if(number == 1)
	params = [s.initialSize];
else
	for i=1:number
		%Change the hidden layer structure
		initSize = s.initialSize;
		ndim = length(s.initialSize);
		
		hidLayerDim = [];
		if(ndim == 0)
			%No hidden layers
			hidLayerDim = [0 0];
		elseif(ndim == 1)
			%One hidden layer
			hidLayerDim = [initSize(1) 0];
		elseif(ndim == 2)
			%Two hidden layers
			hidLayerDim = initSize(1:2);
		else
			error('The maximum number of hidden layers is two');
		end
		delta = [randomInt(s.hiddenUnitDelta) randomInt(s.hiddenUnitDelta)];
	
		hidLayerDim = hidLayerDim + delta;

		% dont allow negative values
		hidLayerDim(hidLayerDim < 0) = 0;

		params = [params ; hidLayerDim];
	end
end

if(wantModels)

	%Pre-allocate the models
	res = repmat(ANNModel(),number,1);

	for i=1:size(params,1)

		dim = params(i,:);
		model = s.createModel(dim);

		% choose a random training function
		model = setLearningRule(model, randomChoose(s.allowedLearningRules));

		res(i,1) = model;
	end
else
	res = params;	
end
