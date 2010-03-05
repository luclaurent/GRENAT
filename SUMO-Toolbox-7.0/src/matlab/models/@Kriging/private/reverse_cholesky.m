function Radj = reverse_cholesky( L2, Ladj )

% reverse_cholesky (SUMO)
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
%	Radj = reverse_cholesky( L2, Ladj )
%
% Description:
%	L2 = L = C (lower triangular)
%	DISABLED: need for speed...

n = size(Ladj, 1);

Radj = Ladj;
for k=n:-1:1
    
    for j=k+1:n
        for i=j:n
            Radj(i,k) = Radj(i,k) - Radj(i,j)*L2(j,k);
            Radj(j,k) = Radj(j,k) - Radj(i,j)*L2(i,k);
        end
    end
    
    for j=k+1:n
        Radj(j,k) = Radj(j,k) ./ L2(k,k);
        Radj(k,k) = Radj(k,k) - L2(j,k) .* Radj(j,k);
    end
    
    Radj(k,k) = Radj(k,k) ./ (2.*L2(k,k));
end

end
