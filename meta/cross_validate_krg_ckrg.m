%% Fonction assurant le calcul de diverses erreurs par validation croisée dans le cas du Krigeage/CoKrigeage
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_krg_ckrg(donnees,meta)
% affichages warning ou non
aff_warning=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des evaluations du metamodele au point enleve
cv_z=zeros(donnees.in.nb_val,1);
cv_var=zeros(donnees.in.nb_val,1);
cv_gz=zeros(donnees.in.nb_val,donnees.in.nb_var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%On parcourt l'ensemble des tirages
for tir=1:donnees.in.nb_val
    %%On construit le metamodele de CoKrigeage avec un site en moins
    %Traitement des matrices et vecteurs en supprimant les lignes et
    %colonnes correspondant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %positions des element a retirer
    if donnees.in.pres_grad
        pos=[tir donnees.in.nb_val+(tir-1)*donnees.in.nb_var+(1:donnees.in.nb_var)];
    else
        pos=tir;
    end
    cv_fc=donnees.build.fc;
    cv_fc(pos,:)=[];
    cv_rcc=donnees.build.rcc;
    cv_rcc(pos,:)=[];
    cv_rcc(:,pos)=[];
    cv_y=donnees.build.y;
    cv_y(pos)=[];
    cv_tirages=donnees.in.tirages;
    cv_tirages(tir,:)=[];
    cv_tiragesn=donnees.in.tiragesn;
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
    if donnees.norm.on
        donnees_cv.sig2=sig2*donnees.norm.std_eval^2;
    else
        donnees_cv.sig2=sig2;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %passage des parametres
    donnees_cv=donnees;
    donnees_cv.in.tirages=cv_tirages;
    donnees_cv.in.tiragesn=cv_tiragesn;
    donnees_cv.in.nb_val=donnees.in.nb_val-1;  %retrait d'un site
    donnees_cv.build.rcc=cv_rcc;
    donnees_cv.build.fc=cv_fc;
    donnees_cv.build.fct=cv_ft;
    donnees_cv.build.gamma=gamma;
    donnees_cv.build.beta=beta;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_krg_ckrg(donnees.in.tirages(tir,:),donnees_cv);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-donnees.in.eval;
%Biais moyen
cv.bm=1/donnees.in.nb_val*sum(diff);
%MSE
diffc=diff.^2;
cv.msep=1/donnees.in.nb_val*sum(diffc);
%PRESS
cv.press=sum(diffc);
%critere d'adequation (SCVR Keane 2005/Jones 1998)
scvr=diff./cv_var;
cv.adequ=1/donnees.in.nb_val*sum(scvr);
%critere perso


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Tracé du graph QQ
if meta.cv_aff
    opt.newfig=false;
    figure
    subplot(2,2,1);
    opt.title='Original data';
    qq_plot(donnees.in.eval,cv_z,opt)
    subplot(2,2,2);
    infos.moy=donnees.norm.moy_eval;
    infos.std=donnees.norm.std_eval;
    cv_zn=norm_denorm(cv_z,'norm',infos);
    opt.title='Standardized data';
    qq_plot(donnees.in.evaln,cv_zn,opt)
    subplot(2,2,3);
    opt.title='SCVR';
    scvr_plot(cv_zn,scvr,opt)
    %subplot(2,2,4);
    %opt.title='SCVR';
    %opt.xlabel='Predicted' ;
    %opt.ylabel='SCVR';
    %qq_plot(cv_zn,cv.adequ,opt)
end


