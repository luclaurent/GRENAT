function values = rbfThinPlateSpline( r, alpha )

% rbfThinPlateSpline (SUMO)
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
%	values = rbfThinPlateSpline( r, alpha )
%
% Description:
%	The thin plate spline radial basis function. First parameter is a scaling...

tmp = find( r == 0 );
r(tmp) = 1;  % to avoid log(0)
values = log( abs(r) * alpha(1) ) .* r.^2 * alpha(1)^2;
values(tmp) = 0;
