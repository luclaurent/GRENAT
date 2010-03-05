function createMovie(s)

% createMovie (SUMO)
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
%	createMovie(s)
%
% Description:
%	Create a quicktime movie of all the .jpeg files in the output directory

import ibbt.sumo.util.*

if(s.plotOptions.saveModelPlots == 0)
	s.logger.warning('Plots of models were not saved to file, createMovie will not work');
	return;
end

framesPerSecond = 1;
quality = 100;

% create plot for each output
for i = 1 : length(s.outputNames)
	
	modelDirectory = ['models_' s.outputNames{i}];
	if(isAbsolutePath(s.outputDirectory))
		sourceDir = fullfile(s.outputDirectory, modelDirectory,'');
	else
		sourceDir = fullfile(s.rootDirectory, s.outputDirectory, modelDirectory,'');
	end
	fname = 'movie.mov';
	outputFile = fullfile(sourceDir,fname);

	%%%%%% Create a mov file
	images2movie(sourceDir, outputFile, 'png', framesPerSecond, quality);
	%%%%%%

	%%%%%% Create an avi file, works everywhere but the resulting avi files can be huge under unix
	%fname = 'movie.avi';
	%images2movie(sourceDir, outputFile, 'png', framesPerSecond, quality);
	%%%%%%
end
