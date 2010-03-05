function [y] = Schwefel(varargin)

% Schwefel (SUMO)
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
%	[y] = Schwefel(varargin)
%
% Description:
%	Schwefels function

x = [varargin{:}];

%Scale to [-500,500]
x = x * 500;

%dimension n
n = size(x,2);
s = sum(-x .* sin(sqrt(abs(x))),2);
y = 418.9829*n+s;
