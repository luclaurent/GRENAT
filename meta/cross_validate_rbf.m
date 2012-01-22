%% Fonction assurant le calcul de diverses erreurs par validation croisée dans le cas RBF/HBFRB
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_rbf(donnees,meta)

% affichages warning ou non
aff_warning=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des evaluations du metamodele au point enleve
cv_z=zeros(donnees.in.nb_val,1);
cv_gz=zeros(donnees.in.nb_val,donnees.in.nb_var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%On parcourt l'ensemble des tirages
for tir=1:donnees.in.nb_val
    %%On construit le metamodele RBF/HBRBF avec un site en moins
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
    cv_KK=donnees.build.KK;
    cv_KK(pos,:)=[];
    cv_KK(:,pos)=[];
    cv_y=donnees.build.y;
    cv_y(pos)=[];
    cv_tirages=donnees.in.tirages;
    cv_tirages(tir,:)=[];
    cv_tiragesn=donnees.in.tiragesn;
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
    donnees_cv=donnees;
    donnees_cv.in.tirages=cv_tirages;
    donnees_cv.in.tiragesn=cv_tiragesn;
    donnees_cv.in.nb_val=donnees.in.nb_val-1;  %retrait d'un site
    donnees_cv.build.KK=cv_KK;
    donnees_cv.build.w=cv_w;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:)]=eval_rbf(donnees.in.tirages(tir,:),donnees_cv);
    
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
%critere d'adequation
%diffa=diffc./cv_var;
%cv.adequ=1/donnees.in.nb_val*sum(diffa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Tracé du graph QQ
if meta.cv_aff
    qq_plot(donnees.in.eval,cv_z)
end


