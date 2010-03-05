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
%	uniquely represents one model.  If wantModels is true an array of model objects is returned.

%Get the default config (from config file)
res = [];
params = [];

[ni no] = getDimensions(s);

if(number == 1)
	params = [s.initialSize];
else
	initialDim = s.initialSize;
	
	for i=1:number

	  %Change the hidden layer structure
	  hidlayers = length(initialDim)-2;
	  hidLayerDim = [];

	  if(hidlayers == 0)
		  %No hidden layers
		  hidLayerDim = [0 0];
	  elseif(hidlayers == 1)
		  %One hidden layer
		  hidLayerDim = [initialDim(2) 0];
	  else
		  %Two hidden layers
		  hidLayerDim = initialDim(1,2:end-1);
	  end

	  delta = [randomInt(getHiddenUnitDelta(s)) randomInt(getHiddenUnitDelta(s))];
	  hidLayerDim = hidLayerDim + delta;

	  params = [params ; hidLayerDim];
	end
end

if(wantModels)
	%Pre-allocate the models
	res = repmat(FANNModel(),number,1);

	for i=1:number
		m = s.createModel(params(i,:));
		res(i,1) = m;
	end

else
	res = params;	
end
