%% fonction assurant la construction du Krigeage à gradients indirect
%% L. LAURENT -- 18/04/2012 -- laurent@lmt.ens-cachan.fr

function ret=meta_inkrg(tirages,eval,grad,meta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf('>>> Préparation donnees Krigeage à gradient indirect (appel Krigeage)  \n');
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
dup_tir=repmat(reord_tir,nb_var+1,[]);
%creation décalage par direction
mat_pas=diag(pas_tayl);
mat_pas_dup=[zeros(1,nb_var*nb_val_init);repmat(mat_pas,1,nb_val_init)];
badord_tir=dup_tir+mat_pas_dup;
tirages_new=zeros((nb_var+1)*nb_val_init,nb_var);

%nouveaux points
for ii=1:nb_var
   li=ii:nb_var:(nb_var*nb_val_init);
   tirages_new(:,ii)=reshape(badord_tir(:,li),(nb_var+1)*nb_val_init,[]);   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creation des nouvelles réponses (aux points ajoutés)

%Reordonnancement reponses
tmp_ev=[eval zeros(nb_val_init,nb_var-1)];
reord_ev=reshape(tmp_ev',1,[]);
dup_ev=repmat(reord_ev,nb_var+1,[]);
%Reordonnancement gradients
reord_grad=reshape(grad',1,[]);
dup_grad=repmat(reord_grad,nb_var+1,[]);
badord_ev=dup_ev+mat_pas_dup.*dup_grad;
%nouvelles reponses
tmp_ev=zeros((nb_var+1)*nb_val_init,nb_var);
for ii=1:nb_var
   li=ii:nb_var:(nb_var*nb_val_init);
   tmp_ev(:,ii)=reshape(badord_ev(:,li),(nb_var+1)*nb_val_init,[]);   
end
eval_new=sum(tmp_ev,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Construction Krigeage a partir de ces donnees
fprintf('>>> Nombre de points pris en compte: %d  \n',size(tirages,1));
ret=meta_krg_ckrg(tirages_new,eval_new,[],meta);
%% extraction informations
ret.in.tirages_init=tirages;
ret.in.eval_init=eval;

