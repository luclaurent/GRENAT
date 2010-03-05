function e = rSquared( a,b )

% rSquared (SUMO)
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
%	e = rSquared( a,b )
%
% Description:
%	Computes the coefficient of determination R2 between a (true values) and b (predicted values)

% calculate the sum squared error
SSE = sumSquareError(a,b);

% calculate the deviations from the mean (total sum of squares)
SST = sum((a - repmat(mean(a,1),size(a,1),1)).^2);

e = 1 - (SSE ./ SST);
