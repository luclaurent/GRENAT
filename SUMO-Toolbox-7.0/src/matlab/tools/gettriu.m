function [d] = gettriu(m)

% gettriu (SUMO)
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
%	[d] = gettriu(m)
%
% Description:
%	Return only the upper triangular part of a matrix (not including the
%	diagonal) in a linear vector, in column-major order. This is useful to
%	get a list of all the unique intersite distances from the matrix
%	returned by buildDistanceMatrix.

n = size(m,1);
d = m((mod(1:n^2,n) <= floor([1:n^2]./n)) & (mod(1:n^2,n) ~= 0));



end

