function s = constructInModelSpace( s, samples, values )

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
%	s = constructInModelSpace( s, samples, values )
%
% Description:
%	Construct a DACE model
%	Model parameters:
%	   Maximal degree of the regression part
%	   Kernelfunction handles
%	   Kernelfunction shape parameters

if(size(values,2) > 1)
	error('The DACE models can not model multiple outputs together, please set combineOutputs to false');
end

s = s.constructInModelSpace@Model(samples, values);

[inDim outDim] = getDimensions(s);

% First construct the trend function, this will be an n-d
% polynomial interpolant with uniform degrees...
degrees = makeGrid( dfix(s.config.degrees+1,inDim ) ) - 1;
sumdegrees = sum( degrees, 2 );
validdegrees = find( sumdegrees <= s.config.degrees );
degrees = degrees(validdegrees,:);

% Solve linear system in least squares sense
s.trendMatrix = buildVandermondeMatrix( samples, degrees, cfix( @chebyshevBase, inDim ) );
trendCoeff = s.trendMatrix \ getValues(s);

% Then interpolate the deviation from the trend separately
s.kernelMatrix = s.buildKernelMatrix( samples, samples, s.config.func );
deviation = getValues(s) - s.trendMatrix * trendCoeff;
kernelCoeff = linsolve( s.kernelMatrix, deviation );

% And assign back to class members for later use
s.trendDegrees = degrees;
s.trendCoeff = trendCoeff;
s.kernelCoeff = kernelCoeff;
