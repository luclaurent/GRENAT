function [sample, gridsize] = latinHypercubeSample( dimension, n )

% latinHypercubeSample (SUMO)
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
%	[sample, gridsize] = latinHypercubeSample( dimension, n )
%
% Description:
%	Generate a random LH design in `dimension' dimensional
%	cube [-1,1]^dimension consisting of n points
%
%	Example:
%	>> latinHypercubeSample( 3,4 )
%	ans =
%	 -0.0102   -0.3047    0.1520
%	  0.2862    0.7790    0.9385
%	 -0.6080   -0.8358   -0.3550
%	  0.6854    0.1308   -0.6352

% construct integers
sample = zeros(n,0);
for i=1:dimension
	sample = [ sample randperm(n)' ];
end
gridsize=repmat( n, 1, dimension );
