function out = GoldsteinPrice(varargin)

% GoldsteinPrice (SUMO)
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
%	out = GoldsteinPrice(varargin)
%
% Description:
%	The Goldstein Price test function

% create input array
x = [varargin{:}];

% number of inputs
n = size(x,2);

% scale input array from [-1,1] to [-2 2]
x = x*2;

x1 = x(:,1);
x2 = x(:,2);

out = (1+(x1+x2+1).^2.*(19-14.*x1+3.*x1.^2-14.*x2+6.*x1.*x2+3.*x2.^2)).*(30+(2.*x1-3.*x2).^2.*(18-32.*x1+12.*x1.^2+48.*x2-36.*x1.*x2+27.*x2.^2));
