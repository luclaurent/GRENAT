%% Preparation for Indirect Gradient-Enhanced Surrogate Models
%% L. LAURENT -- 26/04/2016 -- luc.laurent@lecnam.net

function ret=PrepIn(samplingIn,respIn,gradIn,meta,manq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display information about the function
fprintf('>>> Preparation of data for Indirect Gradient-Based Surrogate Models  \n');

%dimension of the problem (number of parameters)
np=size(samplingIn,2);
% initial number of sample points
nbs_init=size(samplingIn,1);

if ~nargin==5
    manq.eval.on=false;
    manq.grad.on=false;
end  

%en fonction du type de donnees en entree
if ~isstruct(gradIn)
    fprintf('>> Valeur pas developpement de Taylor (manu):')
    fprintf(' %d',meta.para.pas_tayl);
    fprintf('\n')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Creation des nouveaux points (1 nouveau points par direction)
    %traitement pas Taylor
    if numel(meta.para.pas_tayl)~=np
        pas_tayl=meta.para.pas_tayl(1)*ones(1,np);
    else
        pas_tayl=meta.para.pas_tayl;
    end
    
    %Reordonnancement tirages et duplication
    reord_tir=reshape(samplingIn',1,[]);
    dup_tir=repmat(reord_tir,np+1,[]);
    %creation decalage par direction
    mat_pas=diag(pas_tayl);
    mat_pas_dup=[zeros(1,np*nbs_init);repmat(mat_pas,1,nbs_init)];
    badord_tir=dup_tir+mat_pas_dup;
    tirages_new=zeros((np+1)*nbs_init,np);
        
    %nouveaux points
    for ii=1:np
        li=ii:np:(np*nbs_init);            
        tirages_new(:,ii)=reshape(badord_tir(:,li),(np+1)*nbs_init,[]);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Nettoyage si donnees manquantes (attention en cas de reponse
    %%% manquante, on retire egalement le gradient car impossible d'estimer
    %%% la valeur de la reponse aux points proches sans la valeur de cette
    %%% reponse)
    pos_ev=[];
    if manq.eval.on
        pos_tmp=manq.eval.ix_manq;
        fprintf(' >>> Supression informations (r�ponse(s) manquante(s)) a(aux) point(s):');
        fprintf(' %i',pos_ev);
        fprintf('\n');
        %renumerotation pour extraction bonnes valeurs
        pos_tmp=(pos_tmp-1)*(np+1)+1;
        for ii=1:numel(pos_tmp)
            pos_ev=[pos_ev pos_tmp(ii):pos_tmp(ii)+np+1];
        end
    end

    pos_gr=[];
    if manq.grad.on
        pos_tmp=manq.grad.ix_manq;
        pos_gr=(pos_tmp(:,1)-1)*(np+1)+1+pos_tmp(:,2);
    end
  
    %position des elements manquants
    pos_manq=unique([pos_ev,pos_gr]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Creation des nouvelles reponses (aux points ajoutes)
    
    %Reordonnancement reponses
    tmp_ev=[respIn zeros(nbs_init,np-1)];
    reord_ev=reshape(tmp_ev',1,[]);
    dup_ev=repmat(reord_ev,np+1,[]);
    %Reordonnancement gradients
    reord_grad=reshape(gradIn',1,[]);
    dup_grad=repmat(reord_grad,np+1,[]);
    tmp=mat_pas_dup.*dup_grad;
    %si donnees manquantes, traitement specifiques pour eviter les NaN    
    if manq.grad.on||manq.eval.on
             IX=find(isnan(tmp(:)));
             tmp(IX)=0;
    end
        badord_ev=dup_ev+tmp;
    %nouvelles reponses
    tmp_ev=zeros((np+1)*nbs_init,np);
    for ii=1:np
        li=ii:np:(np*nbs_init);
        tmp_ev(:,ii)=reshape(badord_ev(:,li),(np+1)*nbs_init,[]);
    end
    eval_new=sum(tmp_ev,2);
    
    %supression des donnees manquantes
    if ~isempty(pos_manq)
        tirages_new(pos_manq,:)=[];
        eval_new(pos_manq)=[];
    end

else
    %%Attention donnees manquante non prises en compte dans cette approche
    %%(a coder)
    %calcul des pas de Taylor dans chaque direction
    pas_tayl_d=gradIn.tirages{1}-repmat(samplingIn(1,:),np,1);
    pas_tayl=abs(sum(pas_tayl_d,2));
    
    %Nouveaux tirages et reponses
    tirages_new=zeros((np+1)*nbs_init,np);
    eval_new=zeros((np+1)*nbs_init,1);
    for ii=1:nbs_init
        li_tir=(ii-1)*(np+1)+1;
        li_tirg=li_tir+1:ii*(np+1);
        tirages_new(li_tir,:)=samplingIn(ii,:);
        tirages_new(li_tirg,:)=gradIn.tirages{ii};
        eval_new(li_tir)=respIn(ii);
        eval_new(li_tirg)=gradIn.eval{ii};
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
ret.in.tirages_init=samplingIn;
ret.in.eval_init=respIn;
ret.in.pas_tayl=pas_tayl;

