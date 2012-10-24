%% Fonction assurant le calcul de diverses erreurs par validation croisee dans le cas du Krigeage/CoKrigeage
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr
%nouvelle version du 19/10/2012

function cv=cross_validate_krg_ckrg(data_block,meta,type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% OPTIONS
%norme employee dans le calcul de l'erreur LOO
%MSE: norme-L2
LOO_norm='L2';
%debug
debug=false;

% affichages warning ou non
aff_warning=false;

%denormalisation des grandeurs pour calcul CV
denorm_cv=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if denorm_cv;denorm_cv=data_block.norm.on;end

%differents cas de figure
mod_debug=debug;mod_etud=meta.cv_full;mod_final=false;
if nargin==3
    switch type
        case 'debug' %mode debug (grandeurs affichees)
            fprintf('+++ CV KRG en mode DEBUG\n');
            mod_debug=true;
        case 'etud'  %mode etude (calcul des criteres par les deux methodes
            mod_etud=true;
        case 'estim'  %mode estimation
            mod_etud=false;
            % case 'nominal'  %mode nominal (calcul des criteres par la methode de Rippa)
        case 'final'    %mode final (calcul des variances)
            mod_final=true;
    end
else
    mod_final=true;
end

if mod_debug||mod_etud
    condRcc=condest(data_block.build.rcc);
    if condRcc>1e12
        fprintf('+++ //!\\ Mauvais conditionnement (%4.2e)\n',condRcc);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement des grandeurs
nb_var=data_block.in.nb_var;
nb_val=data_block.in.nb_val;
norm_on=data_block.norm.on;
pres_grad=data_block.in.pres_grad;
moy_eval=data_block.norm.moy_eval;
std_eval=data_block.norm.std_eval;
std_tirages=data_block.norm.std_tirages;

if mod_final;tic;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adaptation de la methode de Rippa (Rippa 1999/Fasshauer 2007) par M. Bompard (Bompard 2011)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vecteurs des ecarts aux echantillons retires (reponses et gradients)
esn=data_block.build.coef_KRG./diag(data_block.build.iMKrg);
%retrait des valeurs non coherentes (lie a la partie modele de
%tendance/regression)
esn=esn(1:(end-data_block.build.dim_fc));

%denormalisation des grandeurs
infos.moy=moy_eval;
infos.std=std_eval;infos.std_e=infos.std;
infos.std_t=std_tirages;
if pres_grad
    if norm_on&&denorm_cv
        %denormalisation difference reponses
        esr=norm_denorm(esn(1:nb_val),'denorm_diff',infos);
        %denormalisation difference gradients
        esg=norm_denorm_g(esn(nb_val+1:end),'denorm_concat',infos);
        es=[esr;esg];
    else
        esr=esn(1:nb_val);
        esg=esn(nb_val+1:end);
        es=esn;
    end
else
    if norm_on&&denorm_cv
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
        if pres_grad
            cv.then.press=esr'*esr;
            cv.then.eloor=1/nb_val*sum(abs(esr));
            cv.then.eloog=1/(nb_val*nb_var)*sum(abs(esg));
            cv.then.eloot=1/(nb_val*(nb_var+1))*sum(abs(es));
            cv.press=cv.then.press;
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
            cv.eloot=cv.then.eloot;
        else
            cv.then.press=es'*es;
            cv.then.eloot=1/nb_val*sum(abs(es));
            cv.press=cv.then.press;
            cv.eloot=cv.then.eloot;
        end
    case 'L2' %MSE
        if pres_grad
            cv.then.press=esr'*esr;
            cv.then.eloor=1/nb_val*(cv.then.press);
            cv.then.eloog=1/(nb_val*nb_var)*(esg'*esg);
            cv.then.eloot=1/(nb_val*(nb_var+1))*(es'*es);
            cv.press=cv.then.press;
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
            cv.eloot=cv.then.eloot;
        else
            cv.then.press=es'*es;
            cv.then.eloot=1/nb_val*(cv.then.press);
            cv.press=cv.then.press;
            cv.eloot=cv.then.eloot;
        end
    case 'Linf'
        if pres_grad
            cv.then.press=esr'*esr;
            cv.then.eloor=1/nb_val*max(esr(:));
            cv.then.eloog=1/(nb_val*nb_var)*max(esg(:));
            cv.then.eloot=1/(nb_val*(nb_var+1))*max(es(:));
            cv.press=cv.then.press;
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
            cv.eloot=cv.then.eloot;
        else
            cv.then.press=es'*es;
            cv.then.eloot=1/nb_val*max(es(:));
            cv.press=cv.then.press;
            cv.eloot=cv.then.eloot;
        end
end
%affichage qques infos
if mod_debug||mod_final
    fprintf('=== CV-LOO par methode de Rippa 1999 (extension Bompard 2011)\n');
    fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
    if pres_grad
        fprintf('+++ Erreur reponses %4.2e\n',cv.then.eloor);
        fprintf('+++ Erreur gradient %4.2e\n',cv.then.eloog);
    end
    fprintf('+++ Erreur total %4.2e\n',cv.then.eloot);
    fprintf('+++ PRESS %4.2e\n',cv.then.press);
end
if mod_final;toc;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Methode CV classique (retrait SUCCESSIVE des reponses et gradients)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mod_debug
    tic
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %stockage des evaluations du metamodele au point enleve
    cv_z=zeros(nb_val,1);
    cv_var=zeros(nb_val,1);
    cv_gz=zeros(nb_val,nb_var);
    yy=data_block.build.y;
    MKrg=data_block.build.MKrg;
    fc=data_block.build.fc;
    rcc=data_block.build.rcc;
    tirages=data_block.in.tirages;
    tiragesn=data_block.in.tiragesn;
    grad=data_block.in.grad;
    eval=data_block.in.eval;
    dim_c=data_block.build.dim_fc;
    %parcours des echantillons
    for tir=1:nb_val
        %chargement des donnees
        donnees_cv=data_block;
        %retrait des grandeurs
        cv_MKrg=MKrg([1:(tir-1) (tir+1):end],[1:(tir-1) (tir+1):end]);
        cv_y=yy([1:(tir-1) (tir+1):end]');
        cv_rcc=rcc([1:(tir-1) (tir+1):end],[1:(tir-1) (tir+1):end]);
        cv_fc=fc([1:(tir-1) (tir+1):end],:);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul des coefficients
        if ~aff_warning; warning off all;end
        donnees_cv.build.fact_rcc='None';
        cv_iMKrg=inv(cv_MKrg);
        donnees_cv.build.iMKrg=cv_iMKrg;
        coefKRG=cv_iMKrg*[cv_y;zeros(dim_c,1)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extraction coefficients beta et gamma
        donnees_cv.build.beta=coefKRG((end-dim_c+1):end);
        donnees_cv.build.gamma=coefKRG(1:(end-dim_c));
        donnees_cv.build.rcc=cv_rcc;
        
        %calcul de la variance de prediction
        sig2=1/size(cv_rcc,1)*((cv_y-cv_fc*donnees_cv.build.beta)'*donnees_cv.build.gamma);
        if ~aff_warning; warning on all;end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if norm_on
            donnees_cv.sig2=sig2*std_eval^2;
        else
            donnees_cv.sig2=sig2;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %passage des parametres
        donnees_cv.in.tirages=tirages;
        donnees_cv.in.tiragesn=tiragesn;
        donnees_cv.in.nb_val=nb_val;  %retrait d'un site
        donnees_cv.build.fc=cv_fc;
        donnees_cv.build.fct=cv_fc';
        donnees_cv.enrich.on=false;
        %on retire la reponse associe
        donnees_cv.manq.grad.on=false;
        donnees_cv.manq.eval.on=true;
        donnees_cv.manq.eval.ix_manq=tir;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Evaluation du metamodele au point supprime de la construction
        [cv_z(tir),~,cv_var(tir)]=eval_krg_ckrg(tirages(tir,:),donnees_cv);
        %retrait gradients
        if pres_grad
            for pos_gr=1:nb_var
                %chargement des donnees
                donnees_cv=data_block;
                pos=nb_val+(tir-1)*nb_var+pos_gr;
                %retrait des grandeurs
                cv_MKrg=MKrg([1:(pos-1) (pos+1):end],[1:(pos-1) (pos+1):end]);
                cv_y=yy([1:(pos-1) (pos+1):end]');
                cv_rcc=rcc([1:(pos-1) (pos+1):end],[1:(pos-1) (pos+1):end]);
                cv_fc=fc([1:(pos-1) (pos+1):end],:);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %calcul des coefficients
                if ~aff_warning; warning off all;end
                donnees_cv.build.fact_rcc='None';
                cv_iMKrg=inv(cv_MKrg);
                donnees_cv.build.iMKrg=cv_iMKrg;
                coefKRG=cv_iMKrg*[cv_y;zeros(dim_c,1)];
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %extraction coefficients beta et gamma
                donnees_cv.build.beta=coefKRG((end-dim_c+1):end);
                donnees_cv.build.gamma=coefKRG(1:(end-dim_c));
                donnees_cv.build.rcc=cv_rcc;
                
                %calcul de la variance de prediction
                sig2=1/size(rcc,1)*((cv_y-cv_fc*donnees_cv.build.beta)'*donnees_cv.build.gamma);
                if ~aff_warning; warning on all;end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if norm_on
                    donnees_cv.sig2=sig2*std_eval^2;
                else
                    donnees_cv.sig2=sig2;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %passage des parametres
                donnees_cv.in.tirages=tirages;
                donnees_cv.in.tiragesn=tiragesn;
                donnees_cv.in.nb_val=nb_val;  %retrait d'un site
                donnees_cv.build.fc=cv_fc;
                donnees_cv.build.fct=cv_fc';
                donnees_cv.enrich.on=false;
                %on retire le gradient associe
                donnees_cv.manq.grad.on=true;
                donnees_cv.manq.eval.on=false;
                donnees_cv.manq.grad.ixt_manq_line=pos-nb_val;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%Evaluation du metamodele au point supprime de la construction
                [~,GZ,~]=eval_krg_ckrg(tirages(tir,:),donnees_cv);
                cv_gz(tir,pos_gr)=GZ(pos_gr);
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calcul des erreurs
    [cv.then]=calc_err_loo(eval,cv_z,cv_var,grad,cv_gz,nb_val,nb_var,LOO_norm);
    %affichage qques infos
    if mod_debug
        fprintf('=== CV-LOO par methode retrait reponses PUIS gradients (debug)\n');
        fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
        if pres_grad
            fprintf('+++ Erreur reponses %4.2e\n',cv.then.eloor);
            fprintf('+++ Erreur gradient %4.2e\n',cv.then.eloog);
        end
        fprintf('+++ Erreur total %4.2e\n',cv.then.eloot);
        fprintf('+++ Biais moyen %4.2e\n',cv.then.bm);
        fprintf('+++ PRESS %4.2e\n',cv.then.press);
        fprintf('+++ Critere perso %4.2e\n',cv.then.errp);
        fprintf('+++ SCVR (Min) %4.2e\n',cv.then.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.then.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.then.scvr_mean);
        fprintf('+++ Adequation %4.2e\n',cv.then.adequ);
    end
    toc
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Methode CV classique (retrait simultanee des reponses et gradient en
%%% chaque echantillon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mod_etud||mod_debug||meta.cv_aff
    tic
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %stockage des evaluations du metamodele au point enleve
    cv_z=zeros(nb_val,1);
    cv_var=zeros(nb_val,1);
    cv_gz=zeros(nb_val,nb_var);
    yy=data_block.build.y;
    MKrg=data_block.build.MKrg;
    fc=data_block.build.fc;
    rcc=data_block.build.rcc;
    tirages=data_block.in.tirages;
    tiragesn=data_block.in.tiragesn;
    grad=data_block.in.grad;
    eval=data_block.in.eval;
    dim_c=data_block.build.dim_fc;
    %parcours des echantillons
    for tir=1:nb_val
        %chargement des donnees
        donnees_cv=data_block;
        %retrait des grandeurs
        if pres_grad
            pos=[tir nb_val+(tir-1)*nb_var+(1:nb_var)];
            IX_i=1:((nb_var+1)*nb_val);
        else
            pos=tir;
            IX_i=1:(nb_val);
        end
        %complement index initiaux
        IX_c=IX_i(end)+(1:dim_c);
        %index des elements a extraire
        IX_e=setxor(IX_i,pos);
        
        cv_MKrg=MKrg([IX_e IX_c],[IX_e IX_c]);
        cv_y=yy(IX_e');
        cv_rcc=rcc(IX_e,IX_e);
        cv_fc=fc(IX_e,:);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul des coefficients
        if ~aff_warning; warning off all;end
        donnees_cv.build.fact_rcc='None';
        cv_iMKrg=inv(cv_MKrg);
        donnees_cv.build.iMKrg=cv_iMKrg;
        coefKRG=cv_iMKrg*[cv_y;zeros(dim_c,1)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extraction coefficients beta et gamma
        donnees_cv.build.beta=coefKRG((end-dim_c+1):end);
        donnees_cv.build.gamma=coefKRG(1:(end-dim_c));
        donnees_cv.build.rcc=cv_rcc;
        
        %calcul de la variance de prediction
        sig2=1/size(cv_rcc,1)*((cv_y-cv_fc*donnees_cv.build.beta)'*donnees_cv.build.gamma);
        if ~aff_warning; warning on all;end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if norm_on
            donnees_cv.sig2=sig2*std_eval^2;
        else
            donnees_cv.sig2=sig2;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %passage des parametres
        donnees_cv.in.tirages=tirages([1:(tir-1) (tir+1):end],:);
        donnees_cv.in.tiragesn=tiragesn([1:(tir-1) (tir+1):end],:);
        donnees_cv.in.nb_val=nb_val-1;  %retrait d'un site
        donnees_cv.build.fc=cv_fc;
        donnees_cv.build.fct=cv_fc';
        donnees_cv.enrich.on=false;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Evaluation du metamodele au point supprime de la construction
        [Z,GZ,variance]=eval_krg_ckrg(tirages(tir,:),donnees_cv);
        cv_z(tir)=Z;
        cv_gz(tir,:)=GZ;
        cv_var(tir)=variance;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calcul des erreurs
    [cv.and]=calc_err_loo(eval,cv_z,cv_var,grad,cv_gz,nb_val,nb_var,LOO_norm);
    %affichage qques infos
    if mod_debug||mod_final
        fprintf('=== CV-LOO par methode retrait reponses ET gradients\n');
        fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
        if pres_grad
            fprintf('+++ Erreur reponses %4.2e\n',cv.and.eloor);
            fprintf('+++ Erreur gradient %4.2e\n',cv.and.eloog);
        end
        fprintf('+++ Erreur total %4.2e\n',cv.and.eloot);
        fprintf('+++ Biais moyen %4.2e\n',cv.and.bm);
        fprintf('+++ PRESS %4.2e\n',cv.and.press);
        fprintf('+++ Critere perso %4.2e\n',cv.and.errp);
        fprintf('+++ SCVR (Min) %4.2e\n',cv.and.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.and.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.and.scvr_mean);
        fprintf('+++ Adequation %4.2e\n',cv.and.adequ);
    end
    toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul de la variance  de prediction aux points echantillonnes + test calcul reponses et gradients (pour CV)
%%%ATTENTION defaut pour cas avec gradients et/ou donnees manquantes
if meta.cv_aff||mod_debug
    tic
    cv_varR=zeros(nb_val,1);
    cv_zRn=zeros(nb_val,1);
    cv_GZn=zeros(nb_val,nb_var);
    yy=data_block.build.y;
    MKrg=data_block.build.MKrg;
    fc=data_block.build.fc;
    rcc=data_block.build.rcc;
    grad=data_block.in.grad;
    eval=data_block.in.eval;
    dim_c=data_block.build.dim_fc;
    for tir=1:nb_val
        %extraction des grandeurs
        PP=MKrg(tir,:);
        PP(tir)=[];
        cv_MKrg=MKrg([1:(tir-1) (tir+1):end],[1:(tir-1) (tir+1):end]);
        cv_y=yy([1:(tir-1) (tir+1):end]');
        cv_rcc=rcc([1:(tir-1) (tir+1):end],[1:(tir-1) (tir+1):end]);
        cv_fc=fc([1:(tir-1) (tir+1):end],:);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul des coefficients
        if ~aff_warning; warning off all;end
        coefKRG=cv_MKrg\[cv_y;zeros(dim_c,1)];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extraction coefficients beta et gamma
        beta=coefKRG((end-dim_c+1):end);
        
        %calcul de la variance du processus
        sig2=1/size(cv_rcc,1)*((cv_y-cv_fc*beta)'*gamma);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if norm_on
            sig2=sig2*std_eval^2;
        end
        %calcul de la variance de prediction
        cv_varR(tir)=sig2*(1-PP*(cv_MKrg\PP'));
        %calcul de la reponse
        cv_zRn(tir)=PP*coefKRG;
        if ~aff_warning; warning on all;end
        %retrait gradients
        if pres_grad
            for pos_gr=1:nb_var
                pos=nb_val+(tir-1)*nb_var+pos_gr;
                %retrait des grandeurs
                cv_MKrg=MKrg([1:(pos-1) (pos+1):end],[1:(pos-1) (pos+1):end]);
                cv_y=yy([1:(pos-1) (pos+1):end]');
                %extraction vecteur
                dPP=MKrg(pos,:);
                dPP(pos)=[];
                %calcul du gradients
                GZ=dPP*(cv_MKrg\[cv_y;zeros(dim_c,1)]);
                cv_GZn(tir,pos_gr)=GZ;
            end
        end
    end
    
    %denormalisation
    cv_zR=norm_denorm(cv_zRn,'denorm',infos);
    cv_GZ=norm_denorm_g(cv_GZn,'denorm',infos);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calcul des erreurs
    [cv.then]=calc_err_loo(eval,cv_zR,cv_varR,grad,cv_GZ,nb_val,nb_var,LOO_norm);
    %affichage qques infos
    if mod_debug||mod_final
        fprintf('=== CV-LOO par methode retrait reponses PUIS gradients\n');
        fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
        if pres_grad
            fprintf('+++ Erreur reponses %4.2e\n',cv.then.eloor);
            fprintf('+++ Erreur gradient %4.2e\n',cv.then.eloog);
        end
        fprintf('+++ Erreur total %4.2e\n',cv.then.eloot);
        fprintf('+++ Biais moyen %4.2e\n',cv.then.bm);
        fprintf('+++ PRESS %4.2e\n',cv.then.press);
        fprintf('+++ Critere perso %4.2e\n',cv.then.errp);
        fprintf('+++ SCVR (Min) %4.2e\n',cv.then.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.then.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.then.scvr_mean);
        fprintf('+++ Adequation %4.2e\n',cv.then.adequ);
    end
    toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul de la variance  de prediction aux points echantillonnes (pour CV)
%%%ATTENTION defaut pour cas avec gradients et/ou donnees manquantes
if mod_final
    tic
    cv_varR=zeros(nb_val,1);
    yy=data_block.build.y;
    MKrg=data_block.build.MKrg;
    fc=data_block.build.fc;
    rcc=data_block.build.rcc;
    dim_c=data_block.build.dim_fc;
    for tir=1:nb_val
        
        %extraction des grandeurs
        PP=MKrg(tir,:);
        PP(tir)=[];
        cv_MKrg=MKrg([1:(tir-1) (tir+1):end],[1:(tir-1) (tir+1):end]);
        cv_y=yy([1:(tir-1) (tir+1):end]');
        cv_rcc=rcc([1:(tir-1) (tir+1):end],[1:(tir-1) (tir+1):end]);
        cv_fc=fc([1:(tir-1) (tir+1):end],:);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul des coefficients
        if ~aff_warning; warning off all;end
        coefKRG=cv_MKrg\[cv_y;zeros(dim_c,1)];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extraction coefficients beta et gamma
        beta=coefKRG((end-dim_c+1):end);
        
        %calcul de la variance du processus
        sig2=1/size(cv_rcc,1)*((cv_y-cv_fc*beta)'/cv_rcc)*(cv_y-cv_fc*beta);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if norm_on
            sig2=sig2*std_eval^2;
        end
        %calcul de la variance de prediction
        cv_varR(tir)=sig2*(1-PP*(cv_MKrg\PP'));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calcul des erreurs
    [cv.final]=calc_err_loo(zeros(size(esr)),-esr,cv_varR,[],[],nb_val,nb_var,LOO_norm);
    cv.then.scvr_min=cv.final.scvr_min;
    cv.then.scvr_max=cv.final.scvr_max;
    cv.then.scvr_mean=cv.final.scvr_mean;
    %affichage qques infos
    if mod_debug||mod_final
        fprintf('=== CV-LOO SCVR\n');
        fprintf('+++ SCVR (Min) %4.2e\n',cv.final.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.final.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.final.scvr_mean);
    end
    toc
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
    qq_plot(data_block.in.eval,cv_zR,opt)
    subplot(3,2,2);
    opt.title='Standardized data (CV R)';
    qq_plot(data_block.in.evaln,cv_zRn,opt)
    subplot(3,2,3);
    opt.title='Original data (CV F)';
    qq_plot(data_block.in.eval,cv_z,opt)
    subplot(3,2,4);
    opt.title='Standardized data (CV F)';
    qq_plot(data_block.in.evaln,cv_zn,opt)
    subplot(3,2,5);
    opt.title='SCVR';
    opt.xlabel='Predicted' ;
    opt.ylabel='SCVR';
    scvr_plot(cv_zRn,cv.final.scvr,opt)
end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%