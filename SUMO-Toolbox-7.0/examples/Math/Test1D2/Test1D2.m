function out = Test1D2(varargin)

% Test1D2 (SUMO)
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
%	out = Test1D2(varargin)
%
% Description:
%	Test function

x = varargin{1};

out = ones(length(x),1)*2;

I1 = find(x > -1);
I2 = find(x < 2.5*pi);
I3 = intersect(I1,I2);

out(I3) = sinc(x(I3)) + 2;
