function kernelmatrix = buildKernelMatrix(this, points, samples, kernels )

% buildKernelMatrix (SUMO)
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
%	kernelmatrix = buildKernelMatrix(this, points, samples, kernels )
%
% Description:
%	Build the matrix related to the kernel function interactions...
%	Basically : M_{ij} = \prod_{k=1}^d K_k( points_{ik}, samples_{jk} )

kernelmatrix = ones( size(points,1),size(samples,1) );
for i=1:length(kernels)
	distancematrix = buildDistanceMatrix( points(:,i), samples(:,i) );
	t = kernels(i).theta;
	f = kernels(i).func;
	kernelmatrix = kernelmatrix .* feval( f, distancematrix, t );
end
