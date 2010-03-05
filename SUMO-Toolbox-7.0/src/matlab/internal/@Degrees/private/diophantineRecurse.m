function solution = diophantineRecurse( w,k,lev,curr )

% diophantineRecurse (SUMO)
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
%	solution = diophantineRecurse( w,k,lev,curr )
%
% Description:
%	Internal function to diophantine equation solver:
%	Solves the thing brute force, kind of
%	backtracker/exhaustive solver.
%	Code quite straightforward...

thesum = sum( w(1:lev) .* curr );
solution = zeros( 0,length(w) );
	
if lev == length(w)
	if ( thesum == k )
		solution = curr;
	end
else
	nxt = 0;
	while thesum + nxt * w(lev+1) <= k
		solution = [solution ; diophantineRecurse( w,k,lev+1,[curr nxt] ) ];
		nxt = nxt + 1;
	end
end	
