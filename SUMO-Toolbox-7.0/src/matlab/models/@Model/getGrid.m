function [samples, values] = getGrid(m)

% getGrid (SUMO)
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
%	[samples, values] = getGrid(m)
%
% Description:
%	Returns a set of samples evaluated on a dense grid to be used for
%	evaluation of the model. Recycles previously evaluated grids.

%{
persistent newGrids;
persistent totalGrids;

if isempty(newGrids)
	newGrids = 0;
	totalGrids = 0;
end

totalGrids = totalGrids + 1;
%}

% model id is 0, model wasn't constructed yet
if getId(m) == 0
	msg = 'You must call construct on a model before requesting an evaluated grid';
	error(msg);
end

% we load the grid manager singleton
gridManager = Singleton('ModelGridManager');

% the samples are always those provided by the grid manager
samples = gridManager.getSamples();

% try to get the grid from the manager
values = gridManager.getGrid(m.modelId);

% id is invalid, so must be outdated, or no grid added yet
if isempty(values)
	%newGrids = newGrids + 1;
	values = evaluateInModelSpace(m, samples);
	gridManager = gridManager.addGrid(values, m.modelId);
end
%disp(sprintf('# grids evaluated so far: %d, # grids requested: %d, %d grid evaluations saved', newGrids, totalGrids, (totalGrids-newGrids)));
