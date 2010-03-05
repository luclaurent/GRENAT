function out = Ackley(varargin)

% Ackley (SUMO)
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
%	out = Ackley(varargin)
%
% Description:
%	Ackleys function

% create input array
in = [varargin{:}];
n = size(in,2);

%scale to [-2 2]
in = in * 2;

a = 20;
b = 0.2;
c = 2*pi;

out = zeros(size(in,1),1);
for i = 1:size(in,1)
    p = in(i,:);
    out(i) = - a * exp( -b * sqrt( (1/n) * sum(p .^ 2))) - exp((1/n) * sum(cos(c .* p))) + a + exp(1);
end
