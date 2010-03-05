function x = dfix( x,d,err )

% dfix (SUMO)
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
%	x = dfix( x,d,err )
%
% Description:
%	If x is of length 1 it will be replaced by a d-vector of all x's
%	If x is of length d it will be returned unaltered
%	Else, an error message is printed (either the one you provide or
%	   a default message...

if length(x) == 1
	x = repmat(x,1,d);
else
	if length(x) == d
		x = x;
	else
		if nargin == 3
			error( err );
		else
			error( sprintf( '[E] Either single value or list of length %d expected', d ) );
		end
	end
end
