%% Procédure assurant l'enrichissement du métamodèle
%% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function [approx,enrich,in]=enrich_meta(tirages,doe,meta,enrich)

%% initialisation des quantité
new_tirages=tirages;
%evaluations de la fonction aux points
[new_eval,new_grad]=gene_eval(doe.fct,new_tirages,'eval');

%construction initiale du métamodèle
[approx]=const_meta(new_tirages,new_eval,new_grad,meta);
crit_atteint=false;
pts_ok=true;
mse_ok=true;
conv_loc_ok=true;
conv_glob_ok=true;
done_min=false;
old_tirages=[];
old_eval=[];
old_grad=[];

enrich.ev_crit=cell(length(enrich.crit_type),1);
%suivant le critere d'enrichissement (critere multiple)
%critere TPS_CPU prioritaire si spécifié

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

fprintf('\n >>><<< Enrichissement >>><<<\n')
%tant que le critère retenu n'est pas atteint
while ~crit_atteint&&enrich.on
    %basculement des anciens résultats
    old_tirages=[old_tirages;new_tirages];
    old_eval=[old_eval;new_eval];
    old_grad=[old_grad;new_grad];
    new_tirages=[];new_eval=[];new_grad=[];
    
    
    
    %parcours des types d'enrichissement
    for  it_type=1:length(type)
        if it_type==1
            done_min=false;
        end
        switch type{it_type}
            % controle en nombre de points
            case 'NB_PTS'
                fprintf(' >> Vérification nombre de points echantillons <<\n ')
                % Extraction temps CPU
                tir=old_tirages;
                nb_pts=size(tir,1);
                depass=(nb_pts-crit{it_type})/crit{it_type};
                % vérification temps atteint
                if nb_pts>=crit{it_type}
                    pts_ok=false;
                    fprintf(' ====> Nb maxi de points ATTEINT: %d (max: %d) --- + %4.2e%s <====\n',nb_pts,crit{it_type},depass*100,char(37))
                else
                    pts_ok=true;
                    fprintf(' ====> Nb maxi de points OK: %d (max: %d) --- %4.2e%s <====\n',nb_pts,crit{it_type},depass*100,char(37))
                end
                
                %sauvegarde valeur critère
                enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} nb_pts];
                
                % controle en MSE (CV)
            case 'CV_MSE'
                % Extraction MSE (CV)
                msep=approx.cv.eloot;
                depass=(msep-crit{it_type})/crit{it_type};
                % vérification temps atteint
                if msep<=crit{it_type}
                    mse_ok=false;
                    fprintf(' ====> MSE (CV) ATTEINTE: %4.2e (max: %4.2e) --- + %4.2e%s <====\n',msep,crit{it_type},depass,char(37))
                else
                    mse_ok=true;
                    fprintf(' ====> MSE (CV) OK: %4.2e (max: %4.2e) --- %4.2e%s <====\n',msep,crit{it_type},depass,char(37))
                end
                %sauvegarde valeur critère
                enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} msep];
                % controle en convergence de réponse et/ou de localisation
            case {'CONV_REP','CONV_LOC'}
                %valeur cible
                Z_cible=enrich.min_glob.Z;
                X_cible=enrich.min_glob.X;
                %recherche du minimum de la fonction approchée
                if ~done_min
                    [Zap_min,X_min]=rech_min_meta(meta,approx,enrich.optim);
                    fprintf(' >> Minimum sur metamodele: %4.2e (cible: %4.2e )\n',Zap_min,Z_cible)
                    fprintf(' >> Au point: ');
                    fprintf('%4.2e ',X_min);
                    fprintf(' (cible: [ ');
                    fprintf('%4.2e ',X_cible);
                    fprintf('])\n')                   
                end
                
                switch type{it_type}
                    case 'CONV_REP'
                        %Calcul du critère
                        if Z_cible~=0
                            conv_rep=abs((Zap_min-Z_cible)/Z_cible);
                        else
                            conv_rep=abs(Zap_min-Z_cible);
                        end
                        depass=(conv_rep-crit{it_type})/crit{it_type};
                        % vérification convergence
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
                        %sauvegarde valeur critère
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_rep];
                        %reinitialisation flag min executee
                        if ~done_min;done_min=~done_min;end
                    case 'CONV_LOC'
                        %Calcul du critère
                        ec=(X_min-X_cible).^2;
                        dist=sum(ec(:));
                        conv_loc=dist;
                        depass=(conv_loc-crit{it_type})/crit{it_type};
                        % vérification convergence
                        if conv_loc<=crit{it_type}
                            conv_loc_ok=false;
                            fprintf(' ====> Convergence vers le minimum (LOC): %4.2e (cible: %4.2e) --- + %4.2e%s <====\n',conv_loc,crit{it_type},depass,char(37))
                        else
                            conv_loc_ok=true;
                            fprintf(' ====> Convergence vers le minimum (LOC) OK: %4.2e (cible: %4.2e) --- %4.2e%s <====\n',conv_loc,crit{it_type},depass,char(37))
                        end
                        %sauvegarde valeur critère
                        enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} conv_loc];
                        %reinitialisation flag min executee
                        if ~done_min;done_min=~done_min;end
                end
            otherwise
                fprintf('_______________________________\n')
                fprintf('>>>> Pas d''enrichissement <<<<\n')
                mse_ok=false;pts_ok=false;
        end
    end
    
    %test: si un des crtières est atteint si c'est pas le cas alors on génère
    %un nouveau point de calcul
    crit_atteint=conv_glob_ok&&conv_loc_ok&&mse_ok&&pts_ok;crit_atteint=~crit_atteint;
    
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
                fprintf(' >> Mode d''enrichissement non défini <<\n');
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
    
    
    
    %calcul des grandeurs en ce nouveau point et génération du nouveaux
    %metamodele
    if ~isempty(new_tirages)
        [new_eval,new_grad]=gene_eval(doe.fct,new_tirages,'eval');
        
        %stockage debug
        debug.old_tirages=old_tirages;
        debug.new_tirages=new_tirages;
        debug.old_eval=old_eval;
        debug.new_eval=new_eval;
        debug.old_grad=old_grad;
        debug.new_grad=new_grad;
        debug.approx=approx;
        global debug
        %construction du métamodèle
        [approx]=const_meta([old_tirages;new_tirages],[old_eval;new_eval],[old_grad;new_grad],meta);
    end
    
end


%Extraction des grandeurs ajoutés
in.tirages=old_tirages;
in.eval=old_eval;
in.grad=old_grad;