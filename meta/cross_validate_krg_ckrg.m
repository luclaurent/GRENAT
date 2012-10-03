%% Fonction assurant le calcul de diverses erreurs par validation croisee dans le cas du Krigeage/CoKrigeage
%L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function cv=cross_validate_krg_ckrg(data,meta)
% affichages warning ou non
aff_warning=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des evaluations du metamodele au point enleve
cv_z=zeros(data.in.nb_val,1);
cv_var=zeros(data.in.nb_val,1);
cv_gz=zeros(data.in.nb_val,data.in.nb_var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%On parcourt l'ensemble des tirages
parcours_ev=1;
parcours_gr=1;
for tir=1:data.in.nb_val
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %passage des parametres
    donnees_cv=data;
    %%On construit le metamodele de CoKrigeage avec un site en moins
    %Traitement des matrices et vecteurs en supprimant les lignes et
    %colonnes correspondant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %positions des element a retirer
    %on retire ce qui est disponible
    if data.manq.eval.on||data.manq.grad.on
        if data.manq.eval.on
            if data.manq.eval.masque(tir)
                pos=[];
            else
                pos=parcours_ev;
                parcours_ev=parcours_ev+1;
            end
        end
        if data.manq.grad.on&&data.in.pres_grad
            nb_manq_grad=sum(data.manq.grad.masque(tir,:));
            if nb_manq_grad==data.in.nb_var
                pos=pos;
            else
                pos=[pos data.in.nb_val-data.manq.eval.nb+(parcours_gr:(parcours_gr+data.in.nb_var-nb_manq_grad-1))];
                parcours_gr=parcours_gr+data.in.nb_var;
            end
            
        end
    else
        if data.in.pres_grad
            pos=[tir data.in.nb_val+(tir-1)*data.in.nb_var+(1:data.in.nb_var)];
        else
            pos=tir;
        end
    end
    
    cv_fc=data.build.fc;
    cv_fc(pos,:)=[];
    cv_fct=cv_fc';
    cv_y=data.build.y;
    cv_y(pos)=[];
    cv_tirages=data.in.tirages;
    cv_tirages(tir,:)=[];
    cv_tiragesn=data.in.tiragesn;
    cv_tiragesn(tir,:)=[];
    cv_eval=data.in.eval;
    if data.manq.eval.on||data.manq.grad.on
        cv_eval(tir)=[];
        if data.in.pres_grad
            cv_grad=data.in.grad;
            cv_grad(tir,:)=[];
        else
            cv_grad=[];
        end
        ret_manq=examen_in_data(cv_tirages,cv_eval,cv_grad);
        donnees_cv.manq=ret_manq;
    end
    %si factorisation
    if ~aff_warning; warning off all;end
    switch data.build.fact_rcc
        case 'QR'
            %prise en compte suppression lignes/colonnes
            Qr=data.build.Qrcc;Rr=data.build.Rrcc;
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
            cv_rcc=data.build.rcc;
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
    if data.norm.on
        donnees_cv.sig2=sig2*data.norm.std_eval^2;
    else
        donnees_cv.sig2=sig2;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %passage des parametres
    donnees_cv.in.tirages=cv_tirages;
    donnees_cv.in.tiragesn=cv_tiragesn;
    donnees_cv.in.nb_val=data.in.nb_val-1;  %retrait d'un site
    donnees_cv.build.fc=cv_fc;
    donnees_cv.build.fct=cv_fct;
    donnees_cv.enrich.on=false;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Evaluation du metamodele au point supprime de la construction
    [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_krg_ckrg(data.in.tirages(tir,:),donnees_cv);
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-data.in.eval;
if data.in.pres_grad
    diffg=cv_gz-data.in.grad;
end

%Biais moyen
cv.perso.bm=1/data.in.nb_val*sum(diff);
%MSE
diffc=diff.^2;
cv.eloor=1/data.in.nb_val*sum(diffc);
if data.in.pres_grad
    diffgc=diffg.^2;
    cv.eloog=1/(data.in.nb_val*data.in.nb_var)*sum(diffgc(:));
    cv.eloot=1/(data.in.nb_val*(data.in.nb_var+1))*(data.in.nb_val*cv.eloor+data.in.nb_val*data.in.nb_var*cv.eloog);
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
somm=0.5*(cv_z+data.in.eval);
cv.perso.errp=1/data.in.nb_val*sum(diff./somm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Trace du graph QQ
if meta.cv_aff
    opt.newfig=false;
    figure
    subplot(2,2,1);
    opt.title='Original data';
    qq_plot(data.in.eval,cv_z,opt)
    if data.norm.on
        subplot(2,2,2);
        infos.moy=data.norm.moy_eval;
        infos.std=data.norm.std_eval;
        cv_zn=norm_denorm(cv_z,'norm',infos);
        opt.title='Standardized data';
        qq_plot(data.in.evaln,cv_zn,opt)
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


