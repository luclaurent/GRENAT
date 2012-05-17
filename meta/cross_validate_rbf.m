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
infos.std=data.norm.std_eval;
es=norm_denorm(esn,'denorm_diff',infos);

switch LOO_norm
    case 'L1'
        eloo=1/size(data_block.build.KK,1)*sum(abs(es));
    case 'L2' %MSE
        eloo=1/size(data_block.build.KK,1)*(es'*es);
    case 'Linf'
        eloo=1/size(data_block.build.KK,1)*max(es(:));
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
cv.loo=eloo;
hold off
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



