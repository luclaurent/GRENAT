%% Fonction assurant le calcul de diverses erreurs par validation croisee dans le cas du Krigeage/CoKrigeage
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_krg_ckrg(data,meta)
% affichages warning ou non
aff_warning=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des evaluations du metamodele au point enleve
cv_z=zeros(data.in.nb_val,1);
cv_var=zeros(data.in.nb_val,1);
cv_gz=zeros(data.in.nb_val,data.in.nb_var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%On parcourt l'ensemble des tirages
for tir=1:data.in.nb_val
    %%On construit le metamodele de CoKrigeage avec un site en moins
    %Traitement des matrices et vecteurs en supprimant les lignes et
    %colonnes correspondant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %positions des element a retirer
    if data.in.pres_grad
        pos=[tir data.in.nb_val+(tir-1)*data.in.nb_var+(1:data.in.nb_var)];
    else
        pos=tir;
    end
    cv_fc=data.build.fc;
    cv_fc(pos,:)=[];
    cv_rcc=data.build.rcc;
    cv_rcc(pos,:)=[];
    cv_rcc(:,pos)=[];
    cv_y=data.build.y;
    cv_y(pos)=[];
    cv_tirages=data.in.tirages;
    cv_tirages(tir,:)=[];
    cv_tiragesn=data.in.tiragesn;
    cv_tiragesn(tir,:)=[];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calcul de beta
    if ~aff_warning; warning off all;end
    cv_ft=cv_fc';
    block1=((cv_ft/cv_rcc)*cv_fc);
    block2=((cv_ft/cv_rcc)*cv_y);
    beta=block1\block2;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %creation de la matrice des facteurs de correlation
    gamma=cv_rcc\(cv_y-cv_fc*beta);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %calcul de la variance de prediction
    sig2=1/size(cv_rcc,1)*((cv_y-cv_fc*beta)'/cv_rcc)...
        *(cv_y-cv_fc*beta);
    if ~aff_warning; warning on all;end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if data.norm.on
        donnees_cv.sig2=sig2*data.norm.std_eval^2;
    else
        donnees_cv.sig2=sig2;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %passage des parametres
    donnees_cv=data;
    donnees_cv.in.tirages=cv_tirages;
    donnees_cv.in.tiragesn=cv_tiragesn;
    donnees_cv.in.nb_val=data.in.nb_val-1;  %retrait d'un site
    donnees_cv.build.rcc=cv_rcc;
    donnees_cv.build.fc=cv_fc;
    donnees_cv.build.fct=cv_ft;
    donnees_cv.build.gamma=gamma;
    donnees_cv.build.beta=beta;
    donnees_cv.enrich.on=false;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_krg_ckrg(data.in.tirages(tir,:),donnees_cv);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-data.in.eval;
if data.in.pres_grad
    diffg=cv_gz-data.in.grad;
end

%Biais moyen
cv.bm=1/data.in.nb_val*sum(diff);
%MSE
diffc=diff.^2;
cv.msep=1/data.in.nb_val*sum(diffc);
if data.in.pres_grad
    diffgc=diffg.^2;
    cv.mseg=1/(data.in.nb_val*data.in.nb_var)*sum(diffgc(:));
    cv.msemix=1/(data.in.nb_val*(data.in.nb_var+1))*(data.in.nb_val*cv.msep+data.in.nb_val*data.in.nb_var*cv.mseg);
end
%PRESS
cv.press=sum(diffc);
%critere d'adequation (SCVR Keane 2005/Jones 1998)
cv.scvr=diff./cv_var;
cv.scvr_min=min(cv.scvr(:));
cv.scvr_max=max(cv.scvr(:));
cv.scvr_mean=mean(cv.scvr(:));
%critere perso
somm=0.5*(cv_z+data.in.eval);
cv.errp=1/data.in.nb_val*sum(diff./somm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Trace du graph QQ
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


