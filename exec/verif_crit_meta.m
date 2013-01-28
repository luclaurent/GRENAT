%% fonction assurant la verification des criteres lies au metamodele
% L. LAURENt -- 28/01/2013 -- laurent@lmt.ens-cachan.fr


function  [crit_atteint,id_sub,infos_min]=verif_crit_meta(enrich,meta,infos_enrich,ref,approx,aff_subplot,old_tirages)

%initialisation flag criteres
crit_atteint=false;
done_min=false;
pts_ok=true;
mse_ok=true;
conv_loc_ex_ok=true;
conv_glob_ex_ok=true;
conv_rep_ok=true;
conv_loc_ok=true;
hist_r2_ok=true;
hist_q3_ok=true;
conv_r2_ok=true;
conv_q3_ok=true;
infos_min=[];
infos_min.Zap_min=[];
infos_min.Xap_min=[];

%reponse de reference et grille de verification
Zref=ref.Zref;
grille_verif=ref.grille_verif;

%infos liees a l'enrichissement
iteration_enrich=infos_enrich.iter;

%critere historique sur N metamodeles
nb_hist=4;

%correction rangement type
if ~iscell(enrich.crit_type)
    criteres={enrich.crit_type};
else
    criteres=enrich.crit_type;
end

%correction rangement critere
if ~iscell(enrich.val_crit)
    crit_val={enrich.val_crit};
else
    crit_val=enrich.val_crit;
end

%flag criteres bases sur l'histoire du critere
not_eval=true;
not_eval_hist=true;
    
%numero subplot
num_sub=1;
%identifiant subplot
id_sub=aff_subplot.id_sub;
nb_lign=aff_subplot.nb_lign;
nb_col=aff_subplot.nb_col;
%nb de points
nb_pts=size(old_tirages,1);
opt_plot.bornes=[nb_pts-1 nb_pts+1];


