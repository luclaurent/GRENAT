function values = evaluateInModelSpace( this, points )

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
%	values = evaluateInModelSpace( this, points )
%
% Description:
%	Evaluate @ discrete points, given by the M \times dim
%	array points.

[dim_in dim_out] = this.getDimensions();
values = zeros( size( points,1 ), dim_out );

for start=1:100:size(points,1)
	stop = min(size(points,1),start+99);
	
	M = buildVandermondeMatrix( points(start:stop,:), this.degrees, this.baseFunctions );

	for k=1:dim_out
		values(start:stop,k) = M * this.beta{k};
	end
end

