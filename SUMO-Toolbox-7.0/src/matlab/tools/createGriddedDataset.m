function createGriddedDataset( file, handle, gridsize )

% createGriddedDataset (SUMO)
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
%	createGriddedDataset( file, handle, gridsize )
%
% Description:

% Open file
f = fopen( file, 'w' );

inputs = nargin( handle );
in = cfix( {0}, inputs );

% Determine number of outputs
outputs = nargout( handle );
if outputs == 1
	out = feval( handle, in{:} );
	outputs = length(out);
end

disp( sprintf( '##  Number of inputs:  %d', inputs ) )
disp( sprintf( '##  Number of outputs: %d', outputs ) )

% Duplicate gridsize if necessary
gridsize = dfix( gridsize, inputs )

% Make evaluation grid
gridcoords = cell( 1,inputs );
for k=1:inputs
	gridcoords{k} = linspace( -1,1,gridsize(k) );
end
points = makeEvalGrid( gridcoords, gridsize );

% Initialize counters
nPoints = size(points,1);
startTime = now;
lastTime = now;

% Initialize output variable
values = zeros( nPoints, outputs );

outCell = cell(1,outputs);
for k=1:nPoints
	tmp = num2cell(points(k,:));
	[outCell{:}] = feval(handle, tmp{:});
	values(k,:) = cell2mat(outCell);
	if (now-lastTime) * 3600 * 24 > 5
		elapsed = now - startTime;
		remaining = (nPoints - k) / k * elapsed;
		percentage = k / nPoints * 100;
		disp( sprintf( '   - %02.2f percent done, elapsed: %s, remaining: %s', ... 
			percentage, timeString(elapsed), timeString(remaining) ) );
		lastTime = now;
	end
end

% Convert to one row (in the right order)...
values = values.';
values = values(:).';

% Write values to file
disp( sprintf( ' ## Saving to file : %s', file ) );
stride = 1000;
nValues = length(values);
for start=1:stride:nValues
	stop = min(nValues,start+stride-1);
	fprintf( f, '%.6f ', values(start:stop) );
	percent = start / nValues * 100;
	disp( sprintf( '  - %02.2f percent done', percent ) );
end
fclose(f);

function s = timeString( seconds )

seconds = fix(seconds*24*3600);
sec = mod(seconds,60);
min = div(mod(seconds,3600),60);
hour = div(seconds,3600);

if hour
	s = sprintf( '%02dh-%02dm-%02ds', hour, min, sec );
else
	if min
		s = sprintf( '%02dm-%02ds', min, sec );
	else
		s = sprintf( '%02ds', sec );
	end
end

function y = div( a,b )

y = fix(a/b);
