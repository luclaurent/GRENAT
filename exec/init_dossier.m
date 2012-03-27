%% Creation du dossier de travail (pour sauvegarde figures)
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function [dossier,date]=init_dossier(meta,doe,ajout,chemin)

day=clock;
if length(doe.nb_samples)==2
    dossier=[num2str(day(1),'%4.0f') '-' num2str(day(2),'%02.0f') '-' num2str(day(3),'%02.0f')...
        '_' num2str(day(4),'%02.0f') '-' num2str(day(5),'%02.0f') '-' num2str(day(6),'%02.0f') '_'...
        doe.type '_ns' num2str(prod(doe.nb_samples)) '_reg' num2str(meta.deg) '_' meta.corr]; 
else
    dossier=[num2str(day(1),'%4.0f') '-' num2str(day(2),'%02.0f') '-' num2str(day(3),'%02.0f')...
        '_' num2str(day(4),'%02.0f') '-' num2str(day(5),'%02.0f') '-' num2str(day(6),'%02.0f') '_'...
        doe.type '_ns' num2str(doe.nb_samples) '_reg' num2str(meta.deg) '_' meta.corr];
    
end

%ajout de texte dans le nom de fichier
if nargin>=3
    dossier=[dossier ajout];
end

%modifications du chemin de stockage
if nargin==4
    dossier=[chemin dossier];
else
    dossier=['results/' dossier];
end

if meta.save
%creation du repertoire
unix(['mkdir ' dossier]);
else
global aff
aff.save=false; 	% pas de sauvegarde des traces si pas de sauvegarde
end

%date
date.year=day(1);
date.month=day(2);
date.day=day(3);
date.hour=day(4);
date.minute=day(5);
date.second=day(6);
