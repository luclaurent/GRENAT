%% Procedure assurant l'enrichissement du metamodele
%% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function [approx,enrich,in]=enrich_meta(tirages,doe,meta,enrich)

[tMesu,tInit]=mesu_time;

%% initialisation des quantite
new_tirages=tirages;
%evaluations de la fonction aux points
[new_eval,new_grad]=gene_eval(doe.fct,new_tirages,'eval');

%construction initiale du metamodele
[approx{1}]=const_meta(new_tirages,new_eval,new_grad,meta);
crit_atteint=false;
pts_ok=true;
mse_ok=true;
conv_loc_ok=true;
conv_glob_ok=true;
done_min=false;
old_tirages=[];
old_eval=[];
old_grad=[];

%grille de vérification
nb_pts_verif=3000;
type_tir_verif='IHS';
dd.type=type_tir_verif;
dd.nb_samples=nb_pts_verif;
dd.Xmin=doe.Xmin;
dd.Xmax=doe.Xmax;
grille_verif=gene_doe(dd);

%critere historique sur N metamodèles
nb_hist=4;

global debug

enrich.ev_crit=cell(length(enrich.crit_type),1);
%suivant le critere d'enrichissement (critere multiple)
%critere TPS_CPU prioritaire si specifie

%correction rangement type
if ~iscell(enrich.crit_type)
    type={enrich.crit_type};
else
    type=enrich.crit_type;
end

%correction rangement critere
if ~iscell(enrich.val_crit)
    crit={enrich.val_crit};
else
    crit=enrich.val_crit;
end

%numero iteration enrichissement
it_enrich=0;

