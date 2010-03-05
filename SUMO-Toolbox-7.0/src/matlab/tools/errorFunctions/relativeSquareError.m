function e = relativeSquareError( a,b )

% relativeSquareError (SUMO)
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
%	e = relativeSquareError( a,b )
%
% Description:
%	Computes Relative Squared Error (RSE) between a (true values) and b (predicted values)

% calculate the mean square error
MSE = meanSquareError(a,b);

% calculate the variance
variance = var(a,1);

% note that both the MSE and variance include a division by N (number of points)
% this cancels out in the division when calculating the errors
e = MSE ./ variance;
