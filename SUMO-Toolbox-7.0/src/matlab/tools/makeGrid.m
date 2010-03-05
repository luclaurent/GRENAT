function g = makeGrid( sizes )

% makeGrid (SUMO)
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
%	g = makeGrid( sizes )
%
% Description:
%	Construct a matrix of size ``prod(sizes) by length(sizes)''
%	where the rows represent all gridpoints on a ``sizes''
%	sized grid.
%
%	Example:
%	>> makeGrid( [3 1 2 2] )
%	ans =
%	   1	1	1	1
%	   1	1	1	2
%	   1	1	2	1
%	   1	1	2	2
%	   2	1	1	1
%	   2	1	1	2
%	   2	1	2	1
%	   2	1	2	2
%	   3	1	1	1
%	   3	1	1	2
%	   3	1	2	1
%	   3	1	2	2

if length(sizes) == 1
	g = (1:sizes(1))';
else
	tmp = repmat((1:sizes(1)), prod( sizes(2:end)),1 );
	g = [tmp(:) repmat(makeGrid(sizes(2:end)), sizes(1), 1)];
end