%parcours des types d'enrichissement
for  it_type=1:length(criteres)
    if it_type==1
        done_min=false;
    end
    %balayage des criteres
    switch criteres{it_type}
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % controle amelioration (par rapport aux 4 metamodeles
        % precedents)
        case {'HIST_R2','HIST_Q3'}
            if iteration_enrich>1
                fprintf(' >> Calcul criteres HIST_Q3 et HIST_R2 <<\n');
                if iteration_enrich<nb_hist-1
                    fprintf(' !!! Historique trop faible donc pas de test HIST_R2 ni HIST_Q3 <<\n ');
                end
                if not_eval
                    %evaluation dernier metamodele
                    Z_end=eval_meta(grille_verif,approx{end},meta);
                    not_eval=false;
                end
                if not_eval_hist
                    % evaluation des precedents metamodeles
                    nbmeta=min(iteration_enrich-1,nb_hist);
                    vR2=zeros(nbmeta,1);
                    vQ3=vR2;
                    for it_hist=1:nbmeta
                        Z_old=eval_meta(grille_verif,approx{end-it_hist},meta);
                        [~,~,vR2(it_hist),~]=fact_corr(Z_end.Z,Z_old.Z);
                        [~,~,vQ3(it_hist)]=qual(Z_end.Z,Z_old.Z);
                    end
                    not_eval_hist=false;
                end
                
                switch criteres{it_type}
                    case 'HIST_R2'
                        %moyenne R2
                        mR2=mean(vR2);
                        %sauvegarde valeur critere
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} mR2];
                        if iteration_enrich>=nb_hist-1
                            depass=(mR2-crit_val{it_type})/crit_val{it_type};
                            %affichage info
                            fprintf(' ==>> R2 (Hist %i) atteint: %d (max: %d) <<==\n',nb_hist,mR2,crit_val{it_type});
                            % verification temps atteint
                            if mR2>=crit_val{it_type}
                                hist_r2_ok=false;
                                fprintf(' ====> LIMITE R2 (Hist %i) ATTEINTE --- + %4.2e%s <====\n',nb_hist,depass*100,char(37))
                            else
                                hist_r2_ok=true;
                                fprintf(' ====> LIMITE R2 (Hist %i) NON ATTEINTE --- %4.2e%s <====\n',nb_hist,depass*100,char(37))
                            end
                        else
                            hist_r2_ok=true;
                        end
                        %trace de l'evolution
                        if enrich.aff_evol
                            if iteration_enrich==2;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                            opt_plot.tag='HIST_R2';
                            opt_plot.title='Evol. nombre de points';
                            opt_plot.xlabel='Nombre de points';
                            opt_plot.ylabel='HIST R2';
                            opt_plot.ech_log=false;
                            opt_plot.type='stairs';
                            opt_plot.cible=crit_val{it_type};
                            if iteration_enrich==2;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                            aff_evol(nb_pts,mR2,opt_plot,id_plotloc);
                            num_sub=num_sub+1;
                        end
                    case 'HIST_Q3'
                        %moyenne Q3
                        mQ3=mean(vQ3);
                        %sauvegarde valeur critere
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} mQ3];
                        if iteration_enrich>=nb_hist-1
                            depass=(mQ3-crit_val{it_type})/crit_val{it_type};
                            %affichage info
                            fprintf(' ==>> Q3 (Hist %i) atteint: %d (max: %d) <<==\n',nb_hist,mQ3,crit_val{it_type});
                            % verification temps atteint
                            if mQ3<=crit_val{it_type}
                                hist_q3_ok=false;
                                fprintf(' ====> LIMITE Q3 (Hist %i) ATTEINTE --- + %4.2e%s <====\n',nb_hist,depass*100,char(37))
                            else
                                hist_q3_ok=true;
                                fprintf(' ====> LIMITE Q3 (Hist %i) NON ATTEINTE --- %4.2e%s <====\n',nb_hist,depass*100,char(37))
                            end
                        else
                            hist_q3_ok=true;
                        end
                        %trace de l'evolution
                        if enrich.aff_evol
                            if iteration_enrich==2;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                            opt_plot.tag='HIST_Q3';
                            opt_plot.title='Evol. nombre de points';
                            opt_plot.xlabel='Nombre de points';
                            opt_plot.ylabel='HIST Q3';
                            opt_plot.ech_log=false;
                            opt_plot.type='stairs';
                            opt_plot.cible=crit_val{it_type};
                            if iteration_enrich==2;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                            aff_evol(nb_pts,mQ3,opt_plot,id_plotloc);
                            num_sub=num_sub+1;
                        end
                end
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % controle R2 par rapport a la vraie fonction
        case {'CONV_R2_EX','CONV_Q3_EX'}
            if not_eval
                %evaluation dernier metamodele
                Z_end=eval_meta(grille_verif,approx{end},meta);
                not_eval=false;
            end
            
            switch criteres{it_type}
                case 'CONV_R2_EX'
                    [~,~,vR2,~]=fact_corr(Z_end.Z,Zref);
                    %sauvegarde valeur critere
                    enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} vR2];
                    depass=(vR2-crit_val{it_type})/crit_val{it_type};
                    %affichage info
                    fprintf(' ==>> R2 atteint: %d (max: %d) <<==\n',vR2,crit_val{it_type});
                    % verification temps atteint
                    if vR2>=crit_val{it_type}
                        conv_r2_ok=false;
                        fprintf(' ====> LIMITE R2 ATTEINTE --- + %4.2e%s <====\n',depass*100,char(37))
                    else
                        conv_r2_ok=true;
                        fprintf(' ====> LIMITE R2 NON ATTEINTE --- %4.2e%s <====\n',depass*100,char(37))
                    end
                    %trace de l'evolution
                    if enrich.aff_evol
                        if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                        opt_plot.tag='CONV_R2_EX';
                        opt_plot.title='Evol. nombre de points';
                        opt_plot.xlabel='Nombre de points';
                        opt_plot.ylabel='R2 EX';
                        opt_plot.ech_log=false;
                        opt_plot.type='stairs';
                        opt_plot.cible=crit_val{it_type};
                        if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                        aff_evol(nb_pts,vR2,opt_plot,id_plotloc);
                        num_sub=num_sub+1;
                    end
                case 'CONV_Q3_EX'
                    [~,~,vQ3]=qual(Zref,Z_end.Z);
                    %sauvegarde valeur critere
                    enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} vQ3];
                    depass=(vQ3-crit_val{it_type})/crit_val{it_type};
                    %affichage info
                    fprintf(' ==>> Q3  atteint: %d (max: %d) <<==\n',vQ3,crit_val{it_type});
                    % verification temps atteint
                    if vQ3<=crit_val{it_type}
                        conv_q3_ok=false;
                        fprintf(' ====> LIMITE Q3 ATTEINTE --- + %4.2e%s <====\n',depass*100,char(37))
                    else
                        conv_q3_ok=true;
                        fprintf(' ====> LIMITE Q3 NON ATTEINTE --- %4.2e%s <====\n',depass*100,char(37))
                    end
                    %trace de l'evolution
                    if enrich.aff_evol
                        if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                        opt_plot.tag='CONV_Q3_EX';
                        opt_plot.title='Evol. nombre de points';
                        opt_plot.xlabel='Nombre de points';
                        opt_plot.ylabel='Q3 EX';
                        opt_plot.ech_log=true;
                        opt_plot.type='stairs';
                        opt_plot.cible=crit_val{it_type};
                        if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                        aff_evol(nb_pts,vQ3,opt_plot,id_plotloc);
                        num_sub=num_sub+1;
                    end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % controle en nombre de points
        case 'NB_PTS'
            fprintf(' >> Verification nombre de points echantillons <<\n ')
            % Extraction temps CPU
            tir=old_tirages;
            nb_pts=size(tir,1);
            depass=(nb_pts-crit_val{it_type})/crit_val{it_type};
            %affichage info
            fprintf(' ==>> Nombre de points atteint: %d (max: %d) <<==\n',nb_pts,crit_val{it_type});
            % verification temps atteint
            if nb_pts>=crit_val{it_type}
                pts_ok=false;
                fprintf(' ====> LIMITE Nombre de points ATTEINTE --- + %4.2e%s <====\n',depass*100,char(37))
            else
                pts_ok=true;
                fprintf(' ====> LIMITE Nombre de points NON ATTEINTE --- %4.2e%s <====\n',depass*100,char(37))
            end
            %sauvegarde valeur critere
            enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} nb_pts];
            
            %trace de l'evolution
            if enrich.aff_evol
                if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                opt_plot.tag='NB_PTS';
                opt_plot.title='Evol. nombre de points';
                opt_plot.xlabel='Nombre de points';
                opt_plot.ylabel='Nombre de points';
                opt_plot.ech_log=false;
                opt_plot.type='stairs';
                opt_plot.cible=crit_val{it_type};
                if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                aff_evol(nb_pts,nb_pts,opt_plot,id_plotloc);
                num_sub=num_sub+1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % controle en MSE (CV)
        case 'CV_MSE'
            % Extraction MSE (CV)
            msep=approx{end}.cv.eloot;
            depass=(msep-crit_val{it_type})/crit_val{it_type};
            %affichage info
            fprintf(' ==>> MSE (CV) atteint: %d (max: %d) <<==\n',msep,crit_val{it_type});
            % verification temps atteint
            if msep<=crit_val{it_type}
                mse_ok=false;
                fprintf(' ====> LIMITE MSE (CV) ATTEINTE --- + %4.2e%s <====\n',depass,char(37))
            else
                mse_ok=true;
                fprintf(' ====> LIMITE MSE (CV) NON ATTEINTE --- %4.2e%s <====\n',depass,char(37))
            end
            %sauvegarde valeur critere
            enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} msep];
            %trace de l'evolution
            if enrich.aff_evol
                if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                opt_plot.tag='CV_MSE';
                opt_plot.title='MSE (LOO/CV)';
                opt_plot.xlabel='Nombre de points';
                opt_plot.ylabel='MSE (LOO/CV)';
                opt_plot.ech_log=true;
                opt_plot.type='stairs';
                opt_plot.cible=crit_val{it_type};
                if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                aff_evol(nb_pts,msep,opt_plot,id_plotloc);
                num_sub=num_sub+1;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % controle en convergence de reponse et/ou de localisation
            % par rapport aux solutions pr�c�dentes et/ou par rapport �
            % la solution exacte
        case {'CONV_REP','CONV_LOC','CONV_LOC_EX','CONV_REP_EX'}
            %valeur cible
            if isfield(enrich.min_glob,'Z');Z_cible=enrich.min_glob.Z;else Z_cible=[];end
            if isfield(enrich.min_glob,'X');X_cible=enrich.min_glob.X;else Z_cible=[];end
            %recherche du minimum de la fonction approchee
            if ~done_min
                [Zap_min,Xap_min]=rech_min_meta(meta,approx{end},enrich.optim);
                %extraction informations sur le minimum
                infos_min.Zap_min=Zap_min;
                infos_min.Xap_min=Xap_min;
                %donnees minimum completes
                Zap_min=[infos_enrich.min.Zap_min;Zap_min];
                Xap_min=[infos_enrich.min.Xap_min;Xap_min];
                done_min=true;
                fprintf(' >> Minimum sur metamodele: %4.2e\n',Zap_min(end))
                fprintf(' >> Au point: ');
                fprintf('%4.2e ',Xap_min{end});
                fprintf('\n')
                
                %trace de l'evolution
                if enrich.aff_evol
                    if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                    opt_plot.tag='Min_meta';
                    opt_plot.title='Minimum Metamodele';
                    opt_plot.xlabel='Nombre de points';
                    opt_plot.ylabel='Minimum Metamodele';
                    opt_plot.ech_log=false;
                    opt_plot.type='stairs';
                    opt_plot.cible=Z_cible;
                    if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                    aff_evol(nb_pts,Zap_min(end),opt_plot,id_plotloc);
                    num_sub=num_sub+1;
                end
            end
            
            switch criteres{it_type}
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'CONV_REP_EX'
                    Zap_min_new=Zap_min(end);
                    %Calcul du critere
                    if Z_cible~=0
                        conv_rep=abs((Zap_min_new-Z_cible)/Z_cible);
                    else
                        conv_rep=abs(Zap_min_new-Z_cible);
                    end
                    depass=(conv_rep-crit_val{it_type})/crit_val{it_type};
                    % verification convergence
                    if conv_rep<=crit_val{it_type}
                        conv_glob_ex_ok=false;
                        fprintf(' ====> Convergence vers le minimum (REP/EX):')
                        fprintf('%4.2e ',conv_rep);
                        fprintf('(min: %4.2e) --- ',crit_val{it_type});
                        fprintf('+ %4.2e%s <====\n',depass,char(37))
                    else
                        conv_glob_ex_ok=true;
                        fprintf(' ====> Convergence vers le minimum (REP/EX) OK: ')
                        fprintf('%4.2e ',conv_rep)
                        fprintf('(min: %4.2e) --- ',crit_val{it_type})
                        fprintf('%4.2e%s <====\n',depass,char(37));
                    end
                    %sauvegarde valeur critere
                    enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_rep];
                    %reinitialisation flag min executee
                    if ~done_min;done_min=~done_min;end
                    %trace de l'evolution
                    if enrich.aff_evol
                        if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                        opt_plot.tag='CONV_REP_EX';
                        opt_plot.title='Critere conv. Minimum/exacte';
                        opt_plot.xlabel='Nombre de points';
                        opt_plot.ylabel='CONV REP EX';
                        opt_plot.ech_log=true;
                        opt_plot.type='stairs';
                        opt_plot.cible=crit_val{it_type};
                        if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                        aff_evol(nb_pts,conv_rep,opt_plot,id_plotloc);
                        num_sub=num_sub+1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'CONV_LOC_EX'
                    fprintf(' (cible: [ ');
                    fprintf('%4.2e ',X_cible);
                    fprintf('])\n')
                    Xap_min_new=Xap_min{end};
                    %distance au vrai minimum
                    ec=(Xap_min_new-X_cible).^2;
                    dist=sum(ec(:));
                    if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                    opt_plot.tag='dist_min';
                    opt_plot.title='Ecart minimum reel/metamodele';
                    opt_plot.xlabel='Nombre de points';
                    opt_plot.ylabel='Ecart minimum reel/metamodele';
                    opt_plot.ech_log=true;
                    opt_plot.type='stairs';
                    opt_plot.cible=10^-7;
                    if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                    aff_evol(nb_pts,dist,opt_plot,id_plotloc);
                    num_sub=num_sub+1;
                    %Calcul du critere
                    conv_loc=dist;
                    depass=(conv_loc-crit_val{it_type})/crit_val{it_type};
                    % verification convergence
                    if conv_loc<=crit_val{it_type}
                        conv_loc_ex_ok=false;
                        fprintf(' ====> Convergence vers le minimum (LOC/EX): %4.2e (cible: %4.2e) --- + %4.2e%s <====\n',conv_loc,crit_val{it_type},depass,char(37))
                    else
                        conv_loc_ex_ok=true;
                        fprintf(' ====> Convergence vers le minimum (LOC/EX) OK: %4.2e (cible: %4.2e) --- %4.2e%s <====\n',conv_loc,crit_val{it_type},depass,char(37))
                    end
                    %sauvegarde valeur critere
                    enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_loc];
                    %reinitialisation flag min executee
                    if ~done_min;done_min=~done_min;end
                    %trace de l'evolution
                    if enrich.aff_evol
                        if iteration_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                        opt_plot.tag='CONV_LOC_EX';
                        opt_plot.title='Critere conv. Localisation/exacte';
                        opt_plot.xlabel='Nombre de points';
                        opt_plot.ylabel='CONV LOC EX';
                        opt_plot.ech_log=true;
                        opt_plot.type='stairs';
                        opt_plot.cible=crit_val{it_type};
                        if iteration_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                        aff_evol(nb_pts,conv_loc,opt_plot,id_plotloc);
                        num_sub=num_sub+1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'CONV_REP'
                    if iteration_enrich>1
                        %ecart au minimum precedent en reponse
                        ec=abs(Zap_min(end)-Zap_min(end-1));
                        conv_loc=ec;
                        depass=abs(conv_loc-crit_val{it_type})/crit_val{it_type};
                        % verification convergence
                        if conv_loc<=crit_val{it_type}
                            conv_rep_ok=false;
                            fprintf(' ====> Convergence vers le minimum (REP): %4.2e (cible: %4.2e) --- + %4.2e%s <====\n',conv_loc,crit_val{it_type},depass,char(37))
                        else
                            conv_rep_ok=true;
                            fprintf(' ====> Convergence vers le minimum (REP) OK: %4.2e (cible: %4.2e) --- %4.2e%s <====\n',conv_loc,crit_val{it_type},depass,char(37))
                        end
                        %sauvegarde valeur critere
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_loc];
                        %reinitialisation flag min executee
                        if ~done_min;done_min=~done_min;end
                        %trace de l'evolution
                        if enrich.aff_evol
                            if iteration_enrich==2;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                            opt_plot.tag='CONV_REP';
                            opt_plot.title='Critere conv. Minimum (hist)';
                            opt_plot.xlabel='Nombre de points';
                            opt_plot.ylabel='CONV REP';
                            opt_plot.ech_log=true;
                            opt_plot.type='stairs';
                            opt_plot.cible=crit_val{it_type};
                            if iteration_enrich==2;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                            aff_evol(nb_pts,conv_loc,opt_plot,id_plotloc);
                            num_sub=num_sub+1;
                        end
                    else
                        fprintf(' >> Critere CONV_REP non actif a la 1ere iteration\n');
                        conv_rep_ok=true;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'CONV_LOC'
                    if iteration_enrich>1
                        %ecart au minimum precedent
                        ec=(Xap_min{end}-Xap_min{end-1}).^2;
                        dist=sum(ec(:));
                        conv_loc=dist;
                        depass=abs(conv_loc-crit_val{it_type})/crit_val{it_type};
                        % verification convergence
                        if conv_loc<=crit_val{it_type}
                            conv_loc_ok=false;
                            fprintf(' ====> Convergence vers le minimum (LOC): %4.2e (cible: %4.2e) --- + %4.2e%s <====\n',conv_loc,crit_val{it_type},depass,char(37))
                        else
                            conv_loc_ok=true;
                            fprintf(' ====> Convergence vers le minimum (LOC) OK: %4.2e (cible: %4.2e) --- %4.2e%s <====\n',conv_loc,crit_val{it_type},depass,char(37))
                        end
                        %sauvegarde valeur critere
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_loc];
                        %reinitialisation flag min executee
                        if ~done_min;done_min=~done_min;end
                        %trace de l'evolution
                        if enrich.aff_evol
                            if iteration_enrich==iter_actif;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);else id_sub=[];end
                                opt_plot.tag='CONV_LOC';
                                opt_plot.title='Critere conv. Localisation (hist)';
                                opt_plot.xlabel='Nombre de points';
                                opt_plot.ylabel='CONV LOC';
                                opt_plot.ech_log=true;
                                opt_plot.type='stairs';
                                opt_plot.cible=crit_val{it_type};
                                if iteration_enrich==iter_actif;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                                aff_evol(nb_pts,con_loc,opt_plot,id_plotloc);
                                num_sub=num_sub+1;                           
                        end
                    else
                        fprintf(' >> Critere CONV_LOC non actif a la 1ere iteration\n');
                        conv_loc_ok=true;
                    end
            end
            fprintf('\n')
        otherwise
            fprintf('_______________________________\n')
            fprintf('>>>> Pas d''enrichissement <<<<\n')
            mse_ok=false;pts_ok=false;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%test: si un des criteres est atteint si c'est pas le cas alors on genere
%un nouveau point de calcul
crit_atteint=conv_glob_ex_ok&&conv_rep_ok&&conv_loc_ok&&...
    conv_loc_ex_ok&&mse_ok&&pts_ok...
    &&hist_r2_ok&&hist_q3_ok&&conv_r2_ok&&conv_q3_ok;
crit_atteint=~crit_atteint;
end


