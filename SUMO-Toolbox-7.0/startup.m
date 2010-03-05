function startup

% startup (SUMO)
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
%	startup
%
% Description:
%	Sets up the toolbox path

% Detect the matlab version
checkVersion();

% Set the path to the SUMO Toolbox root directory (the location of the configure script)

% This line assumes that the toolbox will always be run from its installation directory
% ie., you have to run 'go' from the toolbox root
addpath('.');

% Use this line if you want to be able to run 'go' from any subdirectory inside the toolbox tree
%addpath(fullfile('path','to','your','toolbox','installation',''));

% configure the toolbox (set the paths)
configure;

function checkVersion()
    minVersion = '7.7';
    maxVersion = '7.10';

    if(verLessThan('matlab', minVersion))
	    disp(['WARNING: the SUMO Toolbox needs at least MATLAB version ' minVersion ' or higher, which you don''t appear to have ! Depending on what you need it may, or may not work...']);
	elseif(~verLessThan('matlab', maxVersion))
	    disp(['WARNING: the SUMO Toolbox has not been tested fully with MATLAB version ' maxVersion ' or higher! Depending on what you need it may, or may not work...']);
	else
		% version is ok
	end
