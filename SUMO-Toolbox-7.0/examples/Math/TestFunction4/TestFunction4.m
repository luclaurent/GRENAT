function [out] = TestFunction4(varargin)

% TestFunction4 (SUMO)
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
%	[out] = TestFunction4(varargin)
%
% Description:
%	Test function from the paper
%	D. Busby, C.L. Farmer, and A. Iske:
%	Hierarchical Nonlinear Approximation for Experimental Design and Statistical Data Fitting.
%	SIAM Journal on Scientific Computing, 29(1), 2007, 49-69.

% create input array
data = [varargin{:}];

%Scale to [-8,8]
data = data * 8;

x = data(:,1);
y = data(:,2);
z = data(:,3);

eps = 10e-7;

out = 7 * ( (sin(sqrt(x.^2 + y.^2)) + eps ) ./ (sqrt(x.^2 + y.^2)) ) + 3 .* sqrt(abs(x - y)) + 0.001 .* z;

