function x = scaleIn( s, x, spec )

% scaleIn (SUMO)
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
%	x = scaleIn( s, x, spec )
%
% Description:
%	Take percentages and map them to suitable values
%	within the RBF theta parameter ranges specified
%	by specs

for k=1:length(spec.min)
	if (strcmp(spec.scale{k},'ln'))
		x(k) = exp( x(k) ...
			* ( log( spec.max(k) ) - log( spec.min(k) ) ) ...
			+ log( spec.min(k) ) );
	else % linear
		x(k) = x(k) * ( spec.max(k) - spec.min(k) ) + spec.min(k);
	end

	x(k) = truncate( x(k), spec.min(k), spec.max(k) );
end
