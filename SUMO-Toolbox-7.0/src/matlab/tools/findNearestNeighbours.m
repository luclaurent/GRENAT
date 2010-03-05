function [nn idx] = findNearestNeighbours( points, queryPoint, n )

% findNearestNeighbours (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	[nn idx] = findNearestNeighbours( points, queryPoint, n )
%
% Description:
%	Given a matrix of points, find the n points (default 1) that are
%	closest to the query point.

if(~exist('n','var'))
    n = 1;
end

distances = buildDistanceMatrix( points, queryPoint, false);

[Y I] = sort(distances,1,'ascend');

nn = points(I(1:n),:);
idx = I(1:n);
