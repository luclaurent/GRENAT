function desc = getDescription( s )

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
%	desc = getDescription( s )
%
% Description:
%	Get the description of this model

members = sprintf('     *%s (weight = %d)', getDescription(s.models{1}),s.weights(1));
for i=2:length(s.models)
	members = sprintf('%s\n     *%s (weight = %d)',members,getDescription(s.models{i}),s.weights(i));
end

desc = sprintf('Weighted Ensemble of size %d with members\n%s ',length(s.models),members);
