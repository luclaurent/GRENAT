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
for tir=1:krg.dim
   %%On construit le metamodele de CoKrigeage avec un site en moins
   %Traitement des matrices et vecteurs en supprimant les lignes et
   %colonnes correspondant 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %positions des element a retirer
       if donnees.in.pres_grad
    pos=[tir donnees.in.nb_val+(tir-1)*donnees.in.nb_var+(1:donnees.in.nb_var)];
       else
           pos=[tir];
       end
    cv_fc=donnees.build.fc;
    cv_fc(pos,:)=[];
    cv_rcc=ckrg.rcc;
    cv_rcc(pos,:)=[];
    cv_rcc(:,pos)=[];
    cv_y=ckrg.y;
    cv_y(pos)=[];
    cv_tirages=tirages;
    cv_tirages(tir,:)=[];
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %passage des parametres
   donnees_cv=donnees.;
   donnees_cv.in.nb_val=donnees_cv.in.nb_val-1;  %retrait d'un site
   donnees_cv.build.rcc=cv_rcc;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %calcul de beta
   if a~ff_warning; warning off all;end
   cv_ft=cv_fc';
   block1=((cv_ft/cv_rcc)*cv_fc);
   block2=((cv_ft/cv_rcc)*cv_y);
   donnees_cv.build.beta=block1\block2;   
   donnees_cv.ft=cv_ft;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %creation de la matrice des facteurs de correlation
   donnees_cv.gamma=cv_rc\(cv_y-cv_fc*donnees_cv.build.beta);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %calcul de la variance de prediction   
    sig2=1/size(cv_rc,1)*((cv_y-cv_fc*donnees_cv.beta)'/cv_rc)...
        *(cv_y-cv_fc*donnees_cv.beta);
    if a~ff_warning; warning on all;end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if krg.norm.on
        donnees_cv.sig2=sig2*krg.norm.std_eval^2;
    else
        donnees_cv.sig2=sig2;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%Evaluation du metamodele au point supprime de la construction
   [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_krg(tirages(tir,:),donnees_cv,cv_tirages);
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-eval;
%Biais moyen
cv.bm=1/krg.dim*sum(diff);
%MSE
diffc=diff.^2;
cv.msep=1/krg.dim*sum(diffc);
%PRESS
cv.press=sum(diffc);
%critere d'adequation
diffa=diffc./cv_var;
cv.adequ=1/krg.dim*sum(diffa);


%%%CKRG


%%On parcourt l'ensemble des tirages
for tir=1:ckrg.dim
    %%On construit le metamodele de CoKrigeage avec un site en moins
    %Traitement des matrices et vecteurs en supprimant les lignes et
    %colonnes correspondant
    

    
    %passage des parametres
    ckrg_cv=ckrg;
    ckrg_cv.dim=ckrg_cv.dim-1;  %retrait d'un site
    ckrg_cv.rcc=cv_rcc;
    
    %calcul de beta
    warning off all
    cv_ft=cv_fc';
    block1=((cv_ft/cv_rcc)*cv_fc);
    block2=((cv_ft/cv_rcc)*cv_y);
    ckrg_cv.beta=block1\block2;
    
    ckrg_cv.ft=cv_ft;
    
    %creation de la matrice des facteurs de correlation
    ckrg_cv.gamma=cv_rcc\(cv_y-cv_fc*ckrg_cv.beta);
    
    %calcul de la variance de prediction
    sig2=1/size(cv_rcc,1)*((cv_y-cv_fc*ckrg_cv.beta)'/cv_rcc)...
        *(cv_y-cv_fc*ckrg_cv.beta);
    if ckrg.norm.on
        ckrg_cv.sig2=sig2*ckrg.norm.std_eval^2;
    else
        ckrg_cv.sig2=sig2;
    end
    warning on all
    
    %chargement tirages-1
    ckrg_cv.tirages=[];
    ckrg_cv.tirages=cv_tirages;
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_ckrg(tirages(tir,:),ckrg_cv);
    
end

%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-eval;
%Biais moyen
cv.bm=1/ckrg.dim*sum(diff);
%MSE
diffc=diff.^2;
cv.msep=1/ckrg.dim*sum(diffc);
%PRESS
cv.press=sum(diffc);
%critere d'adequation
diffa=diffc./cv_var;
cv.adequ=1/ckrg.dim*sum(diffa);

