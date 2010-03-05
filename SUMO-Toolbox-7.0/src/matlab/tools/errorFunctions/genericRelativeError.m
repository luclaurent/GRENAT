function e = genericRelativeError( a, b )

% genericRelativeError (SUMO)
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
%	e = genericRelativeError( a, b )
%
% Description:
%	Calculate relative error between `a' and `b' scaling with the average of a and b
%	This is useful if one does not know which one of the two are the real values,
%	or if there is no 'real' data (e.g., comparing two models)

e = abs( a - b ) ./ ( 1 + (abs(a)+abs(b))/2 );
