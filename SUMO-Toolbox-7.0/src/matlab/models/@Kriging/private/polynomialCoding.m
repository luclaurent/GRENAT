function [U dU] = polynomialCoding( samples, m, k, delta )

% polynomialCoding (SUMO)
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
%	U = polynomialCoding( samples, m, k, delta )
%
% Description:
%	Encodes the sample matrix using polynomial contrasts
%	See book Hamada
%	+ http://www.stat.ncsu.edu/people/dickey/st512/lab09/OrthPoly.html
%

n = size(samples,1);
U = zeros(n, k-1 );
dU = zeros(n, k-1 );
if k > 1
	U(:,1) = (samples - m)./ delta;
	dU(:,1) = (1-m) ./ delta;

	if k > 2
		U(:,2) = U(:,1).^2 - (k.^2 - 1) ./ 12;
		dU(:,2) = 2.*U(:,1).*dU(:,1) - (k.^2 - 1) ./ 12;

		if k > 3
			U(:,3) = U(:,1).^3 - U(:,1).*((3.*k.^2-7) ./ 20);
			dU(:,3) = 3.*U(:,1).^2.*dU(:,1) - dU(:,1).*((3.*k.^2-7) ./ 20);

			if k > 4
				U(:,4) = U(:,1).^4 - U(:,1).^2.*((3.*k.^2-13) ./ 14) + (3.*(k.^2-1).*(k.^2-9)) ./ 560;
				dU(:,4) = 4.*U(:,1).^3.*dU(:,1) - 2.*U(:,1).*dU(:,1).*((3.*k.^2-13) ./ 14) + (3.*(k.^2-1).*(k.^2-9)) ./ 560;
			end
		end
	end
end	

end
