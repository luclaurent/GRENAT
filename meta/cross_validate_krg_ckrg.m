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
% affichages warning ou non
aff_warning=false;

%denormalisation des grandeurs pour calcul CV
denorm_cv=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if denorm_cv;denorm_cv=data_block.norm.on;end

%differents cas de figure
mod_debug=false;mod_etud=false;mod_final=false;
if nargin==3
    switch type
        case 'debug' %mode debug (grandeurs affichees)
            fprintf('+++ CV KRG en mode DEBUG\n');
            mod_debug=true;
        case 'etud'  %mode etude (calcul des criteres par les deux m�thodes
            mod_etud=true;
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
infos.moy=data_block.norm.moy_eval;
infos.std=data_block.norm.std_eval;infos.std_e=infos.std;
infos.std_t=data_block.norm.std_tirages;
if data_block.in.pres_grad
    if data_block.norm.on&&denorm_cv
        %denormalisation difference reponses
        esr=norm_denorm(esn(1:data_block.in.nb_val),'denorm_diff',infos);
        %denormalisation difference gradients
        esg=norm_denorm_g(esn(data_block.in.nb_val+1:end),'denorm_concat',infos);
        es=[esr;esg];
    else
        esr=esn(1:data_block.in.nb_val);
        esg=esn(data_block.in.nb_val+1:end);
        es=esn;
    end
else
    if data_block.norm.on&&denorm_cv
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
        if data_block.in.pres_grad
            cv.press=esr'*esr;
            cv.eloor=1/data_block.in.nb_val*sum(abs(esr));
            cv.eloog=1/(data_block.in.nb_val*data_block.in.nb_var)*sum(abs(esg));
            cv.eloot=1/(data_block.in.nb_val*(data_block.in.nb_var+1))*sum(abs(es));
        else
            cv.press=es'*es;
            cv.eloot=1/data_block.in.nb_val*sum(abs(es));
        end
    case 'L2' %MSE
        if data_block.in.pres_grad
            cv.press=esr'*esr;
            cv.eloor=1/data_block.in.nb_val*(cv.press);
            cv.eloog=1/(data_block.in.nb_val*data_block.in.nb_var)*(esg'*esg);
            cv.eloot=1/(data_block.in.nb_val*(data_block.in.nb_var+1))*(es'*es);
        else
            cv.press=es'*es;
            cv.eloot=1/data_block.in.nb_val*(cv.press);
        end
    case 'Linf'
        if data_block.in.pres_grad
            cv.press=esr'*esr;
            cv.eloor=1/data_block.in.nb_val*max(esr(:));
            cv.eloog=1/(data_block.in.nb_val*data_block.in.nb_var)*max(esg(:));
            cv.eloot=1/(data_block.in.nb_val*(data_block.in.nb_var+1))*max(es(:));
        else
            cv.press=es'*es;
            cv.eloot=1/data_block.in.nb_val*max(es(:));
        end
end
%affichage qques infos
if mod_debug
    fprintf('=== CV-LOO par methode de Rippa 1999 (extension Bompard 2011)\n');
    fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
    if data_block.in.pres_grad
        fprintf('+++ Erreur reponses %4.2f\n',cv.eloor);
        fprintf('+++ Erreur gradient %4.2f\n',cv.eloog);
    end
    fprintf('+++ Erreur total %4.2f\n',cv.eloot);
    fprintf('+++ PRESS %4.2f\n',cv.press);
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
    cv_z=zeros(data_block.in.nb_val,1);
    cv_var=zeros(data_block.in.nb_val,1);
    cv_gz=zeros(data_block.in.nb_val,data_block.in.nb_var);
    %parcours des echantillons
    for tir=1:data_block.in.nb_val
        %chargement des donnees
        donnees_cv=data_block;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %positions des element a retirer
        %on retire ce qui est disponible
        if data_block.manq.eval.on||data_block.manq.grad.on
            if data_block.manq.eval.on
                if data_block.manq.eval.masque(tir)
                    pos=[];
                else
                    pos=parcours_ev;
                    parcours_ev=parcours_ev+1;
                end
            end
            if data_block.manq.grad.on&&data_block.in.pres_grad
                nb_manq_grad=sum(data_block.manq.grad.masque(tir,:));
                if nb_manq_grad==data_block.in.nb_var
                    pos=pos;
                else
                    pos=[pos data_block.in.nb_val-data_block.manq.eval.nb+(parcours_gr:(parcours_gr+data_block.in.nb_var-nb_manq_grad-1))];
                    parcours_gr=parcours_gr+data_block.in.nb_var;
                end
                
            end
        else
            if data_block.in.pres_grad
                pos=[tir data_block.in.nb_val+(tir-1)*data_block.in.nb_var+(1:data_block.in.nb_var)];
            else
                pos=tir;
            end
        end
        cv_fc=data_block.build.fc;
    cv_fc(pos,:)=[];
    cv_fct=cv_fc';
    cv_y=data_block.build.y;
    cv_y(pos)=[];
    cv_tirages=data_block.in.tirages;
    cv_tirages(tir,:)=[];
    cv_tiragesn=data_block.in.tiragesn;
    cv_tiragesn(tir,:)=[];
    cv_eval=data_block.in.eval;
    if data_block.manq.eval.on||data_block.manq.grad.on
        cv_eval(tir)=[];
        if data_block.in.pres_grad
            cv_grad=data_block.in.grad;
            cv_grad(tir,:)=[];
        else
            cv_grad=[];
        end
        ret_manq=examen_in_data(cv_tirages,cv_eval,cv_grad);
        donnees_cv.manq=ret_manq;
    end
    %si factorisation
    if ~aff_warning; warning off all;end
    switch data_block.build.fact_rcc
%         case 'QR'
%             %prise en compte suppression lignes/colonnes
%             Qr=data_block.build.Qrcc;Rr=data_block.build.Rrcc;
%             for ii=length(pos):-1:1
%                 [Qr,Rr]=qrdelete(Qr,Rr,pos(ii),'col');
%                 [Qr,Rr]=qrdelete(Qr,Rr,pos(ii),'row');
%             end
%             donnees_cv.build.Qrcc=Qr;
%             donnees_cv.build.Rrcc=Rr;
%             donnees_cv.build.yQ=Qr'*cv_y;
%             donnees_cv.build.fcQ=Qr'*cv_fc;
%             donnees_cv.build.fctR=cv_fct/Rr;
%             donnees_cv.build.fctCfc=(cv_fc\Qr)*(Rr/cv_fct);
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %calcul du coefficient beta
%             %%approche classique
%             block1=donnees_cv.build.fctR*donnees_cv.build.fcQ;
%             block2=donnees_cv.build.fctR* donnees_cv.build.yQ;
%             donnees_cv.build.beta=block1\block2;
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %calcul du coefficient gamma
%             donnees_cv.build.gamma=Rr\(donnees_cv.build.yQ-donnees_cv.build.fcQ*donnees_cv.build.beta);
%             %calcul de la variance de prediction
%             sig2=1/size(Qr,1)*((cv_y-cv_fc*donnees_cv.build.beta)'/Rr*Qr')...
%                 *(cv_y-cv_fc*donnees_cv.build.beta);
            % case 'LU'
            % case 'LL'
        otherwise
            donnees_cv.build.fact_rcc='None';
            cv_rcc=data_block.build.rcc;
            cv_rcc(pos,:)=[];
            cv_rcc(:,pos)=[];
            
                    % matrice de krigeage: M=[C X;Xt 0];
        dim_c=size(cv_fct,1);
        cv_MKrg=[cv_rcc cv_fc;cv_fct zeros(dim_c)];
        cv_iMKrg=inv(cv_MKrg);
        coefKRG=cv_iMKrg*[cv_y;zeros(dim_c,1)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
         donnees_cv.build.beta=coefKRG((end-dim_c+1):end);
         donnees_cv.build.gamma=coefKRG(1:(end-dim_c));
        %reconditionnement variable KRG (CV)
            donnees_cv.build.rcc=cv_rcc;
            donnees_cv.build.MKrg=cv_MKrg;
            donnees_cv.build.iMKrg=cv_iMKrg;
            %calcul de la variance de prediction
            sig2=1/size(cv_rcc,1)*((cv_y-cv_fc*donnees_cv.build.beta)'/cv_rcc)...
                *(cv_y-cv_fc*donnees_cv.build.beta);
    end
    if ~aff_warning; warning on all;end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if data_block.norm.on
        donnees_cv.sig2=sig2*data_block.norm.std_eval^2;
    else
        donnees_cv.sig2=sig2;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %passage des parametres
    donnees_cv.in.tirages=cv_tirages;
    donnees_cv.in.tiragesn=cv_tiragesn;
    donnees_cv.in.nb_val=data_block.in.nb_val-1;  %retrait d'un site
    donnees_cv.build.fc=cv_fc;
    donnees_cv.build.fct=cv_fct;
    donnees_cv.enrich.on=false;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_krg_ckrg(data_block.in.tirages(tir,:),donnees_cv);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calcul des erreurs
    %ecart reponses
    diff=cv_z-data_block.in.eval;
    if data_block.in.pres_grad
        %ecart gradients
        diffg=cv_gz-data_block.in.grad;
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
    somm=0.5*(cv_z+data_block.in.eval);
    cv.perso.errp=1/data_block.in.nb_val*sum(abs(diff)./somm);
    %PRESS
    cv.perso.press=sum(diffc);
    %biais moyen
    cv.perso.bm=1/data_block.in.nb_val*sum(diff);
    if data_block.in.pres_grad
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
        cv.perso.eloor=1/data_block.in.nb_val*sum(diffc);
        cv.perso.eloog=1/(data_block.in.nb_val*data_block.in.nb_var)*sum(diffgc(:));
        cv.perso.eloot=1/(data_block.in.nb_val*(1+data_block.in.nb_var))*(sum(diffc)+sum(diffgc(:)));
    else
        %moyenne ecart reponses
        cv.perso.eloor=1/data_block.in.nb_val*sum(diffc);
        cv.perso.eloot=cv.perso.eloor;
    end
    %critere d'adequation (SCVR Keane 2005/Jones 1998)
    cv.perso.scvr=diff./cv_var;
    cv.perso.scvr_min=min(cv.perso.scvr(:));
    cv.perso.scvr_max=max(cv.perso.scvr(:));
    cv.perso.scvr_mean=mean(cv.perso.scvr(:));
    %critere d'adequation (ATTENTION: a la norme!!!>> diff au carre)
    diffa=diffc./cv_var;
    cv.perso.adequ=1/data_block.in.nb_val*sum(diffa);
    %affichage qques infos
    if mod_debug
        fprintf('=== CV-LOO par methode retrait reponses et gradients\n');
        fprintf('+++ Norme calcul CV-LOO: %s\n',LOO_norm);
        if data_block.in.pres_grad
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

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Trace du graph QQ
if meta.cv_aff&&mod_final
    %normalisation
    cv_zn=norm_denorm(cv_z,'norm',infos);
    opt.newfig=false;
    figure
    %subplot(3,2,1);
    %opt.title='Original data (CV R)';
    %qq_plot(data_block.in.eval,cv_zR,opt)
    %subplot(3,2,2);
    %opt.title='Standardized data (CV R)';
    %qq_plot(data_block.in.evaln,cv_zRn,opt)
    %subplot(3,2,3);
    opt.title='Standardized data (CV F)';
    qq_plot(data_block.in.evaln,cv_z,opt)
    subplot(3,2,4);
    opt.title='Standardized data (CV F)';
    qq_plot(data_block.in.evaln,cv_zn,opt)
    %subplot(3,2,5);
    %opt.title='SCVR';
    %opt.xlabel='Predicted' ;
    %opt.ylabel='SCVR';
    %scvr_plot(cv_zRn,cv.scvr,opt)
end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end



%critere d'adequation (SCVR Keane 2005/Jones 1998)
%cv.scvr=diff./cv_var;
%cv.scvr_min=min(cv.scvr(:));
%cv.scvr_max=max(cv.scvr(:));
%cv.scvr_mean=mean(cv.scvr(:));
%critere perso
%somm=0.5*(cv_z+data_block.in.eval);
%cv.perso.errp=1/data_block.in.nb_val*sum(diff./somm);



