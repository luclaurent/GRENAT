%% Build documentation (using m2html library)
% L. LAURENT -- 07/02/2014 -- luc.laurent@lecnam.net

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

%load paths
dirPath=initDirGRENAT;

%% Build documentation

%add configurtation to bash (for finding 'dot' script of graphviz)
setenv('BASH_ENV','~/.bash_profile');

%change nam folder to the original one (the webpages will not work
%properly)
flagChange=false;
%orignal name of the toolbox
origName='GRENAT';
%fullpath of this script
fp=mfilename('fullpath');
fps=strsplit(fp,filesep);
%directory to be analysed
analyseDir=fps(end-3);
analyseDir=analyseDir{1};
%ignoring directory
ignDir={'optigtest','multidoe','PSOt','matlab2tikz'};

%listof files
listFiles=listFilesToolboxGRENAT(dirPath);
%remove ignored directory
for itI=1:numel(ignDir)
   for itL=numel(listFiles):-1:1
       iXFind=strfind(lower(listFiles{itL}),lower(ignDir{itI}));
       if ~isempty(iXFind)
           listFiles(itL)=[];
       end
   end
end
%add path to all files
listFiles=cellfun(@(x) sprintf('%s%s%s',analyseDir,filesep,x),listFiles,'UniformOutput',false);

cd ..
%execute generation of the doc (Graphviz is optional)
try
    %addpath of m2html
    addpath(fullfile(analyseDir,'src','libs','m2html'));
    %run m2html
    m2html('mfiles',listFiles,...
        'htmldir',fullfile(analyseDir,'doc'),...
        'recursive','on',...
        'global','on',...
        'globalHypertextLinks','on',...
        'index','menu',...
        'template','frame',...
        'index','menu',...
        'download','off',...
        'graph','on')
    if flagChange
        %restore original name
        pathTodoc=fullfile(analyseDir,'doc',analyseDir);
        newName=fullfile(analyseDir,'doc',origName);
        if exist(pathTodoc,'dir')&&~strcmp(analyseDir,origName)
            if exist(newName,'dir')
                rmdir(newName,'s');
            end
            movefile([pathTodoc filesep],newName);
        end
    end
catch ME
    fprintf('ERROR during the building of the documentation\n');
    disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
end
cd(analyseDir)
%%%%%%
