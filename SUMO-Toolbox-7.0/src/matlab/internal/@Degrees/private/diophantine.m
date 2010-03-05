function solution = diophantine( w, k )

% diophantine (SUMO)
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
%	solution = diophantine( w, k )
%
% Description:
%	Solves the diophantine equation:
%	  w(1) * x(1) + ... + w(end) * x(end) = k
%	and returns each possible non-negative integer
%	solution for x.

% Some error checkin...
if any( size( w ) == 1 ) && length(size(w)) <= 2
	if numel(k) == 1
		solution = diophantineRecurse( w,k,0,zeros(1,0) );
	else
		error( '[E] k should be a scalar' );
	end
else
	error( '[E] w should be a vector' );
end

