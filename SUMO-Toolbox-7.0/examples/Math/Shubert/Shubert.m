function [y] = Shubert(x1,x2)

% Shubert (SUMO)
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
%	[y] = Shubert(x1,x2)
%
% Description:
%	The Shubert function

%Scale to [-10,10]
x1 = x1*10;
x2 = x2*10;

s1 = 0; 
s2 = 0;
for i = 1:5;   
    s1 = s1+i*cos((i+1)*x1+i);
    s2 = s2+i*cos((i+1)*x2+i);
end
y = s1*s2;
