function e = geometricRelativeError( a,b )

% geometricRelativeError (SUMO)
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
%	e = geometricRelativeError( a,b )
%
% Description:
%	Computes the Geometric Relative error (GRE) between a
%	(true) and b (predicted).

% calculate the log for numerical reasons

e = sum(log(relativeError(a,b)),1) ./ size(a,1);

e = exp(e);
