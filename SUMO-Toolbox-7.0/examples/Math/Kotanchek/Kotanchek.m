function [exact noisy] = Kotanchek(varargin)

% Kotanchek (SUMO)
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
%	[exact noisy] = Kotanchek(varargin)
%
% Description:
%	Kotanchek function with 2 inputs and 2 outputs

% create input array
in = [varargin{:}];
n = size(in,2);

x = in(:,1);
y = in(:,2);

x = (x + 1.0) * 2.0 - 2.5;
y = (y + 1.0) * 2.0 - 1.0;

exact = exp( -y .* y ) ./ (1.2 + x.^2 );
noisy = exact + 0.0001 * (2*rand - 1.0);
