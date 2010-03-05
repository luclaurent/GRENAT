function hidLayerDim = getHiddenLayerDim(model);

% getHiddenLayerDim (SUMO)
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
%	hidLayerDim = getHiddenLayerDim(model);
%
% Description:
%	Return the hidden layer dimension

ndim = model.config.networkDim;

hidlayers = length(ndim)-2;
hidLayerDim = [];

if(hidlayers == 0)
	%No hidden layers
	hidLayerDim = [0 0];
elseif(hidlayers == 1)
	%One hidden layer
	hidLayerDim = [ndim(2) 0];
else
	%Two or more hidden layers
	hidLayerDim = ndim(1,2:end-1);
end
