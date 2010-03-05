function map = getModelTypes( s )

% getModelTypes (SUMO)
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
%	map = getModelTypes( s )
%
% Description:
%	The number of each model type in the ensemble as a java HashMap

map = java.util.HashMap();

for i=1:length(s.models)
	m = s.models{i};
	
	type = class(m);

	if(~map.containsKey(type))
		map.put(type,1);
	else
		map.put(type,map.get(type) + 1);
	end
end
