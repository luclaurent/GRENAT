%%initialisation des chemins de fichiers PSOt
%%L. LAURENT -- 31/01/2014  -- luc.laurent@ens-cachan.fr

function init_PSOt(chemin)

%dossier de la Toolbox COMET
doss={'hiddenutils','nnet','testfunctions'};

%si pas de chemin specifie
if nargin==0
    chemin=pwd;
end

%chemins absolus
chemin_full=cellfun(@(c)[chemin '/' c],doss,'uni',false);

%ajout au PATH
cellfun(@addpath,chemin_full);

end
