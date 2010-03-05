function values = evaluateOnGrid( points, coeff, degrees, baseFunctions )

% evaluateOnGrid (SUMO)
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
%	values = evaluateOnGrid( points, coeff, degrees, baseFunctions )
%
% Description:
%	Slow but neat implementation of the grid evaluation
%	It involves isolating the singleton dimensions (i.e.
%	columns where degrees only contains zeros) and doing
%	matrix permutations and reshapes for the other dimensions
%	in order to arrive at the solution. Pretty straightforward
%	after some reflection...

% Find maxima in degrees, select degrees 
% not present (only value 0)
sizes = max( [zeros(1,size(degrees,2)) ; degrees],[],1 ) + 1;
idx = find( sizes > 1 );
const = find( sizes == 1 );

% fill 'l' with the lengths of each dimension 
% of points
l = ones(1,length(sizes));
for i=1:length(points)
	l(i) = length(points{i});
end

% Drop all unused variables
mx = sizes(idx);
npoints = {points{idx}};
bfs = {baseFunctions{idx}};
ndegrees = degrees(:,idx);

% Split sizes s.t. l .* r == sizes
r = l;
l(const) = 1;
r(idx)   = 1;

% No degrees ? -> just return zero
if isempty(mx)
	alpha = 0;
% 1 degree -> Gave rise to problems with permute
% and reshape, handle seperately
else if length(mx) == 1
%  	alpha = ( repmat( npoints{1}(:), 1, length(coeff)) ) .^ repmat( 0:length(coeff)-1, length(npoints{1}), 1 ) * coeff;
	alpha = buildVandermondeMatrix( npoints{1}(:), (0:length(coeff)-1).', {bfs{1}} ) * coeff;
% 2 or more degrees -> Use a block-matrix algorithm
% looks more complex than it actually is...
else
	% Arrange coefficients in a Hypercube alpha
	alpha = zeros(mx);
	while size(ndegrees,2) > 1
		ndegrees = [ndegrees(:,1:end-2) ndegrees(:,end) * mx(size(ndegrees,2)-1) + ndegrees(:,end-1)];
	end
	alpha( ndegrees+1 ) = coeff;
	
	d = length( npoints );
	psizes = [];
	asizes = size( alpha );
	
	% Now do stuff with it: permute - multiply - reshape - pernmute - reshape
	% Not complicated but difficult to explain in ascii art, maybe in docs
	for i=1:d
		pts = npoints{i};
		pts = pts(:);
		sz = size( alpha,1 );
%  		matrix = ( repmat( pts, 1, sz) ) .^ repmat( 0:sz-1, length(pts), 1 );
		matrix = buildVandermondeMatrix( pts, (0:sz-1).', {bfs{i}} );
		gamma = matrix * reshape( alpha, sz, numel( alpha ) / sz );
		alpha = permute( reshape( gamma, [length(pts) asizes(i+1:end) psizes] ), [2:d 1] );
		psizes = [psizes length(pts)];
	end
end, end

values = repmat( reshape( alpha, l ), r );
