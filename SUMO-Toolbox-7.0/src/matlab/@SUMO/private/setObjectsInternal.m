function s = setObjectsInternal( s, objects, name, stopOnError, perOutput )

% setObjectsInternal (SUMO)
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
%	s = setObjectsInternal( s, objects, name, stopOnError, perOutput )
%
% Description:
%	Internal function to generate uniform errors/warnings
%	This method selects a suitable field out of `objects' (based
%	on `name') and plugs it into `s'.

s_name = [lower(name(1)) name(2:end)];

% field does not exist or is empty
if ~isfield(objects, name) || isempty(objects.(name))
	
	% when this flag is on, we stop the toolbox
	if stopOnError
		msg = sprintf('A %s declaration is needed for constructing the SUMO object', name);
		s.logger.severe(msg);
		error(msg);
	end

	s.(s_name) = [];
	
% component exists
else
	
	% there can be multiple instances of this component type
	if perOutput
		s.(s_name) = objects.(name);

	% only one instance possible, simplify
	else
		s.(s_name) = objects.(name).objects{1};
	end
end

