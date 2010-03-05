function res = Michalewicz(varargin)

% Michalewicz (SUMO)
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
%	res = Michalewicz(varargin)
%
% Description:
%	Michalewicz' function

% create input array
in = [varargin{:}];
n = size(in,2);

% scale to [0,pi]
in = (in + 1) .* pi/2;

m = 10;

res = zeros(size(in,1),1);

for j = 1:size(in,1)
	temp = 0;
	for i = 1:n
		temp = temp + sin(in(j,i)) .* sin(i .* in(j,i).^2 ./ pi) .^ (2*m);
	end

	res(j) = -temp;
end
