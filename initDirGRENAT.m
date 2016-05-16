%% Initialization of the directories (MATLAB's path)
%% L. LAURENT -- 30/01/2014  -- luc.laurent@lecnam.net

function foldersLoad=initDirGRENAT(pathcustom,other)


% variable 'other' (optional) of type cell must constain the list of other
% toolboxes to load (they must be in '../.')

% variable 'pathcustom' (optional) contains the specific folder from where
% the directories must be loaded

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
    'src/libs/PSOt',...
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
    pathcustom=pwd;
end

%absolute paths
pathAbsolute=cellfun(@(c)[pathcustom '/' c],foldersLoad,'uni',false);

%add to the PATH
cellfun(@addpath,pathAbsolute);

%if PSOt is available the PSOt files will be loaded
if exist('initPSOt','file')
    initPSOt([pathcustom '/src/libs/']);
end

%if matlab2tikz is available the matlab2tikz files will be loaded
if exist('initMatlab2tikz','file')
    initMatlab2tikz([pathcustom '/src/libs/']);
end

%if MultiDOE is available the MultiDOE files will be loaded
if exist('initDirMultiDOE','file')
    initDirMultiDOE([pathcustom '/src/libs/MultiDOE']);
end

if nargin==2
    %Load other toolbox
    if ~iscell(other);other={other};end
    %absolute paths
    pathAbsolute=cellfun(@(c)[pathcustom '/../' c],other,'uni',false);
    %add to the PATH
    cellfun(@addpath,pathAbsolute);    
    %add other toolbox to the PATH
    namFun=cellfun(@(c)['initDir' c],other,'uni',false);
    cellfun(@feval,namFun,pathAbsolute,'uni',false)
end
end
