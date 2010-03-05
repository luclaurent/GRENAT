function out = TestKarel(varargin)

% TestKarel (SUMO)
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
%	out = TestKarel(varargin)
%
% Description:
%	Test function

if nargin == 2
	x = varargin{1};
	y = varargin{2};
else
	x = varargin{1};
	y = ones(1, length(x));
end

out = ((x+1).*3 + exp(x .* 3.5) .* sin(x .* 8 .* pi)) .* (y.^2);
