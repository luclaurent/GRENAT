function [] = invertedGridToNewGrid(fileName, gridSize, outDim)

% invertedGridToNewGrid (SUMO)
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
%	[] = invertedGridToNewGrid(fileName, gridSize, outDim)
%
% Description:
%	Load inverted (old format) grid and convert to new format.

% load values, transpose to go from row major to column major mode
values = load(fileName)';

% place in flat array
values = values(:);

% reshape to rows, again take into account column major mode of matlab
values = reshape(values, outDim, prod(gridSize))';

% generate invertex grid
grid = makeGridInverted(gridSize);

% assemble data and resort them
data = [grid values];
data = sortrows(data);

% save to disk only the values in the right order
values = data(:,(end-outDim+1) : end);
save(fileName, 'values', '-ascii');

end
