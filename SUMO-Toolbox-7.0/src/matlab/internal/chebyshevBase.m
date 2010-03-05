function base = chebyshevBase( x, d )

% chebyshevBase (SUMO)
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
%	base = chebyshevBase( x, d )
%
% Description:
%	Build a (second order) Chebyshev basis matrix.

base = [ones(size(x)) 2*x];
for j=2:d
	base = [ base 2*x.*base(:,end) - base(:,end-1) ];
end

% when d == 1, we got one term to many. just return exactly d+1 terms
base = base(:, 1:d+1 );
