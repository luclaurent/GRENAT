function LIST = listfiles(DIR, varargin)
%retrieves files in specified directory
%LISTFILES retrieves file- or foldernames in specified directory. Use
%wildcards and/or multiple inputs for directory or filefilter. Use empty
%filefilter to return only folder names (automatically return full path)
%(based on fuf by Francesco di Pierro)
%
%Syntax
%    listfiles(directory [,filefilter [,recursive [,options]]])
%
%    Valid options are:
%     * 'normal' displays only filename
%     * 'full' displays full path of file
%
%Example
%    f = listfiles('C:\MyData')
%    f =
%        'myprogram.m'
%        'output.txt'
%        'result.png'
%
%    g = listfiles('C:\MyData', '*.m')
%    g =
%        'myprogram.m'
%
%    h = listfiles('C:\MyData', {'*.txt', '*.png'}, 'full')
%    h =
%        'C:\MyData\output.txt'
%        'C:\MyData\result.png'
%
%    k = listfiles('C:\MyData', '')
%    k =
%        'C:\MyData'
%        'C:\MyData\anotherfolder'
%
%See also
%    exist, dir

%#ok<*FNDSB>

p	=	inputParser;
validOptions = {'normal', 'full'};
p.addRequired('DIR',				@(x) any([iscell(x), ischar(x)]) );
p.addOptional('FILE',	'*',		@(x) any([iscell(x), ischar(x)]) );
p.addOptional('REC',	false,		@islogical );
p.addOptional('OPT',	'normal',	@(x) any(strcmp(x, validOptions)) );
p.parse(DIR, varargin{:});

%	Optional arguments
if ischar(p.Results.FILE)
	if ~isempty(p.Results.FILE)
		%	make cell array for single file
		FILE	=	{p.Results.FILE};
	else
		FILE	=	p.Results.FILE;
	end
else
	if size(p.Results.FILE, 2) > size(p.Results.FILE, 1)
		FILE	=	p.Results.FILE';
	end
end
if strcmp(p.Results.OPT, 'full')
	OPT	=	true;
else
	OPT	=	false;
end
if ischar(DIR)
	%	make cell array for single directory
	DIR	=	{DIR};
end
%	add slash to directories, if there is no wildcard
for i = 1:length(DIR)
	if ~strcmp(DIR{i}(end), filesep) && ~strcmp(DIR{i}(end), '*')
		DIR{i}	=	[DIR{i}, filesep];
	end
end
REC		=	p.Results.REC;

%	If there is a wildcard in DIR, add all matching directories to DIR
i	=	0;
LIST	=	{};
while true
	i	=	i+1;
	%	find folders with wildcards
	if ~isempty(strfind(DIR{i}, '*'))
		%	find all folders matching wildcard
		tmp		=	dir(DIR{i});
		dirs	=	arrayfun( @(C) C.name, ...
					tmp(arrayfun( @(C) C.isdir, tmp)), ...
						'UniformOutput', false);
		dirs(strcmp(dirs, '.'))		=	[];
		dirs(strcmp(dirs, '..'))	=	[];
		DIR2	=	cellfun( @(C) fullfile(fileparts(DIR{i}), C), dirs, ...
							'UniformOutput', false);
		%	delete wildcard from list and append new directories
		DIR(i)	=	[];
		DIR		=	vertcat(DIR2, DIR); %#ok<AGROW>
	end
	%	break loop (changing list size -> no "for loop")
	if i == length(DIR) || isempty(DIR)
		break
	end
end

%	Find subfolders
if REC
	i	=	0;
	while true
		i	=	i+1;
		tmp		=	dir(DIR{i});
		dirs	=	arrayfun( @(C) C.name, ...
					tmp(arrayfun( @(C) C.isdir, tmp)), ...
						'UniformOutput', false);
		dirs(strcmp(dirs, '.'))		=	[];
		dirs(strcmp(dirs, '..'))	=	[];
		DIR2	=	cellfun( @(C) fullfile(DIR{i}, C), dirs, ...
							'UniformOutput', false);
		DIR		=	vertcat(DIR, DIR2); %#ok<AGROW>
		%	break loop (changing list size -> no "for loop")
		if i == length(DIR) || isempty(DIR)
			break
		end
	end
	if isempty(FILE)
		LIST	=	DIR;
	end
% Find first level subdirs, if only folders are returned
elseif ~REC && isempty(FILE)
	i	=	0;
	while true
		i	=	i+1;
		tmp		=	dir(DIR{i});
		dirs	=	arrayfun( @(C) C.name, ...
					tmp(arrayfun( @(C) C.isdir, tmp)), ...
						'UniformOutput', false);
		dirs(strcmp(dirs, '.'))		=	[];
		dirs(strcmp(dirs, '..'))	=	[];
		LIST2	=	cellfun( @(C) fullfile(DIR{i}, C), dirs, ...
							'UniformOutput', false);
		LIST	=	vertcat(LIST2, LIST); %#ok<AGROW>
		%	break loop (changing list size -> no "for loop")
		if i == length(DIR) || isempty(DIR)
			break
		end
	end
end

%	Delete double entries and check if folders exist
DIR	=	unique(DIR);
if isempty(DIR)
	error('listfiles:NoDirectories', 'No existing directory found.')
else
	if ~all(cellfun( @(C) exist(C, 'dir'), DIR) == 7)
		error('listfiles:directory', 'One or more invalid folder names encountered.')
	end
end

%	Find files in specified directories
if ~isempty(FILE)
	for i = 1:length(DIR)
		list	=	cellfun( @(C) fullfile(DIR{i},C), FILE, 'UniformOutput', false);
		for j = 1:length(list)
			tmp		=	dir(list{j});
			if OPT
				files	=	arrayfun( @(C) fullfile(DIR{i}, C.name), ...
								tmp(arrayfun( @(C) ~C.isdir, tmp)), ...
								'UniformOutput', false);
			else
				files	=	arrayfun( @(C) C.name, ...
								tmp(arrayfun( @(C) ~C.isdir, tmp)), ...
								'UniformOutput', false);
			end
			LIST	=	[LIST; files]; %#ok<AGROW>
		end
	end
end
LIST	=	sort(unique(LIST));

end

% Copyright 2009-2011 Alexandra Heidsieck <aheidsieck@tum.de>,
%                     IMETUM, Technische Universitaet Muenchen
