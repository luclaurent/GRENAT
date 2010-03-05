function desc = getDescription( model )

% getDescription (SUMO)
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
%	desc = getDescription( model )
%
% Description:
%	Return a user friendly model description

dim = model.network.layers;

desc = num2str(dim(1));
for(i=2:length(dim))
	desc = [desc '-' num2str(dim(i))];
end

desc = [desc ' FANN trained for ' num2str(model.config.epochs) ' epochs with connectivity ' num2str(model.network.connectivity)];
