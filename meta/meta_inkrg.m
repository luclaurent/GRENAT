%% fonction assurant la construction du Krigeage à gradients indirect
%% L. LAURENT -- 18/04/2012 -- laurent@lmt.ens-cachan.fr

function ret=meta_inkrg(tirages,eval,grad,meta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf(' >> Préparation donnees Krigeage à gradient indirect (appel Krigeage)  \n');
fprintf('>> Valeur pas developpement de Taylor:')
fprintf(' %d',meta.para.pas_tayl);
fprintf('\n\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creation des nouveaux points (1 nouveau points par direction)
%dimension du problème (nombre de variables)
nb_var=size(tirages,2);
%nombre de points initiaux
nb_val_init=size(tirages,1);
%traitement pas Taylor
if numel(meta.para.pas_tayl)~=nb_var
    pas_tayl=meta.para.pas_tayl(1)*ones(1,nb_var);
else
    pas_tayl=meta.para.pas_tayl;    
end

%Reordonnancement tirages et duplication
reord_tir=reshape(tirages',1,[]);
dup_tir=repmat(reord_tir,nb_var,[]);
%creation décalage par direction
mat_pas=diag(pas_tayl);
mat_pas_dup=repmat(mat_pas,[],nb_val);
badord_tir=dup_tir+mat_pas;
%nouveaux points
tirages_new=reshape(badord_tir,nb_val,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creation des nouvelles réponses (aux points ajoutés)




