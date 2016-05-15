%%initialization of the directories (MATLAB's path)
%%L. LAURENT -- 30/01/2014  -- luc.laurent@lecnam.net

function foldersLoad=initDirGRENAT(pathcustom,other)


% variable 'other' (optional) of type cell must constain the list of other
% toolboxes to load (they must be in '../.')

% variable 'pathcustom' (optional) contains the specific folder from where
% the directories must be loaded

%folders of the GRENAToolbox
foldersLoad={'test_fun',...
    'src',...
    'src/disp',...
    'src/various',...
    'src/kern_and_fun',...
    'src/kern_and_fun/monomial_basis',...
    'src/init',...
    'src/surrogate',...
    'src/crit',...
    'src/libs',...
    'src/libs/PSOt',...
    'src/libs/matlab2tikz'};

%depending on the paramters
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
if exist('init_PSOt','file')
    initPSOt([pathcustom '/src/libs/PSOt']);
end

if nargin==2
    %Load other toolbox
    if ~iscell(other);other={other};end
    %absolute paths
    pathAbsolute=cellfun(@(c)[pathcustom '/../' c],other,'uni',false);
    %add to the PATH
    cellfun(@addpath,pathAbsolute);    
    %add other toolbox to the PATH
    name_fct=cellfun(@(c)['init_dir_' c],other,'uni',false);
    cellfun(@feval,name_fct,pathAbsolute,'uni',false)
end
end
