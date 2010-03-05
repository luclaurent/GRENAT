function res = contains(s, model )

% contains (SUMO)
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
%	res = contains(s, model )
%
% Description:
%	Return true if the ensemble already contains this model useing a grid-based equality operator

for i=1:length(s.models)
	if(equals(model,s.models{i},s.eqThreshold))
		res = true;
		break;
	end
end

res = false;


