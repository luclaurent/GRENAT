%% Initialization of the directories (MATLAB's path)
% L. LAURENT -- 30/01/2014  -- luc.laurent@lecnam.net

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

function foldersLoad=initDirGRENAT(pathcustom,other,flagNested)


% variable 'other' (optional) of type cell must constain the list of other
% toolboxes to load (they must be in '../.')

% variable 'pathcustom' (optional) contains the specific folder from where
% the directories must be loaded

% variable 'flasgNested' (optional) is type boolean must be used in the
% case of the use of this toolbox on a nested position (called by another
% toolbox). In this case, the  MultiDOE toolbox will be not
% loaded. The default value is false.
if nargin<3;flagNested=false;end

%folders of the GRENAToolbox
foldersLoad={'funTest',...
    'src',...
    'src/disp',...
    'src/various',... 
    'src/kernANDfun',... 
    'src/kernANDfun/monomial_basis',...
    'src/init',...
    'src/surrogate',...
    'src/crit',...
    'src/libs',...
    'src/libs/Monomial',...
    'src/libs/PSOt',...
    'src/libs/multidoe',...
    'src/libs/MultiDOE',...
    'src/libs/matlab2tikz'};


%depending on the parameters
specifDir=true;
if nargin==0
    specifDir=false;
elseif nargin>1
    if isempty(pathcustom)
        specifDir=false;
    end
end
%if no specified directory
if ~specifDir
    pathcustom=strrep(mfilename('fullpath'),mfilename,'');
end

%absolute paths
pathAbsolute=cellfun(@(c)fullfile(pathcustom,c),foldersLoad,'uni',false);

%scan all directory to find "@" folder (used for classes)
folderAt={};
for iP=1:numel(pathAbsolute)
    folderAtTmp=scanATfolder(pathAbsolute{iP});
    folderAt=[folderAt;folderAtTmp'];
end

%add to the PATH
flA=cellfun(@(x)addpathExisted(x),pathAbsolute);

%if PSOt is available the PSOt files will be loaded
if exist('initPSOt','file')
    initPSOt(fullfile(pathcustom,'/src/libs'));
end

%if matlab2tikz is available the matlab2tikz files will be loaded
if exist('initMatlab2tikz','file')&&~flagNested
    initMatlab2tikz(fullfile(pathcustom,'/src/libs'));
end

%if MultiDOE is available the MultiDOE files will be loaded
if exist('initDirMultiDOE','file')&&~flagNested
    initDirMultiDOE(fullfile(pathcustom,'/src/libs/multidoe'),[]);
end

flB=[];
if nargin>=2
    if ~isempty(other)
        %Load other toolbox
        if ~iscell(other);other={other};end
        %absolute paths
        pathAbsolute=cellfun(@(c)fullfile(pathcustom,'/../',c),other,'uni',false);
        %add to the PATH
        cellfun(@(x)addpathExisted(x),pathAbsolute);
        %add other toolbox to the PATH
        namFun=cellfun(@(c)['initDir' c],other,'uni',false);
        flB=cellfun(@feval,namFun,pathAbsolute,'uni',false);
    end
end
if any([flA flB]==2)
    %display
    Gfprintf(' ## Toolbox: GRENAT loaded\n');
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
%check of the folder contains @ (if yes it will not be added to the path)
inAt=contains(folder,'@');
if exist(folder,'dir')&&~onPath&&~inAt
    flag=2;
    addpath(folder)
end
end

%scan folder for finding "@" (classes) folder
function listDir=scanATfolder(folder)
%scan the folder
resScan=dir(folder);
%
listDir={};
for ii=1:numel(resScan)
    if resScan(ii).isdir
        if resScan(ii).name(1)=='@'
            listDir{end+1}=[folder filesep resScan(ii).name];
        end
    end
end
end

