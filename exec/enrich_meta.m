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
old_tirages=[];
old_eval=[];
old_grad=[];
info_enrich.min.Xap_min=[];
info_enrich.min.Zap_min=[];

%grille de verification
nb_pts_verif=3000;
type_tir_verif='LHS';
dd.type=type_tir_verif;
dd.nb_samples=nb_pts_verif;
dd.Xmin=doe.Xmin;
dd.Xmax=doe.Xmax;
dd.aff=false;
ref.grille_verif=gene_doe(dd);
ref.Zref=[];

%si verification par rapport a la fonction reele
if any(strcmp(enrich.crit_type,'CONV_R2_EX'))||any(strcmp(enrich.crit_type,'CONV_Q3_EX'))
    ref.Zref=gene_eval(doe.fct,ref.grille_verif,'eval');
end

global debug

info_enrich.ev_crit=cell(length(enrich.crit_type),1);
%suivant le critere d'enrichissement (critere multiple)
%critere TPS_CPU prioritaire si specifie


%specification affichage subplot
if enrich.aff_evol
    figure('Name','Criteres META')
    num_fig=0;
    %nombre de figures
    aff_subplot.num_fig=num_fig_meta(enrich.crit_type,num_fig);
    %parametres affichage subplot
    aff_subplot.nb_lign=2;
    aff_subplot.nb_col=floor(aff_subplot.num_fig/aff_subplot.nb_lign)+1;
    aff_subplot.id_sub=[];
else
    aff_subplot=[];
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
    info_enrich.iter=it_enrich;
    info_enrich.minZex=min(old_eval);
    info_enrich.maxZex=max(old_eval);
    fprintf('#########################################\n')
    fprintf('########### Iteration n: %i ############\n',it_enrich)
    fprintf('-----------------------------------------\n');
    
    %parcours des types d'enrichissement
    [crit_atteint,id_sub,det_enrich]=verif_crit_meta(enrich,meta,info_enrich,ref,approx,aff_subplot,old_tirages);
    %regroupement infos
    info_enrich.min.Xap_min=[info_enrich.min.Xap_min;det_enrich.min.Xap_min];
    info_enrich.min.Zap_min=[info_enrich.min.Zap_min;det_enrich.min.Zap_min];
    if ~isempty(aff_subplot);aff_subplot.id_sub=id_sub;end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %test: si un des criteres est atteint si c'est pas le cas alors on genere
    %un nouveau point de calcul  
    if ~crit_atteint
        %en fonction du type d'enrichissement
        switch enrich.type
            % en se basant sur l'Expected Improvement
            case {'EI','GEI','VAR','WEI','LCB'}
                fprintf(' \n>> Enrichissement par metamodele, critere: %s\n',enrich.type)
%                 [new_tirages,info_ajout]=ajout_tir_meta(meta,approx{end},enrich);
                info_enrich.valCRIT=info_ajout.fval;
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
        debug.approx=approx{end};
        
        %construction du metamodele
        [approx{it_enrich+1}]=const_meta([old_tirages;new_tirages],[old_eval;new_eval],[old_grad;new_grad],meta);
    end
    
end


%Extraction des grandeurs ajout�s
in.tirages=old_tirages;
in.eval=old_eval;
in.grad=old_grad;

mesu_time(tMesu,tInit);
fprintf('#########################################\n');