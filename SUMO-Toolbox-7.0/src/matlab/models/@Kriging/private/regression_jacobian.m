function jacobian = regression_jacobian(degrees, samples)

% regression_jacobian (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	jacobian = regression_jacobian(degrees, samples)
%
% Description:
%	 calculates jacobian from a degrees+sample matrix
%	Used for deriving polynomials, rationals etc.
%	 INCOMPLETE

	[m n] = size(degrees);
	
	jacobian = zeros( n, m );
	
	for i=1:n
		ddegrees = degrees; % copy
		ddegrees(:,i) = degrees(:,i)- ones(m,1); % derivative = exponent of that variable minus one
		
		% memorize variables that have negative exponent now (means they
		% are 0)
		[idx dummy] = find( ddegrees < 0 );
		ddegrees(idx,:) = 0;

		% get model matrix for that
		jacobian(i,:) = buildVandermondeMatrix( samples(1,:), ddegrees, cfix( @powerBase, n )  );
		
		% multiply by original exponent
		jacobian(i,:) = jacobian(i,:) .* degrees(:,i).';
	end
end
