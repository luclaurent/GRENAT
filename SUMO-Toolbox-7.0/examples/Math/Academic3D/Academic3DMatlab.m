function out = Academic3DMatlab(varargin)

% Academic3DMatlab (SUMO)
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
%	out = Academic3DMatlab(varargin)
%
% Description:
%	A 3D test function

% create input array
in = [varargin{:}];

a = in(:,1);
b = in(:,2);
c = in(:,3);

out = exp(c + 2) ./ gamma(b * 3) .* (a + 3) ./ 135.0;
