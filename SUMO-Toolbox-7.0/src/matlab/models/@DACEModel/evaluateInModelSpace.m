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

[inDim outDim] = getDimensions(s);

% First evaluate the trend part...
trendMatrix = buildVandermondeMatrix( points, s.trendDegrees, cfix( @chebyshevBase, inDim ) );
trend = trendMatrix * s.trendCoeff;

% Then evaluate the kernels..
kernelmatrix = s.buildKernelMatrix( points, getSamplesInModelSpace(s), s.config.func );

% Evaluate by summing...
values = trend + kernelmatrix * s.kernelCoeff;
