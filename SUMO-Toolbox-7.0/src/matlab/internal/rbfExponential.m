function values = rbfExponential( r, alpha )

% rbfExponential (SUMO)
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
%	values = rbfExponential( r, alpha )
%
% Description:
%	exponential radial basis function
%	First row of alpha are the exponents,
%	Second row of alpha are the scaling factors

values = exp( - abs(r) .^ alpha(2) * alpha(1) );
