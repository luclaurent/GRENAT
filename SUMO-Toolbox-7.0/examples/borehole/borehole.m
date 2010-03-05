function f = borehole(x)

% borehole (SUMO)
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
%	f = borehole(x)
%
% Description:

function f = borehole(x)

rw = x(:,1);
r = x(:,2);
Tu = x(:,3);
Hu = x(:,4);
Tl = x(:,5);
Hl = x(:,6);
L = x(:,7);
Kw = x(:,8);

rrw = log(r/rw);

num2 = 2*L*Tu;
denom2 = rrw*rw^2*Kw;

num = 2*pi*Tu*(Hu-Hl);
denom = rrw*(1+num2/denom2)+Tu/Tl;

f = num / denom; % flow rate

end
