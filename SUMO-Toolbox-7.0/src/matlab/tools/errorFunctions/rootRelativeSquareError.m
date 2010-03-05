function e = rootRelativeSquareError( a,b )

% rootRelativeSquareError (SUMO)
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
%	e = rootRelativeSquareError( a,b )
%
% Description:
%	Computes Root Relative Squared Error (RRSE) between a (true values) and b (predicted values)

% calculate the sum squared error
SSE = sumSquareError(a,b);

% calculate the deviations from the mean (total sum of squares)
SST = sumSquareError(a,repmat(mean(a,1),size(a,1),1));

e = sqrt(SSE ./ SST);
