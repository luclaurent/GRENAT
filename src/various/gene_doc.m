%% Generation de la documentation (grace a m2html)
%% L. LAURENT -- 07/02/2014 -- luc.laurent@lecnam.net

%chargement des chemins
doss=init_rep_GRENAT;

%% generation de la documentation


%ajout de la config bash (pour chercher dot de graphviz)
setenv('BASH_ENV','~/.bash_profile');

%dossier analyse
dossier='GRENAT';
%dossiers ignores
%doss_ignore={'};

%liste des fichiers
list_files=list_files_GRENAT(doss);
%ajout chemin
list_files=cellfun(@(x) sprintf('%s/%s',dossier,x),list_files,'UniformOutput',false);

cd ..
%execution generation doc (Graphviz necessaire mais pas indispensable)
m2html('mfiles',list_files,...
    'htmldir',[dossier '/doc'],...
    'recursive','on',...
    'global','on',...
    'globalHypertextLinks','on',...
    'index','menu',...
    'template','frame',...
    'index','menu',...
    'download','off',...
    'graph','on')
cd(dossier)


%%%%%%


%fichier matlab racines
%hh=dir('*.m');
%dossiers/fichiers
%list_files={'routines/','tirages',hh.name};