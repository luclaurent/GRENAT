%% Build documentation (using m2html library)
% L. LAURENT -- 07/02/2014 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

%load paths
dirPath=initDirGRENAT;

%% Build documentation

%add configurtation to bash (for finding 'dot' script of graphviz)
setenv('BASH_ENV','~/.bash_profile');

%directory to be analysed
analyseDir='GRENAT';
%ignoring directory
%ignDir={'};

%listof files
listFiles=listFilesToolbox(dirPath);
%add path to all files
listFiles=cellfun(@(x) sprintf('%s/%s',analyseDir,x),listFiles,'UniformOutput',false);

cd ..
%execute generation of the doc (Graphviz is optional)
m2html('mfiles',listFiles,...
    'htmldir',[analyseDir '/doc'],...
    'recursive','on',...
    'global','on',...
    'globalHypertextLinks','on',...
    'index','menu',...
    'template','frame',...
    'index','menu',...
    'download','off',...
    'graph','on')
cd(analyseDir)
%%%%%%
