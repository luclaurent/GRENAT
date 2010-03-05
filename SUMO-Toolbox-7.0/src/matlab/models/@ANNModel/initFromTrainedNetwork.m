function model = initFromTrainedNetwork(model, other);

% initFromTrainedNetwork (SUMO)
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
%	model = initFromTrainedNetwork(model, other);
%
% Description:
%	Set the initial weights based on the trained weights of a second network

nnDim = model.config.networkDim;

iwOrig = model.config.initialWeights.IW;
lwOrig = model.config.initialWeights.LW;
bOrig = model.config.initialWeights.b;

nwWeights = getNetworkWeights(other);
iwOther = nwWeights.IW;
lwOther = nwWeights.LW;
bOther = nwWeights.b;

%"1st layer - input" connections
iwOrig{1,1} = buildMatrixFromOther(iwOrig{1,1},iwOther{1,1});

%hidden layer and output connections
for(i=3:length(nnDim))
	if((i-1) <= size(lwOther,1) && (i-2) <= size(lwOther,2))
		%If the index is still within the bounds of lwOther
		lwOrig{i-1,i-2} = buildMatrixFromOther(lwOrig{i-1,i-2},lwOther{i-1,i-2});
	end
end

%biases
for i=1:length(nnDim)-1
	if(i <= length(bOther))
		bOrig{i} = buildMatrixFromOther(bOrig{i},bOther{i});
	end
end


model.config.initialWeights.IW = iwOrig;
model.config.initialWeights.LW = lwOrig;
model.config.initialWeights.b = bOrig;
