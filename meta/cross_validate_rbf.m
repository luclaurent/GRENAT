%% Fonction assurant le calcul de diverses erreurs par validation croisée dans le cas RBF/HBFRB
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_rbf(data,meta)

% affichages warning ou non
aff_warning=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des evaluations du metamodele au point enleve
cv_z=zeros(data.in.nb_val,1);
cv_gz=zeros(data.in.nb_val,data.in.nb_var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%On parcourt l'ensemble des tirages
for tir=1:data.in.nb_val
    %%On construit le metamodele RBF/HBRBF avec un site en moins
    %Traitement des matrices et vecteurs en supprimant les lignes et
    %colonnes correspondant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %positions des element a retirer
    if data.in.pres_grad
        pos=(tir-1)*(data.in.nb_var+1)+1:tir*(data.in.nb_var+1);
    else
        pos=tir;
    end
    cv_KK=data.build.KK;
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
    donnees_cv.in.tirages=cv_tirages;
    donnees_cv.in.tiragesn=cv_tiragesn;
    donnees_cv.in.nb_val=data.in.nb_val-1;  %retrait d'un site
    donnees_cv.build.KK=cv_KK;
    donnees_cv.build.w=cv_w;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:)]=eval_rbf(data.in.tirages(tir,:),donnees_cv);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-data.in.eval;
%Biais moyen
cv.bm=1/data.in.nb_val*sum(diff);
%MSE
diffc=diff.^2;
cv.msep=1/data.in.nb_val*sum(diffc);
%PRESS
cv.press=sum(diffc);
%critere d'adequation
%diffa=diffc./cv_var;
%cv.adequ=1/donnees.in.nb_val*sum(diffa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Tracé du graph QQ
if meta.cv_aff
    opt.newfig=false;
    figure
    subplot(1,2,1);
    opt.title='Original data';
    qq_plot(data.in.eval,cv_z,opt)
    subplot(1,2,2);
    infos.moy=data.norm.moy_eval;
    infos.std=data.norm.std_eval;
    cv_zn=norm_denorm(cv_z,'norm',infos);
    opt.title='Standardized data';
    qq_plot(data.in.evaln,cv_zn,opt)
end


