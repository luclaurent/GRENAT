function [L1adj, T1adj] = reverse_backwardSub( T2adj, L1, T2 )

% reverse_backwardSub (SUMO)
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
%	[L1adj, T1adj] = reverse_backwardSub( T2adj, L1, T2 )
%
% Description:
%	L1 = L' = C' (upper triangular)
%	DISABLED: need for speed...

n = length(T2);

% T2adj changes...
%T1adj = T2adj ./ diag(L1);
%L1adj = triu( - T1adj2 * T2' );

for i=1:n-1
    T1adj(i) = T2adj(i) ./ L1(i,i);
    L1adj(i,i) = -T1adj(i) .* T2(i);
    
    for j=i+1:n
        L1adj(i,j) = -T1adj(i) .* T2(j);
        T2adj(j) = T2adj(j) - T1adj(i) .* L1(i,j);
    end
end

T1adj(n) = T2adj(n) ./ L1(n,n);
L1adj(n,n) = -T1adj(n) .* T2(n);
end
