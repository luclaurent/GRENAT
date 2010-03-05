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

[inDim outDim] = getDimensions(this);
[numdegrees,dendegrees] = getDegrees( this.degrees, this.freedom );

% Adjust frequency to complex samples
if this.frequencyVariable ~= 0
      points(:,this.frequencyVariable) = j * ( 2 + points(:,this.frequencyVariable) );
end

values = zeros( size( points,1 ), outDim );
for start=1:100:size(points,1)
	stop = min(size(points,1),start+99);
	MN = buildVandermondeMatrix( points(start:stop,:), numdegrees, this.baseFunctions );
	MD = buildVandermondeMatrix( points(start:stop,:), dendegrees, this.baseFunctions );

	for k=1:outDim
		values(start:stop,k) = (MN * this.numerator{k}) ./ (1.0 + MD * this.denominator{k});
	end
end
