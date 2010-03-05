function theta_space( start, step, ubound, output )

% theta_space (SUMO)
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
%	theta_space( start, step, ubound, output )
%
% Description:
%	Sets up the toolbox path

[filename, pathname, filterindex] = uigetfile( {'*', 'All Files'}, 'Select a dataset');

datafile = [pathname filename];
data = load( datafile );
mkdir( output );

h=figure;
for i=start:step:size(data,1)
	j = min( size(data,1), i+step-1);
	
	figure(h);
	hold off;
	if (j-1) >= 0
		plot( [data(start:j-1, 1)	;ubound;0], [data(start:j-1, 2);ubound;0], 'x' );	
	end
	hold on;
	plot( [data(i:j, 1)	;ubound;0], [data(i:j, 2);ubound;0], 'ro' );
	
	saveas(h, sprintf('%s/theta_plot_%07i.png', output, i) );
	disp( sprintf( 'Swarm %i/%i', i, size( data,1) ) );
end
