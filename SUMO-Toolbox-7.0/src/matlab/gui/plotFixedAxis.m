function plotFixedAxis(directory, outputformat, axisSettings)

% plotFixedAxis (SUMO)
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
%	plotFixedAxis(directory, outputformat, axisSettings)
%
% Description:
%	Replot a directory of .fig images in the specified output format, with
%	axis limits as specified.
%	@param directory	path to the folder containing the .fig files
%	@param outputFormat	extension for the output images
%	@param axisSettings	fixed axis settings for each image (@see AXIS)
%	Example:
%	plotFixedAxis('slices', 'png', [-1 1 -1 1 -1 1 -1 1])

	assert(nargin == 3, 'Error: invalid argument count.');
	
	import java.util.logging.*;
	logger = Logger.getLogger('Matlab.plotFixedAxis');

	files = dir(fullfile(directory, '*.fig'));
	numfiles = length(files);
	logger.info(sprintf('Fixing axis in %i figures. Saving as %s.', numfiles, outputformat));
	for f=1:numfiles
		name = fullfile(directory, files(f).name);
		logger.finer(sprintf('Processing figure %s.',name));
		h = openfig(name, 'new', 'invisible'); % keep figures hidden
		axis(get(h, 'CurrentAxes'), axisSettings);
		saveas(h, regexprep(name, 'fig$', outputformat));
		
		% call delete directly (avoids custom close function of
		% guiPlotModel, which we don't need for figures opened from disc)
		delete(h);
	end
	logger.info('All figures fixed.');
end
