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
info_enrich.min.Vap_max=[];
info_enrich.min.XVap_max=[];

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

%on verifie que les criteres choisis seront bien exploitables
enrich=tri_crit(enrich);

info_enrich.ev_crit=cell(length(enrich.crit_type),1);

%specification affichage subplot
if enrich.aff_evol
    figure('Name','Criteres META & Cofast')
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
    info_enrich.min.XVap_max=[info_enrich.min.XVap_max;det_enrich.min.XVap_max];
    info_enrich.min.Vap_max=[info_enrich.min.Vap_max;det_enrich.min.Vap_max];
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
                [new_tirages,info_ajout]=ajout_tir_meta(meta,approx{end},enrich);
                info_enrich.valCRIT=info_ajout.out_algo.fval;
                approx{end}.enrich.algo=info_ajout.out_algo;
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

end


%fonction de tri des criteres
function ret=tri_crit(enrich)
%methode enrichissement
meth_enrich=enrich.type;

%criteres choisis
choix_crit=enrich.crit_type;

%liste criteres
liste_crit={'CONV_VAR';'CONV_VARR';'CONV_LCB';...   %3
    'CONV_LCBR';'CONV_WEI';'CONV_WEIR';...          %6
    'CONV_EIRb';'CONV_GEIR';'CONV_GEI';...          %9
    'CONV_EI';'CONV_EIR';'HIST_R2';...              %12
    'HIST_Q3';'CONV_R2_EX';'CONV_Q3_EX';...         %15
    'NB_PTS';'CV_MSE';'CONV_REP_EX';...             %18
    'CONV_LOC_EX';'CONV_REP';'CONV_LOC';...         %21
    'CONV_WEIRb';'CONV_GEIRb';'CONV_EIRn';...       %24
    'CONV_WEIRn';'CONV_GEIRn'};                     %26
%on cree un masque des criteres de convergence inapplicables
switch meth_enrich
    case 'DOE'
        masque_bad={liste_crit{1:end}};
    case 'VAR'
        masque_bad={liste_crit{[3:11 22:end]}};
    case 'LCB'
        masque_bad={liste_crit{[1 2 5:11 19:end]}};
    case 'EI'
        masque_bad={liste_crit{[1:6 8:9 22 23 25 26]}};
    case 'GEI'
        masque_bad={liste_crit{[1:7 10 11 22 24:end]}};
    case 'WEI'
        masque_bad={liste_crit{[1:4 7:10 23 24 26]}};
end
%on recherche les criteres a retirer si present
iter_retir=[];
for iter_masq=1:numel(masque_bad)
    [~,IX]=find(strcmp(choix_crit,masque_bad{iter_masq}));
    iter_retir=[iter_retir,IX];
end
crit_type=enrich.crit_type;
val_crit=enrich.val_crit;
if ~isempty(iter_retir)
    fprintf('Les criteres ');
    fprintf('%s ',crit_type{iter_retir});
    fprintf('ne sont plus operationnels\n');
    crit_type(iter_retir)=[];
    val_crit(iter_retir)=[];
end
ret=enrich;
ret.crit_type=crit_type;
ret.val_type=val_crit;
end