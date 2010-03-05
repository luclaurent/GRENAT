function distances = buildDistanceMatrixPoint(samples, point, doSqrt)

% buildDistanceMatrixPoint (SUMO)
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
%	distances = buildDistanceMatrixPoint(samples, point, doSqrt)
%
% Description:
%	Calculates the distance of all points in samples from point.
%	The parameter doSqrt indicates if the square root should be taken of the final matrix
%	in order to get 'real' distances.  Set to 0 to save time.  Defaults to 1.

if nargin == 2
	doSqrt = 1;
end

distances = samples - point(ones(size(samples,1),1), :);
distances = sum(distances .^ 2, 2);

% do square root?
if doSqrt
	distances = sqrt(distances);
end
