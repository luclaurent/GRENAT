function o = mergeStruct( s1, s2, destFieldExist )

% mergeStruct (SUMO)
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
%	o = mergeStruct( s1, s2, destFieldExist )
%
% Description:
%	Copies field of s2 over to s1

% destFieldExist can be:
% -1: always copy
% false: only copy when destination field does NOT exist
% true: only copy when destination field exist
if ~exist( 'destFieldExist', 'var' )
	destFieldExist = true;
end

fn = fieldnames(s2);
o = s1;

for n = 1:length(fn)
	
	% Always copy the field over, if it exists or not in s1
	if destFieldExist == -1
	    o.(fn{n}) = s2.(fn{n});
	else % copy the field depending on the type
		if isfield(o, fn{n} ) == destFieldExist
			o.(fn{n}) = s2.(fn{n});
		end
	end
end