fprintf('\n >>><<< Enrichissement >>><<<\n')
%tant que le critere retenu n'est pas atteint
while ~crit_atteint&&enrich.on
    %basculement des anciens resultats
    old_tirages=[old_tirages;new_tirages];
    old_eval=[old_eval;new_eval];
    old_grad=[old_grad;new_grad];
    new_tirages=[];new_eval=[];new_grad=[];
    %increment numero iteration
    it_enrich=it_enrich+1;
    num_sub=1;
    fprintf('####################################\n')
    fprintf('######### Iteration n°: %i ##########\n',it_enrich)
    fprintf('------------------------------------\n');
    if enrich.aff_evol&&it_enrich==1
        figure
        num_fig=0;
        for  it_type=1:length(type)
            switch type{it_type}
                case {'NB_PTS','HIST_R2','HIST_Q3','CV_MSE'}
                    num_fig=num_fig+1;
                case {'CONV_REP','CONV_LOC'}
                    num_fig=num_fig+2;
            end
        end
        nb_lign=2;
        nb_col=floor(num_fig/nb_lign)+1;
        opt_plot.bornes=[1 30];
    end
    
    %parcours des types d'enrichissement
    for  it_type=1:length(type)
        if it_type==1
            done_min=false;
        end
        switch type{it_type}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % controle amélioration (par rapport aux 4 métamodèles
            % précédents)
            case {'HIST_R2','HIST_Q3'}
                if it_enrich>1
                    fprintf(' >> Calcul criteres HIST_Q3 et HIST_R2 <<\n ');
                    if it_enrich<nb_hist-1
                        fprintf(' /!\ Historique trop faible donc pas de test HIST_R2 ni HIST_Q3 <<\n ');
                    end
                    %evaluation dernier metamodele
                    Z_end=eval_meta(grille_verif,approx{end},meta);
                    % evaluation des precedents metamodeles
                    nbmeta=min(it_enrich,nb_hist+1);
                    for it_hist=1:nb_hist+1
                        Z=eval_meta(grille_verif,approx{end-it_hist},meta);
                        [~,~,vR2(it_hist),~]=fact_corr(Zref,Zap);
                        [~,~,vQ3(it_hist)]=qual(Zref,Zap);
                    end
                    switch type{it_type}
                        case 'HIST_R2'
                            %moyenne R2
                            mR2=mean(vR2);
                            %sauvegarde valeur critere
                            enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} mR2];
                            if it_enrich>=nb_hist-1
                                depass=(mR2-crit{it_type})/crit{it_type};
                                %affichage info
                                fprintf(' ==>> R2 (Hist %i) atteint: %d (max: %d) <<==\n',nb_hist,mR2,crit{it_type});
                                % verification temps atteint
                                if mR2>=crit{it_type}
                                    hist_r2_ok=false;
                                    fprintf(' ====> LIMITE R2 (Hist %i) ATTEINTE --- + %4.2e%s <====\n',nb_hist,depass*100,char(37))
                                else
                                    hist_r2_ok=true;
                                    fprintf(' ====> LIMITE R2 (Hist %i) NON ATTEINTE --- %4.2e%s <====\n',depass*100,char(37))
                                end
                            else
                                hist_r2_ok=true;
                            end
                            %trace de l'evolution
                            if enrich.aff_evol
                                if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                                opt_plot.tag='HIST_R2';
                                opt_plot.title='Evol. nombre de points';
                                opt_plot.xlabel='Nombre de points';
                                opt_plot.ylabel='HIST_R2';
                                opt_plot.ech_log=false;
                                opt_plot.type='stairs';
                                opt_plot.cible=crit{it_type};
                                if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                                aff_evol(nb_pts,mR2,opt_plot,id_plotloc);
                                num_sub=num_sub+1;
                            end
                        case 'HIST_Q3'
                            %moyenne Q3
                            mQ3=mean(vQ3);
                            %sauvegarde valeur critere
                            enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} mQ3];
                            if it_enrich>=nb_hist-1
                                depass=(mQ3-crit{it_type})/crit{it_type};
                                %affichage info
                                fprintf(' ==>> Q3 (Hist %i) atteint: %d (max: %d) <<==\n',nb_hist,mQ3,crit{it_type});
                                % verification temps atteint
                                if mQ3<=crit{it_type}
                                    hist_q3_ok=false;
                                    fprintf(' ====> LIMITE Q3 (Hist %i) ATTEINTE --- + %4.2e%s <====\n',depass*100,char(37))
                                else
                                    hist_q3_ok=true;
                                    fprintf(' ====> LIMITE Q3 (Hist %i) NON ATTEINTE --- %4.2e%s <====\n',depass*100,char(37))
                                end
                            else
                                hist_q3_ok=true;
                            end
                            %trace de l'evolution
                            if enrich.aff_evol
                                if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                                opt_plot.tag='HIST_Q3';
                                opt_plot.title='Evol. nombre de points';
                                opt_plot.xlabel='Nombre de points';
                                opt_plot.ylabel='HIST_Q3';
                                opt_plot.ech_log=false;
                                opt_plot.type='stairs';
                                opt_plot.cible=crit{it_type};
                                if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                                aff_evol(nb_pts,mQ3,opt_plot,id_plotloc);
                                num_sub=num_sub+1;
                            end
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
                depass=(nb_pts-crit{it_type})/crit{it_type};
                %affichage info
                fprintf(' ==>> Nombre de points atteint: %d (max: %d) <<==\n',nb_pts,crit{it_type});
                % verification temps atteint
                if nb_pts>=crit{it_type}
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
                    if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                    opt_plot.tag='NB_PTS';
                    opt_plot.title='Evol. nombre de points';
                    opt_plot.xlabel='Nombre de points';
                    opt_plot.ylabel='Nombre de points';
                    opt_plot.ech_log=false;
                    opt_plot.type='stairs';
                    opt_plot.cible=crit{it_type};
                    if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                    aff_evol(nb_pts,nb_pts,opt_plot,id_plotloc);
                    num_sub=num_sub+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % controle en MSE (CV)
            case 'CV_MSE'
                % Extraction MSE (CV)
                msep=approx.cv.eloot;
                depass=(msep-crit{it_type})/crit{it_type};
                %affichage info
                fprintf(' ==>> MSE (CV) atteint: %d (max: %d) <<==\n',msep,crit{it_type});
                % verification temps atteint
                if msep<=crit{it_type}
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
                    if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                    opt_plot.tag='CV_MSE';
                    opt_plot.title='MSE (LOO/CV)';
                    opt_plot.xlabel='Nombre de points';
                    opt_plot.ylabel='MSE (LOO/CV)';
                    opt_plot.ech_log=true;
                    opt_plot.type='stairs';
                    opt_plot.cible=crit{it_type};
                    if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                    aff_evol(nb_pts,msep,opt_plot,id_plotloc);
                    num_sub=num_sub+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % controle en convergence de reponse et/ou de localisation
            case {'CONV_REP','CONV_LOC'}
                %valeur cible
                Z_cible=enrich.min_glob.Z;
                X_cible=enrich.min_glob.X;
                %recherche du minimum de la fonction approchee
                if ~done_min
                    [Zap_min,X_min]=rech_min_meta(meta,approx,enrich.optim);
                    fprintf(' >> Minimum sur metamodele: %4.2e (cible: %4.2e )\n',Zap_min,Z_cible)
                    fprintf(' >> Au point: ');
                    fprintf('%4.2e ',X_min);
                    fprintf(' (cible: [ ');
                    fprintf('%4.2e ',X_cible);
                    fprintf('])\n')
                    %distance au vrai minimum
                    ec=(X_min-X_cible).^2;
                    dist=sum(ec(:));
                    %trace de l'evolution
                    if enrich.aff_evol
                        if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                        opt_plot.tag='Min_meta';
                        opt_plot.title='Minimum Metamodele';
                        opt_plot.xlabel='Nombre de points';
                        opt_plot.ylabel='Minimum Metamodele';
                        opt_plot.ech_log=false;
                        opt_plot.type='stairs';
                        opt_plot.cible=Z_cible;
                        if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                        aff_evol(nb_pts,Zap_min,opt_plot,id_plotloc);
                        num_sub=num_sub+1;
                        if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                        opt_plot.tag='Min_meta';
                        opt_plot.title='Ecart minimum reel/metamodele';
                        opt_plot.xlabel='Nombre de points';
                        opt_plot.ylabel='Ecart minimum reel/metamodele';
                        opt_plot.ech_log=true;
                        opt_plot.type='stairs';
                        opt_plot.cible=10^-7;
                        if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                        aff_evol(nb_pts,dist,opt_plot,id_plotloc);
                        num_sub=num_sub+1;
                    end
                end
                
                switch type{it_type}
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    case 'CONV_REP'
                        %Calcul du critere
                        if Z_cible~=0
                            conv_rep=abs((Zap_min-Z_cible)/Z_cible);
                        else
                            conv_rep=abs(Zap_min-Z_cible);
                        end
                        depass=(conv_rep-crit{it_type})/crit{it_type};
                        % verification convergence
                        if conv_rep<=crit{it_type}
                            conv_glob_ok=false;
                            fprintf(' ====> Convergence vers le minimum (REP):')
                            fprintf('%4.2e ',conv_rep);
                            fprintf('(min: %4.2e) --- ',crit{it_type});
                            fprintf('+ %4.2e%s <====\n',depass,char(37))
                        else
                            conv_glob_ok=true;
                            fprintf(' ====> Convergence vers le minimum (REP) OK: ')
                            fprintf('%4.2e ',conv_rep)
                            fprintf('(min: %4.2e) --- ',crit{it_type})
                            fprintf('%4.2e%s <====\n',depass,char(37));
                        end
                        %sauvegarde valeur critere
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_rep];
                        %reinitialisation flag min executee
                        if ~done_min;done_min=~done_min;end
                        %trace de l'evolution
                        if enrich.aff_evol
                            if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                            opt_plot.tag='CONV_REP';
                            opt_plot.title='Critere conv. Minimum';
                            opt_plot.xlabel='Nombre de points';
                            opt_plot.ylabel='Critere conv. Minimum';
                            opt_plot.ech_log=true;
                            opt_plot.type='stairs';
                            opt_plot.cible=crit{it_type};
                            if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                            aff_evol(nb_pts,conv_rep,opt_plot,id_plotloc);
                            num_sub=num_sub+1;
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    case 'CONV_LOC'
                        %Calcul du critere
                        conv_loc=dist;
                        depass=(conv_loc-crit{it_type})/crit{it_type};
                        % verification convergence
                        if conv_loc<=crit{it_type}
                            conv_loc_ok=false;
                            fprintf(' ====> Convergence vers le minimum (LOC): %4.2e (cible: %4.2e) --- + %4.2e%s <====\n',conv_loc,crit{it_type},depass,char(37))
                        else
                            conv_loc_ok=true;
                            fprintf(' ====> Convergence vers le minimum (LOC) OK: %4.2e (cible: %4.2e) --- %4.2e%s <====\n',conv_loc,crit{it_type},depass,char(37))
                        end
                        %sauvegarde valeur critere
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_loc];
                        %reinitialisation flag min executee
                        if ~done_min;done_min=~done_min;end
                        %trace de l'evolution
                        if enrich.aff_evol
                            if it_enrich==1;id_sub(num_sub)=subplot(nb_lign,nb_col,num_sub);end
                            opt_plot.tag='CONV_LOC';
                            opt_plot.title='Critere conv. Localisation';
                            opt_plot.xlabel='Nombre de points';
                            opt_plot.ylabel='Critere conv. Localisation';
                            opt_plot.ech_log=true;
                            opt_plot.type='stairs';
                            opt_plot.cible=crit{it_type};
                            if it_enrich==1;id_plotloc=[];else id_plotloc=id_sub(num_sub);end
                            aff_evol(nb_pts,conv_loc,opt_plot,id_plotloc);
                            num_sub=num_sub+1;
                        end
                end
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
    %test: si un des crteres est atteint si c'est pas le cas alors on genere
    %un nouveau point de calcul
    crit_atteint=conv_glob_ok&&conv_loc_ok&&mse_ok&&pts_ok&&hist_r2_ok&&hist_q3_ok;crit_atteint=~crit_atteint;
    
    if ~crit_atteint
        %en fonction du type d'enrichissement
        switch enrich.type
            % en se basant sur l'Expected Improvement
            case {'EI','GEI','VAR','WEI','LCB'}
                fprintf(' >> Enrichissement par metamodele, critere: %s\n',enrich.type)
                new_tirages=ajout_tir_meta(meta,approx,enrich);
                %en ajoutant des points dans le tirages
            case {'DOE'}
                fprintf(' >> Enrichissement du tirage\n')
                new_tirages=ajout_tir_doe(old_tirages);
            otherwise
                fprintf(' >> Mode d''enrichissement non defini <<\n');
        end
        
    else
        new_tirages=[];
        
    end
    
    %Affichage nouveau point
    if isempty(new_tirages)
        fprintf('>>> Pas de nouveaux points <<<\n')
        fprintf('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n')
    else
        fprintf(' >> Nouveau point: ');
        fprintf('%4.2f ',new_tirages);
        fprintf('\n')
    end
    
    
    
    %calcul des grandeurs en ce nouveau point et generation du nouveaux
    %metamodele
    if ~isempty(new_tirages)
        [new_eval,new_grad]=gene_eval(doe.fct,new_tirages,'eval');
        
        %stockage debug
        debug=[];
        debug.old_tirages=old_tirages;
        debug.new_tirages=new_tirages;
        debug.old_eval=old_eval;
        debug.new_eval=new_eval;
        debug.old_grad=old_grad;
        debug.new_grad=new_grad;
        debug.approx=approx;
        
        %construction du metamodele
        [approx{it_enrich+1}]=const_meta([old_tirages;new_tirages],[old_eval;new_eval],[old_grad;new_grad],meta);
    end
    
end


%Extraction des grandeurs ajoutï¿½s
in.tirages=old_tirages;
in.eval=old_eval;
in.grad=old_grad;

mesu_time(tMesu,tInit);
fprintf('#########################################\n');