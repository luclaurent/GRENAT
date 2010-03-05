function values = evaluateMSEInModelSpace( s, points )

% evaluateMSEInModelSpace (SUMO)
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
%	values = evaluateMSEInModelSpace( s, points )
%
% Description:
%	Evaluation at a set of points, just straightforward
%	matrix construct and matrix-vector multiply.

[inDim outDim] = s.getDimensions();
samples = s.getSamplesInModelSpace();

nPoints = size( points, 1 );
values = zeros( nPoints, 1 );

% See RBFModel for full explanation
zeroMatrix = zeros( size(s.trendMatrix,2), size(s.trendMatrix, 2) );
bigMatrix = [zeroMatrix s.trendMatrix';s.trendMatrix s.kernelMatrix];
bigMatrix = inv(bigMatrix);
k = 1;
step = 1000; % good enough, if not enough memory -> lower value

for start=1:step:nPoints
	stop = min(start+step-1,nPoints);
	
	r = s.buildKernelMatrix( points(start:stop,:), samples, s.config.func );
	f = buildVandermondeMatrix( points(start:stop,:), s.trendDegrees, cfix( @chebyshevBase, inDim ) );

	values(start:stop) = k - diag([f r] * bigMatrix * [f' ; r']);

end

end
