function [s,residues] = buildRegressionPart( s, samples, values )

% buildRegressionPart (SUMO)
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
%	[s,residues] = buildRegressionPart( s, samples, values )
%
% Description:
%	Basicly this does a least squares polynomial fit with polynomials
%	of degrees up to s.config.degrees through all samples and values.
%	It then fills out the correct fields in the `fit' record to correspond
%	to the interpolant found, and returns the remaining residues

if s.config.degrees < 0
	degrees = [];
	regressionmatrix = [];
	regressioncoefficients = [];
	residues = values;
else
	degrees = makeEvalGridInverted( cfix( { 0:s.config.degrees }, size(samples,2) ) );
	regressionmatrix = buildVandermondeMatrix( samples, degrees, cfix( {@chebyshevBase}, size(samples,2) ) );
	regressioncoefficients = regressionmatrix \ values;
	residues = values - regressionmatrix * regressioncoefficients;
end
s.fit.degrees = degrees;
s.fit.regressionCoefficients = regressioncoefficients;
s.fit.regressionmatrix = regressionmatrix;
