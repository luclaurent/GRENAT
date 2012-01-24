%% Procédure assurant l'enrichissement du métamodèle
%% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function [approx,enrich]=enrich_meta(tirages,doe,meta,enrich)

%% initialisation des quantité
new_tirages=tirages;
%evaluations de la fonction aux points
[new_eval,new_grad]=gene_eval(doe.fct,new_tirages,'eval');

%construction initiale du métamodèle
[approx]=const_meta(new_tirages,new_eval,new_grad,meta);

crit_atteint=false;
pts_ok=true;
mse_ok=true;
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
                    fprintf(' ====> Nb maxi de points ATTEINT: %d (max: %d) --- + %4.2f%s <====\n',nb_pts,crit{it_type},depass,char(37))
                else
                    pts_ok=true;
                    fprintf(' ====> Nb maxi de points OK: %d (max: %d) --- %4.2f%s <====\n',nb_pts,crit{it_type},depass,char(37))
                end
                
                %sauvegarde valeur critère
                enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} nb_pts];
                
                % controle en MSE (CV)
            case 'CV_MSE'
                % Extraction MSE (CV)
                msep=approx.cv.msep;
                depass=(msep-crit{it_type})/crit{it_type};
                % vérification temps atteint
                if msep<=crit{it_type}
                    mse_ok=false;
                    fprintf(' ====> MSE (CV) ATTEINTE: %0.7f (max: %0.7f) --- + %4.2f%s <====\n',msep,crit{it_type},depass,char(37))
                else
                    mse_ok=true;
                    fprintf(' ====> Nb maxi de points OK: %0.7f (max: %0.7f) --- %4.2f%s <====\n',msep,crit{it_type},depass,char(37))
                end
                
                %sauvegarde valeur critère
                enrich.ev_crit{it_type}=[enrich.ev_crit{it_type} msep];
            otherwise
                fprintf('_______________________________\n')
                fprintf('>>>> Pas d''enrichissement <<<<\n')
                mse_ok=false;pts_ok=false;
        end
    end
    
    %test: si un des crtières est atteint si c'est pas le cas alors on génère
    %un nouveau point de calcul
    crit_atteint=mse_ok&&pts_ok;crit_atteint=~crit_atteint;
    
    if ~crit_atteint
        %en fonction du type d'enrichissement
        switch enrich.type
            % en se basant sur l'Expected Improvement
            case {'EI_KRG','VAR_KRG'}
                new_tirages=ajout_tir_meta(old_tirages,old_eval,old_grad,old_meta,approx,enrich);
                %en ajoutant des points dans le tirages
            case {'DOE'}
                new_tirages=ajout_tir_doe(doe,old_tirages);
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
        %construction du métamodèle
        [approx]=const_meta([old_tirages;new_tirages],[old_eval;new_eval],[old_grad;new_grad],meta);
    end
    
end