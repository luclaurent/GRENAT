%%initialisation des chemins de fichiers
%%L. LAURENT -- 30/01/2014  -- luc.laurent@ens-cachan.fr

function doss=init_rep_GRENAT(chemin,other)

% variable 'other' de type cellule contenant la liste des autre toolbox a
% charger (elles doivent etre situees dans le dossier ../.)

%dossier de la Toolbox COMET
doss={'fct_test','routines','routines/aff','routines/divers',...
    'routines/fct','routines/fct/base_monomes',...
    'routines/init','routines/meta',...
    'routines/crit','routines/libs','routines/libs/PSOt'};

%en fonction des parametres
specif_chemin=true;
if nargin==0
    specif_chemin=false;
elseif nargin>1
    if isempty(chemin)
        specif_chemin=false;
    end
end
%si pas de chemin specifie
if ~specif_chemin
    chemin=pwd;
end

%chemins absolus
chemin_full=cellfun(@(c)[chemin '/' c],doss,'uni',false);

%ajout au PATH
cellfun(@addpath,chemin_full);

%si PSOt est bien present, on charge ses fichiers
if exist('init_PSOt','file')
    init_PSOt([chemin '/routines/libs/PSOt']);
end

if nargin==2
    %%chargement des autres toolbox
    if ~iscell(other);other={other};end
    %chemins absolus
    chemin_full=cellfun(@(c)[chemin '/../' c],other,'uni',false);
    %ajout au PATH
    cellfun(@addpath,chemin_full);
    
    %ajout des toolbox dans le PATH
    nom_fct=cellfun(@(c)['init_rep_' c],other,'uni',false);
    cellfun(@feval,nom_fct,chemin_full)
end
end
