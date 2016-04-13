%% Petite routine de verification du statut parallele (actif ou non)
%% L. LAURENT -- 24/01/2014 -- luc.laurent@lecnam.net

function [statut,num]=statut_parallel
%statut
statut=false;
num=0;
%si la variable globale est disponible on vois ce qu'il y a dedans sinon
%pas de parallelisme
if ~isempty(whos('global','parallel_actif'));
    global parallel_actif;
    statut=parallel_actif;
    if statut
        num=Inf;
    end
end
end