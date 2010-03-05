function scat = gridToScattered( grid, gridsize, numOutputs, makeOutputsComplex )

% gridToScattered (SUMO)
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
%	scat = gridToScattered( grid, gridsize, numOutputs, makeOutputsComplex )
%
% Description:
%	Transform a gridded dataset into a scattered one

dimension = length(gridsize);
outputs = reshape(grid,length(grid)/numOutputs, numOutputs);

if(makeOutputsComplex)
	outputs = outputs(:,1:2:end) + j*outputs(:,2:2:end);
end

inputs = cell(1,dimension);
for i=1:dimension
	inputs{i} = linspace(-1,1,gridsize(i));
end
points = makeEvalGrid(inputs,gridsize);

% TODO: Apparently not needed
%Have to take into account wouters weird convention of storing the input columns backwards
%points = fliplr(points);

scat = [points outputs];
