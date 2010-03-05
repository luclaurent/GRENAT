function d = avgDistance( p )

% avgDistance (SUMO)
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
%	d = avgDistance( p )
%
% Description:
%	Return the average distance between a set of points p (in column format, one column per dimension)

dist = buildDistanceMatrix(p);
t = triu(dist);
n = sum( 1:(size(dist,2)-1) );
d = sum(sum(t)) / n;
