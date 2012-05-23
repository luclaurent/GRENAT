%% Fonction assurant le calcul de diverses erreurs par validation croisï¿½e dans le cas RBF/HBFRB
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_rbf(data_block,data,meta)

%norme employee dans le calcul de l'erreur LOO
%MSE: norme-L2
LOO_norm='L2';

% affichages warning ou non
aff_warning=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des evaluations du metamodele au point enleve
cv_zn=zeros(data.in.nb_val,1);
cv_gzn=zeros(data.in.nb_val,data.in.nb_var);
cv_z=zeros(data.in.nb_val,1);
cv_var=zeros(data.in.nb_val,1);
cv_gz=zeros(data.in.nb_val,data.in.nb_var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Soit on parcours l'ensemble des tirages
%% Soit on utilise la méthode de Rippa (Rippa 1999/Fasshauer 2007/Bompard 2011)

%vecteur des ecarts aux echantillons retires
esn=data_block.build.w./diag(data_block.build.iKK);
infos.moy=data.norm.moy_eval;
infos.std=data.norm.std_eval;infos.std_e=infos.std;
infos.std_t=data.norm.std_tirages;
%denormalisation
if data.in.pres_grad
    %denormalisation difference reponses
    esr=norm_denorm(esn(1:data.in.nb_val),'denorm_diff',infos);
    %denormalisation difference gradients
    esg=norm_denorm_g(esn(data.in.nb_val+1:end),'denorm_concat',infos);
    es=[esr;esg];
else
    es=norm_denorm(esn,'denorm_diff',infos);
end



switch LOO_norm
    case 'L1'
        if data.in.pres_grad
            eloor=1/data.in.nb_val*sum(abs(esr));
            eloog=1/(data.in.nb_val*data.in.nb_var)*sum(abs(esg));
            eloot=1/(data.in.nb_val*(data.in.nb_var+1))*sum(abs(es));
        else
            eloot=1/data.in.nb_val*sum(abs(es));
        end
    case 'L2' %MSE
        if data.in.pres_grad
            eloor=1/data.in.nb_val*(esr'*esr);
            eloog=1/(data.in.nb_val*data.in.nb_var)*(esg'*esg);
            eloot=1/(data.in.nb_val*(data.in.nb_var+1))*(es'*es);
        else
            eloot=1/data.in.nb_val*(es'*es);
        end
    case 'Linf'
        if data.in.pres_grad
            eloor=1/data.in.nb_val*max(esr(:));
            eloog=1/(data.in.nb_val*data.in.nb_var)*max(esg(:));
            eloot=1/(data.in.nb_val*(data.in.nb_var+1))*max(es(:));
        else
            eloot=1/data.in.nb_val*max(es(:));
        end
end

for tir=1:data.in.nb_val
    %%On construit le metamodele RBF/HBRBF avec un site en moins
    %Traitement des matrices et vecteurs en supprimant les lignes et
    %colonnes correspondant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %positions des element a retirer
    if data.in.pres_grad
        pos=[tir data.in.nb_val+(tir-1)*data.in.nb_var+(1:data.in.nb_var)];
        % pos=(tir-1)*(data.in.nb_var+1)+1:tir*(data.in.nb_var+1);
    else
        pos=tir;
    end
    cv_KK=data_block.build.KK;
    cv_KK(pos,:)=[];
    cv_KK(:,pos)=[];
    cv_y=data.build.y;
    cv_y(pos)=[];
    cv_tirages=data.in.tirages;
    cv_tirages(tir,:)=[];
    cv_tiragesn=data.in.tiragesn;
    cv_tiragesn(tir,:)=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calcul des coefficients
    if ~aff_warning; warning off all;end
    cv_w=cv_KK\cv_y;
    if ~aff_warning; warning on all;end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %passage des parametres
    donnees_cv=data;
    donnees_cv.build.fct=data_block.build.fct;
    donnees_cv.build.para=data_block.build.para;
    donnees_cv.in.tirages=cv_tirages;
    donnees_cv.in.tiragesn=cv_tiragesn;
    donnees_cv.in.nb_val=data.in.nb_val-1;  %retrait d'un site
    donnees_cv.build.KK=cv_KK;
    donnees_cv.build.w=cv_w;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_rbf(data.in.tirages(tir,:),donnees_cv);
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
infos.moy=data.norm.moy_eval;
infos.std=data.norm.std_eval;
%cv_z=norm_denorm(cv_zn,'denorm',infos);
diff=cv_z-data.in.eval;

if data.in.pres_grad
    if meta.norm
        infos.std_e=data.norm.std_eval;
        infos.std_t=data.norm.std_tirages;
        cv_gz=norm_denorm_g(cv_gzn,'denorm',infos);
    else
        cv_gz=cv_gzn;
    end
    diffg=cv_gz-data.in.grad;
end


somm=0.5*(cv_z+data.in.eval);
%Biais moyen
cv.bm=1/data.in.nb_val*sum(diff);
%MSE
diffc=diff.^2;
cv.msep=1/data.in.nb_val*sum(diffc);
cv.loot=eloot;
if data.in.pres_grad
    diffgc=diffg.^2;
    cv.mseg=1/(data.in.nb_val*data.in.nb_var)*sum(diffgc(:));
    cv.msemix=1/(data.in.nb_val*(data.in.nb_var+1))*(data.in.nb_val*cv.msep+data.in.nb_val*data.in.nb_var*cv.mseg);
    cv.loor=eloor;
    cv.loog=eloog;
    
end
if abs(cv.loot-cv.msep)>10e-10
    cv.loot
    cv.msep
    abs(cv.loot-cv.msep)
    figure;
    condest(data_block.build.KK)
    data_block.build.para.val
    
    plot(1:numel(es),es.^2,'b')
    hold on
    plot(1:numel(diff),diffc,'r')
    plot(1:numel(diff),abs(es.^2-diffc),'k')
end
% if abs(cv.loor-cv.msep)>10e-10
%     cv.loor
%     cv.msep
%     cv.loog
%     cv.loot
%     cv.mseg
%     cv.msemix
%
%     cv.loor-cv.msep
%     pause
% end

%PRESS
cv.press=sum(diffc);
%critere d'adequation (SCVR Keane 2005/Jones 1998)
cv.scvr=diff./cv_var;
cv.scvr_min=min(cv.scvr(:));
cv.scvr_max=max(cv.scvr(:));
cv.scvr_mean=mean(cv.scvr(:));
%critere d'adequation
%diffa=diffc./cv_var;
%cv.adequ=1/donnees.in.nb_val*sum(diffa);
%critere perso
cv.errp=1/data.in.nb_val*sum(abs(diff)./somm);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Tracï¿½ du graph QQ
if meta.cv_aff
    opt.newfig=false;
    figure
    subplot(2,2,1);
    opt.title='Original data';
    qq_plot(data.in.eval,cv_z,opt)
    subplot(2,2,2);
    infos.moy=data.norm.moy_eval;
    infos.std=data.norm.std_eval;
    cv_zn=norm_denorm(cv_z,'norm',infos);
    opt.title='Standardized data';
    qq_plot(data.in.evaln,cv_zn,opt)
    subplot(2,2,3);
    opt.title='SCVR';
    scvr_plot(cv_zn,cv.scvr,opt)
    %subplot(2,2,4);
    %opt.title='SCVR';
    %opt.xlabel='Predicted' ;
    %opt.ylabel='SCVR';
    %qq_plot(cv_zn,cv.adequ,opt)
end



