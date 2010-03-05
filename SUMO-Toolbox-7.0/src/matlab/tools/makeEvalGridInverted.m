function evalgrid = makeEvalGridInverted( gridpoints, gridsize )

% makeEvalGridInverted (SUMO)
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
%	evalgrid = makeEvalGridInverted( gridpoints, gridsize )
%
% Description:
%	Low-level procedure, makes a `prod(gridsize)' by `length(gridsize)'
%	array, where each row is a different vector, where the i th
%	element is a number out of `gridpoints{i}'.
%	The `gridsize' parameter may be omitted, in that case it's generated
%	from `gridpoints'. The order in which the elements are returned is
%	of major importance to some the calling functions, maintain reverse
%	lexicographic row order!
%	WARNING: this is legacy code. Because the original makeEvalGrid used
%	an unusual inverse lexographic row order, this function was created
%	to be able to support old code from Wouter which relies on this
%	order. Use makeEvalGrid instead.
%
%	Example:
%	makeEvalGrid( { [-1, .5], [-1 0 1], [.2 .3] }, [2 3 2] )
%	ans =
%	-1.0000   -1.0000    0.2000
%	 0.5000   -1.0000    0.2000
%	-1.0000         0    0.2000
%	 0.5000         0    0.2000
%	-1.0000    1.0000    0.2000
%	 0.5000    1.0000    0.2000
%	-1.0000   -1.0000    0.3000
%	 0.5000   -1.0000    0.3000
%	-1.0000         0    0.3000
%	 0.5000         0    0.3000
%	-1.0000    1.0000    0.3000
%	 0.5000    1.0000    0.3000

dimension = length(gridpoints);

if nargin == 1
	gridsize = zeros(dimension,1);
	for i=1:dimension
		gridsize(i) = length(gridpoints{i});
	end
else
	for i=1:dimension
		assert( length(gridpoints{i}) == gridsize(i), '[E] Parameter conflict' )
	end
end

evalgrid = makeGridInverted( gridsize(:) );

for i=1:dimension
	tmp = gridpoints{i}( evalgrid(:,i) );
	evalgrid(:,i) = tmp(:);
end
