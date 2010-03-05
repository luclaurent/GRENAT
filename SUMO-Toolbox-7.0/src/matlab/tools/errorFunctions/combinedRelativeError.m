function e = combinedRelativeError( a, b )

% combinedRelativeError (SUMO)
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
%	e = combinedRelativeError( a, b )
%
% Description:
%	Calculates the combined relative error between a (true) and b (predicted).
%	This is an ajusted relative error, it becomes an absolute error if the absolute value of a is close to zero

e = abs( a - b ) ./ ( 1 + abs(a) );
