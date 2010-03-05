function s = update( s, n )

% update (SUMO)
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
%	s = update( s, n )
%
% Description:
%	Update the degree class such that a request to return
%	degrees smaller than or equal to n will succeed later on.

% Switch implementations :)

if 0
	
	% While we haven't got enough of 'em...
	while s.sums(end) < n
		s.level = s.level + 1;
		% solve diophantine equation w' * x = s.level
		newdegrees = diophantine( s.weights, s.level );
		% add solution
		s.degrees = [s.degrees ; newdegrees];
		% upgrade utility structures,
		% these are used by the indexing procedure to
		newmarks = (newdegrees * s.flags) == 0;
		s.marks = [s.marks ; newmarks];
		s.sums = [s.sums ; cumsum( newmarks + 1 ) + s.sums(end) ];
	end

else
	import ibbt.sumo.algorithms.*;
	
	% Call the Java diopantine solver, request at least `n' solutions
	solutions = DiophantineSolver.request( s.weights, n );
	solutions = reshape( solutions, s.dimension + 1, length(solutions) / (s.dimension+1) );

	% Sort and reorder by score, clip off score (last row)
	solutions = sortrows( solutions' );
	solutions = solutions( :, 2:end );
	s.degrees = double(solutions);
	
	% Generate marks
	s.marks = (s.degrees * s.flags) == 0;
	s.marks(1) = 0;
	
	% Generate sums
	s.sums = cumsum( s.marks + 1 );
end
