%% Fonction assurant la creation d'un nouveau point d'echantillonnage basï¿½ sur un metamodele
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr


function [pts,ret_tir_meta]=ajout_tir_meta(meta,approx,enrich)

[tMesu,tInit]=mesu_time;
global doe
%definition des bornes de l'espace de recherche
lb=doe.Xmin;ub=doe.Xmax;
%nombre parametres
nb_para=numel(doe.Xmin);

%%%Definition manuelle de la population initiale par LHS (Ga)
popInitManu=enrich.optim.popManu;
if popInitManu
    nbpopspecif=false;
    if isfield(enrich.optim,'nbPopInit');if ~isempty(enrich.optim.nbPopInit);nbpopspecif=false;end, end
    if nbpopspecif;nbPopInit=enrich.optim.nbPopInit;else nbPopInit=10*nb_para; end
end

%critere arret minimisation
crit_opti=enrich.optim.crit_opti;
meta.enrich.on=true;

%en fonction du type de nouveau point reclame
switch enrich.type
    %Expected Improvement (Krigeage/RBF)
    case 'EI'
        fun=@(point)ret_EI(point,approx,meta);
        %Weighted Expected Improvement (Krigeage/RBF)
    case 'WEI'
        fun=@(point)ret_WEI(point,approx,meta);
        %Generalized Expected Improvement (Krigeage/RBF)
    case 'GEI'
        fun=@(point)ret_GEI(point,approx,meta);
        %Lower Confidence Bound (Krigeage/RBF)
    case 'LCB'
        fun=@(point)ret_LCB(point,approx,meta);
        %Variance (Krigeage/RBF)
    case 'VAR'
        fun=@(point)ret_VAR(point,approx,meta);
end

%Options algo pour chaque fonction de minimisation
%declaration des options de la strategie de minimisation
options_ga = gaoptimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn','',...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'UseParallel','always',...
    'PopInitRange',[lb(:)';ub(:)'],...    %zone de definition de la population initiale
    'PlotFcns','',...
    'TolFun',crit_opti,...
    'StallGenLimit',20);

%{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,@gaplotexpectation,...
%@gaplotmaxconstr,@gaplotrange,@gaplotselection,@gaplotscorediversity,@gaplotscores,@gaplotstopping});

%options algo PSO de la toolbox PSOt
ac      = [2.1,2.1];% acceleration constants, only used for modl=0
Iwt     = [0.9,0.6];  % intertia weights, only used for modl=0
epoch   = 2000; % max iterations
wt_end  = 100; % iterations it takes to go from Iwt(1) to Iwt(2), only for modl=0
errgrad = 1e-25;   % lowest error gradient tolerance
errgraditer=150; % max # of epochs without error change >= errgrad
PSOseed = 0;    % if=1 then can input particle starting positions, if= 0 then all random
% starting particle positions (first 20 at zero, just for an example)
PSOT_plot=[];
PSOT_tirage = [];
PSOT_mv=4; %vitesse maxi des particules (=4 def) 
shw=0;      %MAJ affichage a chque iteration (0 sinon)
ps=10*nb_para; %nb de particules
errgoal=NaN;    %cible minimisation
modl=3;         %type de PSO
%                   0 = Common PSO w/intertia (default)
%                 1,2 = Trelea types 1,2
%                 3   = Clerc's Constricted PSO, Type 1"

PSOT_options=...
    [shw epoch ps ac(1) ac(2) Iwt(1) Iwt(2) ...
    wt_end errgrad errgraditer errgoal modl PSOseed];


%affichage des iterations
if ~enrich.aff_iter_graph
    options_ga=gaoptimset(options_ga,'OutputFcn','');
else
    figure
end
if ~enrich.aff_iter_cmd
    options_ga=gaoptimset(options_ga,'Display', 'final');
end

%affichage informations interations algo (sous forme de plot
if enrich.aff_plot_algo
    options_ga=gaoptimset(options_ga,'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,...
        @gaplotexpectation,@gaplotmaxconstr,@gaplotrange,@gaplotselection,...
        @gaplotscorediversity,@gaplotscores,@gaplotstopping});
    PSOT_plot='goplotpso';
end

%specification manuelle de la population initiale (Ga)
if popInitManu
    doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nbPopInit;doePop.aff=false;doePop.type=popInitManu;
    tir_pop=gene_doe(doePop);
    options_ga=gaoptimset(options_ga,'PopulationSize',nbPopInit,'InitialPopulation',tir_pop);
    PSOT_tirage=tir_pop;
    PSOT_options(13)=1;
else
    PSOT_options(13)=0;
end

%% Minimisation par algo genetique
switch enrich.algo
    case 'ga'
        [pts,fval,exitflag,output] = ga(fun,nb_para,[],[],[],[],lb,ub,[],options_ga);
    case 'pso'
        %variation des parametres
        PSOT_varrange=[lb';ub'];
        %minimisation
        PSOT_minmax=0;
        
        %PSOt version vectorisee
        [pso_out,...    %pt minimum et reponse associee
            tr,...      %pt minimum a chaque iteration 
            te...       %epoch? iterations
            ]=pso_Trelea_vectorized(...
            fun,...             %fonction
            nb_para,...         %nombre variables
            PSOT_mv,...         %vitesse maxi particules (def. 4)
            PSOT_varrange,...   %matrice des plages de variation des parametres
            PSOT_minmax,...     %minimisation (=0 def), maximisation (=1) ou autre (=2)
            PSOT_options,...    %vecteur options
            PSOT_plot,...       %fonction de tracé (optionnelle)
            PSOT_tirage);       %tirage initial aleatoire (=0) ou utilisateur (=1)
        
        %extraction infos
        pts=pso_out(1:end-1)';
        fval=pso_out(end);
        exitflag=[];
        output.tr=tr;
        output.te=te;
    otherwise
        error('Algorithme phase enrichissement mal specifie')
end

%extraction retour algo
ret_tir_meta.out_algo=output;
ret_tir_meta.out_algo.fval=fval;
ret_tir_meta.out_algo.exitflag=exitflag;
%%
mesu_time(tMesu,tInit);
fprintf('#########################################\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Fonction extraction criteres
%fonction extraction WEI
function EI=ret_EI(X,approx,meta)
ZZ=eval_meta(X,approx,meta,false);
EI=-ZZ.ei;
end

%fonction extraction WEI
function WEI=ret_WEI(X,approx,meta)
ZZ=eval_meta(X,approx,meta,false);
WEI=-ZZ.wei;
end

%fonction extraction GEI
function GEI=ret_GEI(X,approx,meta)
ZZ=eval_meta(X,approx,meta,false);
GEI=-ZZ.gei(:,:,meta.enrich.para_gei);
end

%fonction extraction LCB
function LCB=ret_LCB(X,approx,meta)
ZZ=eval_meta(X,approx,meta,false);
LCB=ZZ.lcb;
end

%fonction extraction variance
function VARIANCE=ret_VAR(X,approx,meta)
ZZ=eval_meta(X,approx,meta,false);
VARIANCE=-ZZ.var;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

