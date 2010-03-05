function this = constructInModelSpace( this, samples, values )

% constructInModelSpace (SUMO)
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
%	this = constructInModelSpace( this, samples, values )
%
% Description:
%	Build a polynomial model through the samples and values
%	 degrees : a structure returning the order in which degrees of freedom
%	     are selected

this = this.constructInModelSpace@Model(samples, values);

[dim_in dim_out] = this.getDimensions();

this.baseFunctions = cfix( this.baseFunctions, dim_in );

% fit each output
for i=1:dim_out
	
	% construct model matrix
	M = buildVandermondeMatrix( samples, this.degrees, this.baseFunctions );

	% solve equation (least squares)
	[this.beta{i}, stdx,mse,S] = lscov( M, values(:,i) );
	this.covariance_matrix{i} = S ./ mse;
end
