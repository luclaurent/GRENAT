function [out] = Rastrigin(varargin)

% Rastrigin (SUMO)
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
%	[out] = Rastrigin(varargin)
%
% Description:
%	f(x) = sum([x.^2-10*cos(2*pi*x) + 10], 2);
%
%	x = N element row vector containing [x0, x1, ..., xN]

% 	example: cost = Rastrigin([1,2;5,6;0,-50])
% 	note: known minimum =0 @ all x = 0

in = [varargin{:}];

%Scale to [-5.12,5.12]
in = in*5.12;

cos_in = cos(2*pi*in);
out = sum((in.^2-10*cos_in + 10), 2);
