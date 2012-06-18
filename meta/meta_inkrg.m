%% fonction assurant la construction du Krigeage à gradients indirect
%% L. LAURENT -- 18/04/2012 -- laurent@lmt.ens-cachan.fr

function ret=meta_inkrg(tirages,eval,grad,meta,manq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf('>>> Préparation donnees Krigeage à gradient indirect (appel Krigeage)  \n');

%dimension du problème (nombre de variables)
nb_var=size(tirages,2);
%nombre de points initiaux
nb_val_init=size(tirages,1);

%en fonction du type de donnees en entree
if ~isstruct(grad)
    fprintf('>> Valeur pas developpement de Taylor (manu):')
    fprintf(' %d',meta.para.pas_tayl);
    fprintf('\n')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Creation des nouveaux points (1 nouveau points par direction)
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
    %%% Nettoyage si données manquantes (attention en cas de réponse
    %%% manquante, on retire également le gradient car impossible d'estimer
    %%% la valeur de la réponse aux points proches sans la valeur de cette
    %%% réponse)
    pos_ev=[];
    if manq.eval.on
        pos_tmp=manq.eval.ix_manq;
        fprintf(' >>> Supression informations (réponse(s) manquante(s)) à(aux) point(s):');
        fprintf(' %i',pos_ev);
        fprintf('\n');
        %renumerotation pour extraction bonnes valeurs
        pos_tmp=(pos_tmp-1)*(nb_var+1)+1;
        for ii=1:numel(pos_tmp)
            pos_ev=[pos_ev pos_tmp(ii):pos_tmp(ii)+nb_var+1];
        end
    end

    pos_gr=[];
    if manq.grad.on
        pos_tmp=manq.grad.ix_manq;
        pos_gr=(pos_tmp(:,1)-1)*(nb_var+1)+1+pos_tmp(:,2);
    end
  
    %position des elements manquants
    pos_manq=unique([pos_ev,pos_gr]);
    
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
    tmp=mat_pas_dup.*dup_grad;
    %si données manquantes, traitement spécifiques pour eviter les NaN    
    if manq.grad.on||manq.eval.on
             IX=find(isnan(tmp(:)));
             tmp(IX)=0;
    end
        badord_ev=dup_ev+tmp;
    %nouvelles reponses
    tmp_ev=zeros((nb_var+1)*nb_val_init,nb_var);
    for ii=1:nb_var
        li=ii:nb_var:(nb_var*nb_val_init);
        tmp_ev(:,ii)=reshape(badord_ev(:,li),(nb_var+1)*nb_val_init,[]);
    end
    eval_new=sum(tmp_ev,2);
    
    %supression des donneés manquantes
    if ~isempty(pos_manq)
        tirages_new(pos_manq,:)=[];
        eval_new(pos_manq)=[];
    end

else
    %%Attention données manquante non prises en compte dans cette approche
    %%(a coder)
    %calcul des pas de Taylor dans chaque direction
    pas_tayl_d=grad.tirages{1}-repmat(tirages(1,:),nb_var,1);
    pas_tayl=abs(sum(pas_tayl_d,2));
    
    %Nouveaux tirages et réponses
    tirages_new=zeros((nb_var+1)*nb_val_init,nb_var);
    eval_new=zeros((nb_var+1)*nb_val_init,1);
    for ii=1:nb_val_init
        li_tir=(ii-1)*(nb_var+1)+1;
        li_tirg=li_tir+1:ii*(nb_var+1);
        tirages_new(li_tir,:)=tirages(ii,:);
        tirages_new(li_tirg,:)=grad.tirages{ii};
        eval_new(li_tir)=eval(ii);
        eval_new(li_tirg)=grad.eval{ii};
    end
    
    fprintf('>> Valeur pas developpement de Taylor (auto):')
    fprintf(' %d',pas_tayl);
    fprintf('\n')
    
end
 fprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Construction Krigeage a partir de ces donnees
fprintf('>>> Nombre de points pris en compte: %d  \n',numel(eval_new));
ret=meta_krg_ckrg(tirages_new,eval_new,[],meta);
%% extraction informations
ret.in.tirages_init=tirages;
ret.in.eval_init=eval;
ret.in.pas_tayl=pas_tayl;

