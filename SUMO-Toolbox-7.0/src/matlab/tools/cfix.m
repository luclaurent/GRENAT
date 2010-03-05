function y = cfix( x,d,err )

% cfix (SUMO)
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
%	y = cfix( x,d,err )
%
% Description:
%	This function ``fixes'' a cell array. Either a constant,
%	a one element cell array or a length `d' cell array can be
%	passed to this function. The function will return a length
%	`d' cell array, duplicating the input if necessary

if length(x) ~= 1 && ( ~iscell( x ) || length(x) ~= d )
	if nargin == 3
		error( err );
	else
		error( sprintf( '[E] Either single value or list of length %d expected', d ) );
	end
end

if length(x) == 1
	if iscell(x)
		x = x{1};
	end
	y = cell(1,d);
	for i=1:d
		y{i} = x;
	end
else
	y = x;
end
