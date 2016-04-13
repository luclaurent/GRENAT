%%initialization of the directories (MATLAB's path)
%%L. LAURENT -- 30/01/2014  -- luc.laurent@ens-cachan.fr

function doss=init_dir_GRENAT(pathcustom,other)


% variable 'other' (optional) of type cell must constain the list of other
% toolboxes to load (they must be in '../.')

% variable 'pathcustom' (optional) contains the specific folder from where
% the directories must be loaded

%folders of the GRENAToolbox
doss={'test_fun',...
    'src',...
    'src/disp',...
    'src/various',...
    'src/fct',...
    'src/fct/monomial_basis',...
    'src/init',...
    'src/surrogate',...
    'src/crit',...
    'src/libs',...
    'src/libs/PSOt'};

%depending on the paramters
specif_dir=true;
if nargin==0
    specif_dir=false;
elseif nargin>1
    if isempty(pathcustom)
        specif_dir=false;
    end
end
%if no specified directory
if ~specif_dir
    pathcustom=pwd;
end

%absolute paths
path_absolute=cellfun(@(c)[pathcustom '/' c],doss,'uni',false);

%add to the PATH
cellfun(@addpath,path_absolute);

%if PSOt is available the PSOt files will be loaded
if exist('init_PSOt','file')
    init_PSOt([pathcustom '/routines/libs/PSOt']);
end

if nargin==2
    %Load other toolbox
    if ~iscell(other);other={other};end
    %absolute paths
    path_absolute=cellfun(@(c)[pathcustom '/../' c],other,'uni',false);
    %add to the PATH
    cellfun(@addpath,path_absolute);    
    %add other toolbox to the PATH
    name_fct=cellfun(@(c)['init_dir_' c],other,'uni',false);
    cellfun(@feval,name_fct,path_absolute,'uni',false)
end
end
