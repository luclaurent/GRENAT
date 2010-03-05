function s = directFit( s, samples, values )

% directFit (SUMO)
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
%	s = directFit( s, samples, values )
%
% Description:
%	Fit the BF model directly

[inDim outDim] = getDimensions(s);

nSamples = size( samples, 1 );
dimension = size( samples, 2 );

% Build regression part matrix
if s.config.degrees < 0
	regressionmatrix = zeros( nSamples, 0 );
	degrees = [];
else
	degrees = makeEvalGridInverted( cfix( { 0:s.config.degrees }, dimension ) );
	regressionmatrix = buildVandermondeMatrix( samples, degrees, cfix( @chebyshevBase, inDim ) );
end
regcoeff = size(regressionmatrix,2);

% Build the kernel part matrix
distancematrix = buildDistanceMatrix( samples, samples );
rbfmatrix = feval( translateBasisFunction( s ), ...
	distancematrix, s.config.func.theta );

%{
% Add smoothing by offsetting the diagonal elements,
% smoothing is then done in the sense that the
% native space norm is minimized along with the deviation
% in the sample points.
if s.config.lambda ~= 0
	rbfmatrix = rbfmatrix + s.config.lambda * eye(size(rbfmatrix));
end
%}

% Combine
matrix = [ regressionmatrix rbfmatrix ; ...
	zeros(regcoeff) regressionmatrix.' ];
values = [ values ; zeros(regcoeff,1) ];
	
% Calculate coefficients
coeff = matrix \ values;

s.fit.degrees = degrees;
s.fit.centers = samples;
s.fit.regressionCoefficients = coeff(1:regcoeff);
s.fit.regressionMatrix = regressionmatrix;
s.fit.rbfmatrix = rbfmatrix;
s.fit.kernelCoefficients = coeff(regcoeff+1:end);
s.fit.type = 'Direct';
