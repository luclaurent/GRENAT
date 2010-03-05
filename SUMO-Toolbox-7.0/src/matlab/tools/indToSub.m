function coords = indToSub( gridSize, indices )

% indToSub (SUMO)
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
%	coords = indToSub( gridSize, indices )
%
% Description:
%	Convert plain array indices to multi-indices.

d = length(gridSize);
N = length(indices);

coords = zeros(N,d);
indices = indices - 1;

for k=1:d
	coords(:,k) = mod( indices, gridSize(k) ) + 1;
	indices = fix( indices / gridSize(k) );
end
