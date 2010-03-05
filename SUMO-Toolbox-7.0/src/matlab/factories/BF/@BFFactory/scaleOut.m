function x = scaleOut( s, x, spec )

% scaleOut (SUMO)
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
%	x = scaleOut( s, x, spec )
%
% Description:
%	Take parameters within the RBF spec ranges and
%	map them to percentages.

for k=1:length(spec.min)
	if (strcmp(spec.scale{k},'ln'))
		x(k) = ( log( x(k) ) - log( spec.min(k) ) ) ...
			/ ( log( spec.max(k) ) - log( spec.min(k) ) );
	else % linear
		x(k) = ( x(k) - spec.min(k) ) ...
			/ ( spec.max(k) - spec.min(k) );
	end
end
