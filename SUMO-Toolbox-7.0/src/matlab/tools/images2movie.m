function images2movie(directory, outputfile, format, framesPerSecond, quality)

% images2movie (SUMO)
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
%	images2movie(directory, outputfile, format, framesPerSecond, quality)
%
% Description:
%	Create a movie from a set of images

import java.util.logging.*;

if (nargin < 3)
	% no format specified
	format = 'png';
end
if (nargin < 4)
	% no framesPerSecond specified
	framesPerSecond = 1;
end
if (nargin < 5)
	% no quality specified
	quality = 100;
end

logger = Logger.getLogger('Matlab.images2movie');

if(isdir(directory))
    files = dir([directory '/*.' format]);
else
    % treat as a wildcard in the current dir
    files = dir(directory);
    directory = '.';
end


if(length(files) < 1)
	logger.warning('No source files found, returning....')
	return
end

% create a quicktime file using java
if(strcmp(outputfile(end-2:end),'mov'))
   
    %is the java media framework installed
    if(~exist('javax.media.Format','class'))
	   msg = 'jmf.jar not found in the java classpath, movie creation skipped! Did you install the SUMO extension pack? Alternatively you can install the java media framwork from java.sun.com and make sure it is in your path';
       logger.warning(msg);
	   return;
    end
    
	%figure out width and height from the first file
	f = fullfile(directory,files(1).name);
	im = imread(f);
	width = size(im,2);
	height = size(im,1);
    
    % convert to a cell of filenames
    fnames = {};
    for i=1:length(files)
        fnames = [fnames fullfile(directory,files(i).name)];
    end
	ibbt.sumo.util.JpegImagesToMovie.createMovie(width,height,framesPerSecond,outputfile,fnames);

% create an avi file using matlab (no compression on linux)
elseif(strcmp(outputfile(end-2:end),'avi'))
	numframes = length(files);
	
	logger.info(sprintf('%d images read from %s',numframes,directory));
	
	aviobj = avifile(outputfile, 'fps',framesPerSecond, 'quality',quality);
	
	for f=1:numframes
		name = [directory '/' files(f).name];
		logger.finer(sprintf('Processing image %s',name));
		image = imread(name,format);
		frame = im2frame(image);
		aviobj = addframe(aviobj,frame);
	end
	
	aviobj = close(aviobj);
else
	error('Invalid output file, must end in mov or avi');
end

logger.info(sprintf('Movie %s created...', outputfile));
