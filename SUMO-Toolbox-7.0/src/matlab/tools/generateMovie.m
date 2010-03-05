function generateMovie(model, outputFile, numSlices, framesPerSecond, varyAxis, outputIndex, options)

% generateMovie (SUMO)
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
%	generateMovie(model, outputFile, numSlices, framesPerSecond, varyAxis, outputIndex, options)
%
% Description:
%	Create a movie of slices from a model with 3 inputs and n
%	outputs, on the input interval [-1,1]. Only one of the outputs is
%	plotted, specified by outputIndex. A subfolder named slices will
%	be created in the directory where the movie must be saved. In
%	that subdirectory the generated slices will be stored as png
%	files. The value of the varying axis will be appended to the title of
%	each slice.
%	NOTE: existing png files in the slices subdirectory will be deleted!
%	@param model	the model to generate slices from (3
%	               dimensional input, n dimensional output)
%	@param outputFile	file location to save the movie to
%	@param numSlices	number of slices to generate over the interval
%	@param framesPerSecond	number of frames per second in the movie
%	@param varyAxis		the axis index of the model to variate over
%	                   the different slices
%	@param outputIndex	index of the output dimension to plot
%	                   (ignored if output is 1D, defaults to 1)
%	@param options	plot options (to pass to plotScatteredData)

	% TODO use same interval for output in each frame
	% Probably not possible because you don't know how big the output is going to be,
	% but maybe prevent magnifying in next image?
	% or first output in .fig and remember the extremes, then output in .png?
	
	if (nargin < 2)
		% no output file passed
		outputFile = 'movie.mov';
	end
	if (nargin < 3)
		% no numSlices passed
		numSlices = 50;
	end
	if (nargin < 4)
		% no framesPerSecond passed
		framesPerSecond = 1;
	end
	if (nargin < 5)
		% no varyAxis passed
		varyAxis = 3;
	end
	if (nargin < 6)
		% no outputIndex passed
		outputIndex = 1;
	end
	if (nargin < 7)
		% no options passed --> define default options
		% (otherwise we get a 'parameter undefined' error)
		options = struct;
		options.plotPoints = 0;
		options.lighting = 0;
		options.lowerBounds = [-1,-1];
		options.upperBounds = [1,1];
		options.title = '';
		switch varyAxis;
			case {1}
				options.axisLabels = {'input(2)', 'input(3)', sprintf('output(%i)', outputIndex)};
			case {2}
				options.axisLabels = {'input(1)', 'input(3)', sprintf('output(%i)', outputIndex)};
			otherwise
				options.axisLabels = {'input(1)', 'input(2)', sprintf('output(%i)', outputIndex)};
		end
		options.grayScale = 0;
		options.meshSize = 50;
		options.colorbar = 0;
		options.contour = 0;
	end
	
	% check the dimensions of the model
	dim = getDimensions(model);
	if (dim ~= 3)
		error('Model must have exactly 3 input parameters, but has %i. Unable to create movie.', dim);
	end
	
	% get the directory where the output file should be stored
	movieDir = fileparts(outputFile);
	% the directory where slices will be saved
	picsDir = fullfile(movieDir, 'slices');
	% remove existing .png's from the slices directory, to avoid inclusion in
	% movie
	delete(fullfile(picsDir, '*.png'));
	% create the slices directory (if it doesn't exist)
	mkdir(picsDir);
	
	% the steps to generate slices for
	steps = linspace(-1,1,numSlices);
	% random evaluation points in [-1,1]
	s = rand(5000,2)*2-1;
	
	% save the current graph title, add a newline if non-empty (to print
	% the current value of the varyAxis on a new line)
	if (strcmp(options.title,''))
		title = '';
	else
		title = sprintf('%s\n', options.title);
	end
	
	% open a plot window
	figure
	
	for i=1:length(steps)
		axis = ones(size(s,1),1)*steps(i);
		switch varyAxis;
			case {1}
				data = [axis s(:,1) s(:,2)];
			case {2}
				data = [s(:,1) axis s(:,2)];
			otherwise
				data = [s(:,1) s(:,2) axis];
		end
				
		res = evaluateInModelSpace(model,data);
		if (length(res(1)) > 1)
			% the result is multidimensional -> select correct dimension
			% TODO check whether this works
			res = res(outputIndex);
		end
		
		% add the current value of the varying axis to the title (on a new
		% line, see definition of title above)
		options.title = sprintf('%sinput(%i) = %d', title, varyAxis, steps(i));
		
        % use the randomly generated columns to plot the current slice
		plotScatteredData(s(:,1), s(:,2), res, options);
		
		% how many zero's before the file name? (to ensure correct order)
		numZeros = floor(log10(numSlices))-floor(log10(i));
		padding = char(ones(1,numZeros)*double('0'));
		
		saveas(gcf,fullfile(picsDir, [padding num2str(i) '.png']));
	end
	% close the plot window (happens only when function returns?)
	close(gcf);
	
	images2movie(picsDir, outputFile, 'png', framesPerSecond);
end
