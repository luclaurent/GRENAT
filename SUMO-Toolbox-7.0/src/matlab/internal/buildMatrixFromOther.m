function A = buildMatrixFromOther(varargin);

% buildMatrixFromOther (SUMO)
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
%	A = buildMatrixFromOther(varargin);
%
% Description:
%	Initializes matrix A with the data in matrix B
%	The dimensions need not match, data in B will
%	be pruned or appended with random values in [min, max]
%	if necessary.
%	The idea is to preserve the information in B as much as possible.
%	Usage: A = buildMatrixFromOther(A,B,[min],[max])
%	       if neigher min/max are specified no random values are added, the original A values are used

if(nargin == 2)
	A = varargin{1};
	B = varargin{2};
	min = NaN;
	max = NaN;
elseif(nargin == 4)
	A = varargin{1};
	B = varargin{2};
	min = varargin{3};
	max = varargin{4};
else
	error('Invalid number of arguments');
end

ra = size(A,1);
ca = size(A,2);

rb = size(B,1);
cb = size(B,2);

if(~(isnan(min) || isnan(max)))  
	A = boundedRand(min,max,ra,ca);
end

if(ra >= rb)
	if(ca >= cb)
		%A has more rows and cols than B
		A(1:rb,1:cb) = B(:,:);
	else
		%A has more rows but less cols than B
		A(1:rb,1:end) = B(:,1:ca);
	end
else
	if(ca >= cb)
		%A has less rows and more cols than B
		A(:,1:cb) = B(1:ra,:);
	else
		%A has less rows and cols than B
		A = B(1:ra,1:ca);
	end
end
