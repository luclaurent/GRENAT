%% Fonction assurant le calcul de diverses erreurs par validation croisee dans le cas du Krigeage/CoKrigeage
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_krg_ckrg(data_block,meta)

%norme employee dans le calcul de l'erreur LOO
%MSE: norme-L2
LOO_norm='L2';
% affichages warning ou non
aff_warning=false;

mod_debug=true;

%denormalisation des grandeurs pour calcul CV
denorm_cv=true;
if denorm_cv;denorm_cv=data_block.norm.on;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des evaluations du metamodele au point enleve
cv_z=zeros(data_block.in.nb_val,1);
cv_var=zeros(data_block.in.nb_val,1);
cv_gz=zeros(data_block.in.nb_val,data_block.in.nb_var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%On parcourt l'ensemble des tirages
parcours_ev=1;
parcours_gr=1;

for tir=1:data_block.in.nb_val
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %passage des parametres
    donnees_cv=data_block;
    %%On construit le metamodele de CoKrigeage avec uns site en moins
    %Traitement des matrices et vecteurs en supprimant les lignes et
    %colonnes correspondant
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
        case 'QR'
            %prise en compte suppression lignes/colonnes
            Qr=data_block.build.Qrcc;Rr=data_block.build.Rrcc;
            for ii=length(pos):-1:1
                [Qr,Rr]=qrdelete(Qr,Rr,pos(ii),'col');
                [Qr,Rr]=qrdelete(Qr,Rr,pos(ii),'row');
            end
            donnees_cv.build.Qrcc=Qr;
            donnees_cv.build.Rrcc=Rr;
            donnees_cv.build.yQ=Qr'*cv_y;
            donnees_cv.build.fcQ=Qr'*cv_fc;
            donnees_cv.build.fctR=cv_fct/Rr;
            donnees_cv.build.fctCfc=(cv_fc\Qr)*(Rr/cv_fct);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %calcul du coefficient beta
            %%approche classique
            block1=donnees_cv.build.fctR*donnees_cv.build.fcQ;
            block2=donnees_cv.build.fctR* donnees_cv.build.yQ;
            donnees_cv.build.beta=block1\block2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %calcul du coefficient gamma
            donnees_cv.build.gamma=Rr\(donnees_cv.build.yQ-donnees_cv.build.fcQ*donnees_cv.build.beta);
            %calcul de la variance de prediction
            sig2=1/size(Qr,1)*((cv_y-cv_fc*donnees_cv.build.beta)'/Rr*Qr')...
                *(cv_y-cv_fc*donnees_cv.build.beta);
            % case 'LU'
            % case 'LL'
        otherwise
            donnees_cv.build.fact_rcc='None';
            cv_rcc=data_block.build.rcc;
            cv_rcc(pos,:)=[];
            cv_rcc(:,pos)=[];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %calcul de beta
            block1=((cv_fct/cv_rcc)*cv_fc);
            block2=((cv_fct/cv_rcc)*cv_y);
            donnees_cv.build.beta=block1\block2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %creation de la matrice des facteurs de correlation
            donnees_cv.build.gamma=cv_rcc\(cv_y-cv_fc*donnees_cv.build.beta);
            donnees_cv.build.rcc=cv_rcc;
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
%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-data_block.in.eval;
if data_block.in.pres_grad
    diffg=cv_gz-data_block.in.grad;
end

%Biais moyen
cv.perso.bm=1/data_block.in.nb_val*sum(diff);
%MSE
diffc=diff.^2;
cv.eloor=1/data_block.in.nb_val*sum(diffc);
1/data_block.in.nb_val*sum(diffc)
if data_block.in.pres_grad
    diffgc=diffg.^2;
    cv.eloog=1/(data_block.in.nb_val*data_block.in.nb_var)*sum(diffgc(:));
    cv.eloot=1/(data_block.in.nb_val*(data_block.in.nb_var+1))*(data_block.in.nb_val*cv.eloor+data_block.in.nb_val*data_block.in.nb_var*cv.eloog);
else
    cv.eloot=cv.eloor;
end
%PRESS
cv.perso.press=sum(diffc);
%critere d'adequation (SCVR Keane 2005/Jones 1998)
cv.scvr=diff./cv_var;
cv.scvr_min=min(cv.scvr(:));
cv.scvr_max=max(cv.scvr(:));
cv.scvr_mean=mean(cv.scvr(:));
%critere perso
somm=0.5*(cv_z+data_block.in.eval);
cv.perso.errp=1/data_block.in.nb_val*sum(diff./somm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Nouvelle strategie basee sur les demonstration de M. Bompard
%vecteurs des ecarts aux echantillons retires (reponses et gradients)
esn=data_block.build.iRcc*data_block.in.eval./diag(data_block.build.iRcc);

%denormalisation des grandeurs (forc
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
            1/data_block.in.nb_val*(cv.press)
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
    fprintf('+++ PRESS %4.2f\n',cv.perso.press);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Trace du graph QQ
if meta.cv_aff
    opt.newfig=false;
    figure
    subplot(2,2,1);
    opt.title='Original data';
    qq_plot(data_block.in.eval,cv_z,opt)
    if data_block.norm.on
        subplot(2,2,2);
        infos.moy=data_block.norm.moy_eval;
        infos.std=data_block.norm.std_eval;
        cv_zn=norm_denorm(cv_z,'norm',infos);
        opt.title='Standardized data';
        qq_plot(data_block.in.evaln,cv_zn,opt)
        subplot(2,2,3);
        opt.title='SCVR';
        %    scvr_plot(cv_zn,cv.scvr,opt)
    end
    %subplot(2,2,4);
    %opt.title='SCVR';
    %opt.xlabel='Predicted' ;
    %opt.ylabel='SCVR';
    %qq_plot(cv_zn,cv.adequ,opt)
end


