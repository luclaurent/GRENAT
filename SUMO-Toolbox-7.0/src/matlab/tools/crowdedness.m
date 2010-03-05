function out = crowdedness( p, points )

% crowdedness (SUMO)
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
%	out = crowdedness( p, points )
%
% Description:
%	Calculates the crowdedness at a given design x
%	 or in this case, for all designs in 'points')

nrPoints = size( p, 1 );
N = nrPoints;
dim = size( p, 2 );
L = pdist( [ones(1,dim);-ones(1,dim)] ); % distance from one corner to the other (euclidean)

assert( all( size(L) == [1,1] ) );

% pairwise distance vector
d=buildDistanceMatrix( p, points );
out = zeros( nrPoints, 1 );

n=30;
m=1000;
for i=n:m
	Ri = (i./m) .* L;
	Ni = sum( d <= Ri, 2 ); % produces a column vector
	out = out + (Ni ./ Ri); % .* (L ./ Ri - 1);
end
out = out ./ N; % normalize
