function m = buildVandermondeMatrix( samples, degrees, baseFunctions )

% buildVandermondeMatrix (SUMO)
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
%	m = buildVandermondeMatrix( samples, degrees, baseFunctions )
%
% Description:
%	Build multidimensional Vandermonde like matrix for interpolation
%	and/or evaluation of multidimensional polynomials.

if 0
	m = mxVandermondeMatrix( samples, degrees, baseFunctions );
else
	
	[n,d] = size(samples);
	[ndegrees,d2] = size( degrees );
	assert( d==d2, 'Dimension mismatch' );
	
	m = ones(n,ndegrees);
	for dim=1:d
		baseValues = feval( baseFunctions{dim}, samples(:,dim), max([0; degrees(:,dim)]) );
		m = m .* baseValues(:,degrees(:,dim).'+1);
	end
end
