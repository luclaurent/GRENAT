%% Initialization of the matlab2tikz's files (MATLAB's path)
%L. LAURENT -- 13/04/2016  -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function initMatlab2tikz(pathCustom)

%directories in the matlab2tikz toolbox
folderToolbox={'src'};

%if no specified directory
if nargin==0
    pathCustom=pwd;
end

if exist(pathCustom,'dir')
    
    %absolute path
    absolutePath=cellfun(@(c)fullfile(pathCustom,'matlab2tikz/',c),folderToolbox,'uni',false);
    
    %add to the PATH
    flA=cellfun(@(x)addpathExisted(x),absolutePath);
    
    %display
    if any(flA==2)
        fprintf(' ## Toolbox: matlab2tikz loaded\n');
    end
end
end

%check if a directory exists in the path or not and add it to the path if not
function flag=addpathExisted(folder)
flag=1;
folder=fullfile(folder);
if ispc
    % Windows is not case-sensitive
    onPath = ~isempty(strfind(lower(path),lower(folder)));
else
    onPath = ~isempty(strfind(path,folder));
end
if exist(folder,'dir')&&~onPath
    flag=2;
    addpath(folder)
end
end
