%procÃ©dure de calcul CV pour debug

function [cv]=cross_validate_rbf(data_block,data,meta,type)

%norme employee dans le calcul de l'erreur LOO
%MSE: norme-L2
LOO_norm='L2';

% affichages warning ou non
aff_warning=false;

%denormalisation des grandeurs pour calcul CV
denorm_cv=true;
if denorm_cv;denorm_cv=data.norm.on;end

%differents cas de figure
mod_debug=false;mod_etud=false;mod_final=false;
if nargin==4
    switch type
        case 'debug' %mode debug (grandeurs affichees)
            fprintf('+++ CV RBF en mode DEBUG\n');
            mod_debug=true;
        case 'etud'  %mode etude (calcul des critères par les deux méthodes
            mod_etud=true;
            % case 'nominal'  %mode nominal (calcul des criteres par la methode de Rippa)
        case 'final'    %mode final (calcul des variances)
            mod_final=true;
    end
else
    mod_final=true;
end

if mod_debug||mod_etud
    condKK=condest(data_block.build.KK);
    if condKK>1e12
        fprintf('+++ //!\\ Mauvais conditionnement (%4.2e)\n',condKK);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Methode de Rippa (Rippa 1999/Fasshauer 2007/Bompard 2011)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%vecteurs des ecarts aux echantillons retires (reponses et gradients)
esn=data_block.build.w./diag(data_block.build.iKK);

%denormalisation des grandeurs (forc
infos.moy=data.norm.moy_eval;
infos.std=data.norm.std_eval;infos.std_e=infos.std;
infos.std_t=data.norm.std_tirages;
if data.in.pres_grad
    if data.norm.on&&denorm_cv
        %denormalisation difference reponses
        esr=norm_denorm(esn(1:data.in.nb_val),'denorm_diff',infos);
        %denormalisation difference gradients
        esg=norm_denorm_g(esn(data.in.nb_val+1:end),'denorm_concat',infos);
        es=[esr;esg];
    else
        esr=esn(1:data.in.nb_val);
        esg=esn(data.in.nb_val+1:end);
        es=esn;
    end
else
    if data.norm.on&&denorm_cv
        es=norm_denorm(esn,'denorm_diff',infos);
    else
        es=esn;
    end
    esr=es;
end

%calcul des erreurs en reponses et en gradients (differentes normes
%employees)
switch LOO_norm
    case 'L1'
        if data.in.pres_grad
            cv.press=esr'*esr;
            cv.eloor=1/data.in.nb_val*sum(abs(esr));
            cv.eloog=1/(data.in.nb_val*data.in.nb_var)*sum(abs(esg));
            cv.eloot=1/(data.in.nb_val*(data.in.nb_var+1))*sum(abs(es));
        else
            cv.press=es'*es;
            cv.eloot=1/data.in.nb_val*sum(abs(es));
        end
    case 'L2' %MSE
        if data.in.pres_grad
            cv.press=esr'*esr;
            cv.eloor=1/data.in.nb_val*(cv.press);
            cv.eloog=1/(data.in.nb_val*data.in.nb_var)*(esg'*esg);
            cv.eloot=1/(data.in.nb_val*(data.in.nb_var+1))*(es'*es);
        else
            cv.press=es'*es;
            cv.eloot=1/data.in.nb_val*(cv.press);
        end
    case 'Linf'
        if data.in.pres_grad
            cv.press=esr'*esr;
            cv.eloor=1/data.in.nb_val*max(esr(:));
            cv.eloog=1/(data.in.nb_val*data.in.nb_var)*max(esg(:));
            cv.eloot=1/(data.in.nb_val*(data.in.nb_var+1))*max(es(:));
        else
            cv.press=es'*es;
            cv.eloot=1/data.in.nb_val*max(es(:));
        end
end
%affichage qques infos
if mod_debug
    fprintf('=== CV-LOO par methode de Rippa 1999 (extension Bompard 2011)\n');
    fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
    if data.in.pres_grad
        fprintf('+++ Erreur reponses %4.2f\n',cv.eloor);
        fprintf('+++ Erreur gradient %4.2f\n',cv.eloog);
    end
    fprintf('+++ Erreur total %4.2f\n',cv.eloot);
    fprintf('+++ PRESS %4.2f\n',cv.perso.press);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Methode CV classique (retrait simultanee des reponses et gradient en
%%% chaque echantillon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mod_etud||mod_debug||mod_final
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %stockage des evaluations du metamodele au point enleve
    cv_z=zeros(data.in.nb_val,1);
    cv_var=zeros(data.in.nb_val,1);
    cv_gz=zeros(data.in.nb_val,data.in.nb_var);
    %parcours des echantillons
    for tir=1:data.in.nb_val
        %determination des position des grandeurs a supprimer
        if data.in.pres_grad
            pos=[tir data.in.nb_val+(tir-1)*data.in.nb_var+(1:data.in.nb_var)];
        else
            pos=tir;
        end
        
        %retrait des grandeurs
        cv_y=data.build.y;
        cv_KK=data_block.build.KK;
        cv_y(pos,:)=[];
        cv_KK(:,pos)=[];
        cv_KK(pos,:)=[];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul des coefficients
        if ~aff_warning; warning off all;end
        cv_w=cv_KK\cv_y;
        if ~aff_warning; warning on all;end
        cv_tirages=data.in.tirages;
        cv_tirages(tir,:)=[];
        cv_tiragesn=data.in.tiragesn;
        cv_tiragesn(tir,:)=[];
        %chargement des donnees
        donnees_cv=data;
        donnees_cv.build.fct=data_block.build.fct;
        donnees_cv.build.para=data_block.build.para;
        donnees_cv.build.w=cv_w;
        donnees_cv.build.KK=cv_KK;
        donnees_cv.in.nb_val=data.in.nb_val-1; %retrait d'un site
        donnees_cv.in.tirages=cv_tirages;
        donnees_cv.in.tiragesn=cv_tiragesn;
        %evaluation de la reponse, des derivees et de la variance au site
        %retire
        [Z,GZ,variance]=eval_rbf(data.in.tirages(tir,:),donnees_cv);
        cv_z(tir)=Z;
        cv_gz(tir,:)=GZ;
        cv_var(tir)=variance;
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calcul des erreurs
    %ecart reponses
    diff=cv_z-data.in.eval;
    if data.in.pres_grad
        %ecart gradients
        diffg=cv_gz-data.in.grad;
    end
    %ecart reponses (norme au choix)
    switch LOO_norm
        case 'L1'
            diffc=abs(diff);
        case 'L2'
            diffc=diff.^2;
        case 'Linf'
            diffc=max(diff(:));
    end
    %critere perso
    somm=0.5*(cv_z+data.in.eval);
    cv.perso.errp=1/data.in.nb_val*sum(abs(diff)./somm);
    %PRESS
    cv.perso.press=sum(diffc);
    %biais moyen
    cv.perso.bm=1/data.in.nb_val*sum(diff);
    if data.in.pres_grad
        %ecart gradients (norme au choix)
        switch LOO_norm
            case 'L1'
                diffgc=abs(diffg);
            case 'L2'
                diffgc=diff.^2;
            case 'Linf'
                diffgc=max(diffg);
        end
        %moyenne ecart reponses, gradients et mixte au carres
        cv.perso.eloor=1/data.in.nb_val*sum(diffc);
        cv.perso.eloog=1/(data.in.nb_val*data.in.nb_var)*sum(diffgc(:));
        cv.perso.eloot=1/(data.in.nb_val*(1+data.in.nb_var))*(sum(diffc)+sum(diffgc(:)));
    else
        %moyenne ecart reponses
        cv.perso.eloor=1/data.in.nb_val*sum(diffc);
        cv.perso.eloot=cv.perso.eloor;
    end
    %critere d'adequation (SCVR Keane 2005/Jones 1998)
    cv.perso.scvr=diff./cv_var;
    cv.perso.scvr_min=min(cv.perso.scvr(:));
    cv.perso.scvr_max=max(cv.perso.scvr(:));
    cv.perso.scvr_mean=mean(cv.perso.scvr(:));
    %critere d'adequation (ATTENTION: a la norme!!!>> diff au carre)
    diffa=diffc./cv_var;
    cv.perso.adequ=1/data.in.nb_val*sum(diffa);
    %affichage qques infos
    if mod_debug
        fprintf('=== CV-LOO par methode retrait reponses et gradients\n');
        fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
        if data.in.pres_grad
            fprintf('+++ Erreur reponses %4.2f\n',cv.perso.eloor);
            fprintf('+++ Erreur gradient %4.2f\n',cv.perso.eloog);
        end
        fprintf('+++ Erreur total %4.2f\n',cv.perso.eloot);
        fprintf('+++ Biais moyen %4.2f\n',cv.perso.bm);
        fprintf('+++ PRESS %4.2f\n',cv.perso.press);
        fprintf('+++ Critere perso %4.2f\n',cv.perso.errp);
        fprintf('+++ SCVR (Min) %4.2f\n',cv.perso.scvr_min);
        fprintf('+++ SCVR (Max) %4.2f\n',cv.perso.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2f\n',cv.perso.scvr_mean);
        fprintf('+++ Adequation %4.2f\n',cv.perso.adequ);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul de la variance de prediction aux points echantillonnes (pour CV)
if mod_final
    cv_varR=zeros(data.in.nb_val,1);
    cv_zRn=zeros(data.in.nb_val,1);
    for tir=1:data.in.nb_val
        %retrait des reponses seules
        pos=tir;
        %extraction vecteur et calcul de la variance
        PP=data_block.build.KK(:,tir);
        ret_KK=data_block.build.KK;
        ret_y=data.build.y;
        ret_KK(pos,:)=[];
        ret_KK(:,pos)=[];
        ret_y(pos)=[];
        PP(pos)=[];
        if ~aff_warning; warning off all;end
        cv_varR(tir)=1-PP'*(ret_KK\PP);
        %calcul de la réponse
        cv_zRn(tir)=PP'*(ret_KK\ret_y);
        if ~aff_warning; warning on all;end
    end
    %denormalisation
    cv_zR=norm_denorm(cv_zRn,'denorm',infos);
    diffR=cv_zR-data.in.eval;
    %critere d'adequation (SCVR Keane 2005/Jones 1998)
    cv.scvr=diffR./cv_varR;
    cv.scvr_min=min(cv.scvr(:));
    cv.scvr_max=max(cv.scvr(:));
    cv.scvr_mean=mean(cv.scvr(:));
    %critere d'adequation
    diffa=esr.^2./cv_varR;
    cv.adequ=1/data.in.nb_val*sum(diffa);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Trace du graph QQ
if meta.cv_aff&&mod_final
        %normalisation 
    cv_zn=norm_denorm(cv_z,'norm',infos);
    opt.newfig=false;
    figure
    subplot(3,2,1);
    opt.title='Original data (CV R)';
    qq_plot(data.in.eval,cv_zR,opt)
    subplot(3,2,2);
    opt.title='Standardized data (CV R)';
    qq_plot(data.in.evaln,cv_zRn,opt)
    subplot(3,2,3);
    opt.title='Standardized data (CV F)';
    qq_plot(data.in.evaln,cv_z,opt)
    subplot(3,2,4);
    opt.title='Standardized data (CV F)';
    qq_plot(data.in.evaln,cv_zn,opt)
    subplot(3,2,5);
    opt.title='SCVR';
    opt.xlabel='Predicted' ;
    opt.ylabel='SCVR';
    scvr_plot(cv_zRn,cv.scvr,opt)
end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end