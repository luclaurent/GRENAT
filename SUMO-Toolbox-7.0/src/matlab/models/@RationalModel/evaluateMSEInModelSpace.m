function mse = evaluateMSEInModelSpace(this, points)

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
%	mse = evaluateMSEInModelSpace(this, points)
%
% Description:
%	Evaluation at a set of points

N = size(points,1);

%getDescription(s)

[numdegrees,dendegrees] = getDegrees( this.degrees, this.freedom );
[dim_in, dim_out] = this.getDimensions();

% Adjust frequency to complex samples
if this.frequencyVariable ~= 0
      points(:,this.frequencyVariable) = j * ( 2 + points(:,this.frequencyVariable) );
end

values = evaluateInModelSpace( this, points );
mse = zeros( N, dim_out );
step=1; % 100
for start=1:step:N
	stop = min(N,start+step-1);
	
	MN = buildVandermondeMatrix( points(start:stop,:), numdegrees, this.baseFunctions );
	MD = buildVandermondeMatrix( points(start:stop,:), dendegrees, this.baseFunctions );

	for k=1:dim_out
		F = diag( values(start:stop,k) );
		X = [MN -F*MD];
		mse(start:stop,k) = X(1,:) * this.covarianceMatrix{k} * X(1,:)';
	end
end
