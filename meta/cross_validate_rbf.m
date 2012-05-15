%% Fonction assurant le calcul de diverses erreurs par validation crois�e dans le cas RBF/HBFRB
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_rbf(data_block,data,meta)

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
%%On parcourt l'ensemble des tirages
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
    
    %cf. Rippa 1999/Fasshauer 2007
    %%!!!! a coder: differentes factorisation
%     cv_zn(tir)=data.build.y(pos(1))-data_block.build.w(pos(1))/data_block.build.iKK(pos(1),pos(1));
%     if data.in.pres_grad
%        cv_gzn(tir,:)=data.build.y(pos(2:end))-...
%            data_block.build.w(pos(2:end))./diag(data_block.build.iKK(pos(2:end),pos(2:end)));
%     end
    
    
    
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
%critere d'adequation
%diffa=diffc./cv_var;
%cv.adequ=1/donnees.in.nb_val*sum(diffa);
%critere perso
cv.errp=1/data.in.nb_val*sum(abs(diff)./somm);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Trac� du graph QQ
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



