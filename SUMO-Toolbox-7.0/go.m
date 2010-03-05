function go(varargin)

% go (SUMO)
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
% Revision: $Rev: 6403 $
%
% Signature:
%	go(varargin)
%
% Description:
%	Main entry point for the SUMO Toolbox.
%
%	Example:
%	Usage:
%	    "go"
%	    "go('MyConfigFile.xml')"
%	    "go('MyConfigFile.xml', runFilter)"
%	    "go('MyConfigFile.xml',xValues, yValues)"
%	    "go('MyConfigFile.xml',xValues, yValues, options)"
%	    "go('MyConfigFile.xml',xValues, yValues, options, runFilter)"
%
%	With options a cell array containing one or more of:
%	    "-merge" : merge MyConfigFile.xml with the default configuration
%
%	The runFilter parameter is a number or vector (with range [1 numRuns]) that specifies which runs to execute
%
%	NB: the default configuraiton file is /path/to/SUMO/config/default.xml

%dbstop if error
%dbstop if caught error % dont use

% No point in running the toolbox if there is no JVM
if ~usejava('jvm')
	error('The SUMO Toolbox requires Java to run, normally this is enabled by default.  Check the FAQ for more information');
end

% Check if the toolbox path has been set
res = exist('ibbt.sumo.config.ConfigUtil','class');
if(res == 0)
    disp('It seems the SUMO-Toolbox path has not yet been setup, running startup now..')
    startup
end

% get location of this file
p = mfilename('fullpath');
% get the toolbox root directory
SUMORoot = p(1:end-2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Is the toolbox activated?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
actFile = fullfile(SUMORoot,'bin','java','ibbt','sumo','config','ContextConfig.class');
activated = fopen(actFile,'r');

if(activated < 0)
	s = sprintf('---------------------------------------------------------\n');
	s = sprintf('%s Your SUMO Toolbox installation has not been activated yet\n',s);
	s = sprintf('%s Please contact sumo@intec.ugent.be for further information\n',s);
	s = sprintf('%s---------------------------------------------------------\n',s);

	error(s);
else
  fclose(activated);
end

switch nargin
	case 0
		configFile = fullfile(SUMORoot,'config','default.xml');
		samples = [];
		values = [];
		options = {};
		runFilter = [];
	case 1
		configFile = varargin{1};
		samples = [];
		values = [];
		options = {};
		runFilter = [];
	case 2
		configFile = varargin{1};
		samples = [];
		values = [];
		options = {};
		runFilter = varargin{2};
	case 3
		configFile = varargin{1};
		samples = varargin{2};
		values = varargin{3};
		options = {};
		runFilter = [];
	case 4
		configFile = varargin{1};
		samples = varargin{2};
		values = varargin{3};
		options = varargin{4};
		runFilter = [];
	case 5
		configFile = varargin{1};
		samples = varargin{2};
		values = varargin{3};
		options = varargin{4};
		runFilter = varargin{5};
	otherwise
		error('Invalid arguments given, type "help go" for usage instructions');
	end

SUMODriver(configFile,samples,values,options,runFilter);
