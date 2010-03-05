function L2adj = reverse_forwardSub( T1adj, L2, T1 )

% reverse_forwardSub (SUMO)
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
%	L2adj = reverse_forwardSub( T1adj, L2, T1 )
%
% Description:
%	L2 = L = C (lower triangular)
%	DISABLED: need for speed...

n = length(T1);

for i=n:-1:2
    aadj(i) = T1adj(i) ./ L2(i,i);
    L2adj(i,i) = -aadj(i) .* T1(i);
    
    for j=1:i-1
        L2adj(i,j) = -aadj(i) .* T1(j);
        T1adj(j) = T1adj(j) - aadj(i) .* L2(i,j);
    end
end

aadj(1) = T1adj(1) ./ L2(1,1);
L2adj(1,1) = -aadj(1) .* T1(1);

end
