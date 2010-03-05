function values = evaluateInModelSpace( s, points )

% evaluateInModelSpace (SUMO)
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
%	values = evaluateInModelSpace( s, points )
%
% Description:
%	Evaluation at a set of points, just straightforward
%	matrix construct and matrix-vector multiply.

if isempty( s.fit )
	values = zeros(size(points,1),1);
	return
end

[inDim outDim] = getDimensions(s);

switch s.config.backend
	case 'FastRBF'
		locs = struct( 'Location', points.' );
		values = getfield( fastrbf_pointeval( s.fit, locs ), 'Value' ).';
	case {'Direct','direct','AP','Greedy'}
		% Evaluate points in blocks of `n' samples to reduce
		% memory usage...
		nPoints = size( points, 1 );
		values = zeros( nPoints, 1 );
		for start=1:1000:nPoints
			stop = min(start+999,nPoints);

            distanceMatrix = buildDistanceMatrix( points(start:stop,:), s.fit.centers );
			kernelMatrix = feval( translateBasisFunction( s ), ...
				distanceMatrix, s.config.func.theta );
			
			if isempty(s.fit.degrees)
				values(start:stop) = kernelMatrix * s.fit.kernelCoefficients;
			else
				regressionMatrix = buildVandermondeMatrix( points(start:stop,:), ...
					s.fit.degrees, cfix( @chebyshevBase, inDim ) );
				values(start:stop) = regressionMatrix * s.fit.regressionCoefficients + ...
					kernelMatrix * s.fit.kernelCoefficients;
			end
		end
end
