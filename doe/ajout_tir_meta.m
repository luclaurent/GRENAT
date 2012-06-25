%% Fonction assurant la création d'un nouveau point d'echantillonnage basé sur un metamodele
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr


function [pts,ret_tir_meta]=ajout_tir_meta(meta,approx,enrich)

global doe
%Definition manuelle de la population initiale par LHS (Ga)
popInitManu=true;
nbPopInit=50;
%critere arret minimisation
crit_opti=10^-6;

%en fonction du type de nouveau point reclamé
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
%definition des bornes de l'espace de recherche
lb=doe.Xmin;ub=doe.Xmax;
%nombre parametres
nb_var=numel(doe.Xmin);

%Options algo pour chaque fonction de minimisation
%declaration des options de la strategie de minimisation
options_ga = gaoptimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn','',...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'UseParallel','always',...
    'PopInitRange',[lb(:)';ub(:)'],...    %zone de définition de la population initiale
    'PlotFcns','',...
    'TolFun',crit_opti,...
    'StallGenLimit',20);

%{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,@gaplotexpectation,...
%@gaplotmaxconstr,@gaplotrange,@gaplotselection,@gaplotscorediversity,@gaplotscores,@gaplotstopping});
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
end

%specification manuelle de la population initiale (Ga)
if popInitManu
    tir_pop=lhsu(lb,ub,nbPopInit);
    options_ga=gaoptimset(options_ga,'PopulationSize',nbPopInit,'InitialPopulation',tir_pop);
end

%% Minimisation par algo genetique
switch enrich.algo
    case 'ga'
        [pts,fval,exitflag,output] = ga(fun,nb_var,[],[],[],[],lb,ub,[],options_ga);
    otherwise
        error('Algorithme phase enrichissement mal specifie')
end

%extraction retour algo
ret_tir_meta.out_algo=output;
ret_tir_meta.out_algo.fval=fval;
ret_tir_meta.out_algo.exitflag=exitflag;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Fonction extraction criteres
%fonction extraction WEI
function EI=ret_EI(X,approx,meta)
ZZ=eval_meta(X,approx,meta);
EI=-ZZ.ei;
end

%fonction extraction WEI
function WEI=ret_WEI(X,approx,meta)
ZZ=eval_meta(X,approx,meta);
WEI=-ZZ.wei;
end

%fonction extraction GEI
function GEI=ret_GEI(X,approx,meta)
ZZ=eval_meta(X,approx,meta);
GEI=-ZZ.gei(:,:,meta.enrich.para_gei);
end

%fonction extraction LCB
function LCB=ret_LCB(X,approx,meta)
ZZ=eval_meta(X,approx,meta);
LCB=ZZ.lcb;
end

%fonction extraction variance
function VARIANCE=ret_VAR(X,approx,meta)
ZZ=eval_meta(X,approx,meta);
VARIANCE=-ZZ.var;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

