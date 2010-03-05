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

import java.util.logging.*;
logger = Logger.getLogger('Matlab.RBFModel');

if isempty( s.fit )
	values = zeros(size(points,1),1);
	return
end

[inDim outDim] = getDimensions(s);

switch s.config.backend
	case {'FastRBF','AP','Greedy'}
		
		msg = 'RBFModel does not support variance when using a FastRBF, AP or Greedy backend...';
		logger.severe(msg);
		error(msg);
				
		%locs = struct( 'Location', points.' );
		%values = getfield( fastrbf_pointeval( s.fit, locs ), 'Value' ).';
	case {'Direct','direct'}
		nPoints = size( points, 1 );
		values = zeros( nPoints, 1 );
		
		% See Sacks 1989, Gibs 1997 and Sobester 2005
		% TODO: simple implementation, can process multiple points now.
		% => still slow but it works. more is calculated than needed (only the diagonal is needed). make it as fast as DACE (avoid inv(matrices) ) ? 
		
		% k is the covariance of the to be predicted point
		% in kriging every correlation function would give: r(x,x)=1.
		% this is the case too for rbfMultiQuadric, rbfGaussian and
		% rbfExponential (are there others ?)
		k = 1; % if other BF are found, one can just call the BF with parameter 0 (dist(x,x)=0)
		if isempty(s.fit.degrees)
			rbfmatrixInv = inv(s.fit.rbfmatrix);
		else
			zeroMatrix = zeros( size(s.fit.regressionMatrix,2), size(s.fit.regressionMatrix, 2) );
			bigMatrix = [zeroMatrix s.fit.regressionMatrix';s.fit.regressionMatrix s.fit.rbfmatrix];
			bigMatrix = inv(bigMatrix);		
		end
		step = 1000; % good enough, if not enough memory -> lower value
			
		for start=1:step:nPoints
			stop = min(start+step-1,nPoints);
		
			distanceMatrix = buildDistanceMatrix( points(start:stop,:), s.fit.centers );
			r = feval( translateBasisFunction( s ), ...
				distanceMatrix, s.config.func.theta );
			
			if isempty(s.fit.degrees)
				% k - r * inv(R) * r'
				values(start:stop) = k - diag(r * rbfmatrixInv * r'); % s.fit.kernelCoefficients;
			else
				% Equation from Sacks et al.
				%               (0 F')-1 (f)
				% k - (f' r') * (F R ) * (r)          (
				% Difference: f,r are row vectors here. so they are
				% transposed.
				
				f = buildVandermondeMatrix( points(start:stop,:), ...
					s.fit.degrees, cfix( @chebyshevBase, inDim ) );	
				
				values(start:stop) = k - diag([f r] * bigMatrix * [f' ; r']);
			end
		end
end
