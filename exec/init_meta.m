%% Initialisation du metamodele
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function meta=init_meta(in)

fprintf('=========================================\n')
fprintf('     >>> INITIALISATION META <<<\n');
[tMesu,tInit]=mesu_time;

%%%configuration par defaut
%prise en compte des gradients
meta.grad=false;
%type de metamodele
meta.type='KRG';
%longueur de correlation
meta.para.l_val=1;
%parametre puissance 
meta.para.p_val=2;
%normalisation
meta.norm=true;
%amelioration du conditionnement de la matrice de correlation
meta.recond=false;
%validation croisee
meta.cv=true;
%calcul tous criteres CV
meta.cv_full=false;
%affichage QQ plot CV
meta.cv_aff=false;


%%%options specifiques
%parametre SWF
swf_para=1;
%degre regression krigeage
deg=0;
%fonction de correlation
corr='corr_sexp';
rbf='rf_sexp';


%%estimation parametre long (longueur de correlation)
% recherche de la longueur de correlation
meta.para.estim=true;
%prise en compte de l'anisotropie (longueur de correlation suivant chaque dimension)
meta.para.aniso=true;
%affichage de la fonctionnelle a miniser pour obtenir le "meilleur" jeu de parametres
meta.para.aff_estim=false;
%affichage iteration estimation parametres sur un graph (1D/2D)
meta.para.aff_iter_graph=false;
%affichage iteration dans la console
meta.para.aff_iter_cmd=false;
%affichage informations convergence algo dans des plots
meta.para.aff_plot_algo=false;
% methode de minimisation de la log-vraisemblance
meta.para.method='tir_min_fmincon';
%strategie tirage population initiale algo GA '', 'LHS','IHS'...
meta.para.popManu='IHS';
%population initiale algo GA
meta.para.nbPopInit=[];
%critere arret algo optimisation
meta.para.crit_opti=10^-4;
%bornes esapce recherche parametres
if meta.para.estim
    meta.para.l_min=1e-4;
    meta.para.l_max=50;
    meta.para.p_max=2;
    meta.para.p_min=1.001;
end

%enrichissement (evaluation critere)
meta.enrich.on=false;
meta.enrich.para_wei=0.5;
meta.enrich.para_gei=1;
meta.enrich.para_lcb=0.5;

%Verification interpolation
meta.verif=true;

%sauvegarde des 


%% chargement configuration particuliere
if nargin==1
    %prise en compte des gradients
    if isfield(in,'grad');meta.grad=in.grad;end
    %type de metamodele KRG/CKRG/DACE/RBF/GRBF
    if isfield(in,'type');meta.type=in.type;end
    %parametre fonction RBF/KRG
    if isfield(in,'long');meta.para.l_val=in.long(1);end
    if meta.para.estim
        if isfield(in,'long');
            meta.para.l_max=in.long(2);
            meta.para.l_min=in.long(1);
        end
    end
    if isfield(in,'pow');meta.para.p_val=in.pow(1);end
    if meta.para.estim
        if isfield(in,'pow');
            meta.para.p_max=in.pow(2);
            meta.para.p_max=in.pow(1);
        end
    end
    
    %en fonction du type de metamodele
    switch meta.type
        case 'SWF'
            if isfield(in,'swf_para');meta.swf_para=in.swf_para;else meta.swf_para=swf_para;end
        case 'DACE'
                fctp='regpoly';
                %fonction de regression
                if isfield(in,'deg');meta.regr=[fctp num2str(in.deg,'%d')];else meta.regr=[fctp num2str(deg,'%d')];end
                %fonction de correlation
                if isfield(in,'corr');meta.corr=['corr' in.corr];else meta.corr=['corr' corr];end
        case {'RBF','GRBF','InRBF'}
            if isfield(in,'rbf');meta.rbf=['rf_' in.rbf];else meta.rbf=rbf;end
        case {'KRG','CKRG','InKRG'}
            %degre de la regression
            if isfield(in,'deg');meta.deg=in.deg;else meta.deg=deg;end
            %fonction de correlation
            if isfield(in,'corr');meta.corr=['corr_' in.corr];else meta.corr=['corr_' in.corr];end
            
        otherwise
    end
    %normalisation
    if isfield(in,'norm');meta.norm=in.norm;end
    %amelioration du conditionnement de la matrice de correlation
    if isfield(in,'recond');meta.recond=in.recond;end
    %validation croisee
    if isfield(in,'cv');meta.cv=in.cv;end
    %calcul tous criteres CV
    if isfield(in,'cv_full');meta.cv_full=in.cv_full;end
    %affichage QQ plot CV
    if isfield(in,'cv_aff');meta.cv_aff=in.cv_aff;end
    
    
    %%estimation parametre long (longueur de correlation)
    if isfield(in,'para');
        % recherche de la longueur de correlation
        if isfield(in.para,'estim');meta.para.estim=in.para.estim;end
        %prise en compte de l'anisotropie (longueur de correlation suivant chaque dimension)
        if isfield(in.para,'aniso');meta.para.aniso=in.para.aniso;end
        %affichage de la fonctionnelle a miniser pour obtenir le "meilleur" jeu de parametres
        if isfield(in.para,'aff_estim');meta.para.aff_estim=in.para.aff_estim;end
        %affichage iteration estimation parametres sur un graph (1D/2D)
        if isfield(in.para,'aff_iter_graph');meta.para.aff_iter_graph=in.para.aff_iter_graph;end
        %affichage iteration dans la console
        if isfield(in.para,'aff_iter_cmd');meta.para.aff_iter_cmd=in.para.aff_iter_cmd;end
        % methode de minimisation de la log-vraisemblance
        if isfield(in.para,'method');meta.para.method=in.para.method;end
        %strategie tirage population initiale algo GA '', 'LHS','IHS'...
        if isfield(in.para,'popManu');meta.para.popManu=in.para.popManu;end
        %population initiale algo GA
        if isfield(in.para,'norpopInitm');meta.para.popInit=in.para.popInit;end
        %critere arret algo optimisation
        if isfield(in.para,'crit_opti');meta.para.crit_opti=in.para.crit_opti;end
        if meta.para.estim
            if isfield(in.para,'long');
                meta.para.l_max=in.para.long(2);
                meta.para.l_min=in.para.long(1);
            end
        end
    end
    %enrichissement (evaluation critere)
    if isfield(in,'enrich');
        if isfield(in.enrich,'on');meta.enrich.on=in.enrich.on;end
        if isfield(in.enrich,'para_wei');meta.enrich.para_wei=in.enrich.para_wei;end
        if isfield(in.enrich,'para_gei');meta.enrich.para_gei=in.enrich.para_gei;end
        if isfield(in.enrich,'para_lcb');meta.enrich.para_lcb=in.enrich.para_lcb;end
        
        %Verification interpolation
        if isfield(in,'verif');meta.verif=in.verif;end
    end
end

%comptage du nombre de workers disponibles (pour parallelisme)
meta.worker_parallel=matlabpool('size');

mesu_time(tMesu,tInit);
fprintf('=========================================\n')