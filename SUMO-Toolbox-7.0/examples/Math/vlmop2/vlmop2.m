function f = vlmop2(x1,x2)

% vlmop2 (SUMO)
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
%	f = vlmop2(x1,x2)
%
% Description:

dim = 2;

transl = 1./sqrt(dim);
part1 = (x1 - transl).^2 + (x2 - transl).^2;
part2 = (x1 + transl).^2 + (x2 + transl).^2;

f(:,1) = 1 - exp( -part1 );
f(:,2) = 1 - exp( -part2 );
