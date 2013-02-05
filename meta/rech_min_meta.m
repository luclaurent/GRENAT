%% Proc�dure de recherche du minimum de l'approximation construite
%% L.LAURENT -- 25/06/2012 -- laurent@lmt.ens-cachan.fr

function [Zap_min,X_min]=rech_min_meta(meta,approx,optim,type)

[tMesu,tInit]=mesu_time;
fprintf('++++++++++++++++++++++++++++++++++++\n');
fprintf('>>> RECHERCHE MINIMUM METAMODELE <<<\n');

%%type de minimum recherche (par defaut minimisation fonction
if nargin==3
    type='rep';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% definition de la strategie d'optimisation et de ses parametres


% en fonction du type d'algo souhaite
switch optim.algo
    %pour une recherche locale
    case 'fmincon'
        
    case 'ga'
        global doe
        %definition des bornes de l'espace de recherche
        lb=doe.Xmin;ub=doe.Xmax;
        %nombre parametres
        nb_para=numel(doe.Xmin);
        %Definition manuelle de la population initiale par LHS (Ga)
        popInitManu=optim.popManu;
        nbPopInit=optim.nbPopInit;
        if popInitManu
            nbpopspecif=false;
            if isfield(optim,'nbPopInit');if ~isempty(optim.nbPopInit);nbpopspecif=false;end, end
            if nbpopspecif;nbPopInit=optim.nbPopInit;else nbPopInit=10*nb_para; end
        end
                
        %Options algo pour chaque fonction de minimisation
        %declaration des options de la strategie de minimisation
        options_ga = gaoptimset(...
            'Display', 'iter',...        %affichage evolution
            'OutputFcn','',...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
            'UseParallel','always',...
            'PopInitRange',[lb(:)';ub(:)'],...    %zone de d�finition de la population initiale
            'PlotFcns','',...
            'TolFun',optim.crit_opti,...
            'StallGenLimit',20);
        %affichage des iterations
        if ~optim.aff_iter_graph
            options_ga=gaoptimset(options_ga,'OutputFcn','');
        else
            figure
        end
        if ~optim.aff_iter_cmd
            options_ga=gaoptimset(options_ga,'Display', 'final');
        end
        
        %affichage informations interations algo (sous forme de plot
        if optim.aff_plot_algo
            options_ga=gaoptimset(options_ga,'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,...
                @gaplotexpectation,@gaplotmaxconstr,@gaplotrange,@gaplotselection,...
                @gaplotscorediversity,@gaplotscores,@gaplotstopping});
        end
        
        %specification manuelle de la population initiale (Ga)
        if ~isempty(popInitManu)
            doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nbPopInit;doePop.aff=false;doePop.type=meta.para.popManu;
             tir_pop=gene_doe(doePop);
            options_ga=gaoptimset(options_ga,'PopulationSize',nbPopInit,'InitialPopulation',tir_pop);
        end
        
    case 'ANT'
        
    case 'PSO'
        
    otherwise
        error('Algorithme de minimisation sur le metamodele mal defini\n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% declaration de la fonction a minimiser
switch type
    case 'rep'
        fun=@(point)ext_rep(point,approx,meta);
    case 'var'
        fun=@(point)ext_var(point,approx,meta);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimisation
switch optim.algo
    case 'ga'
        [pts,fval,exitflag,output] = ga(fun,nb_para,[],[],[],[],lb,ub,[],options_ga);
        Zap_min=fval;
        X_min=pts;
    case 'fmincon'
    case 'sqp'
    case 'ANT'
    case 'PSO'
end



mesu_time(tMesu,tInit);
fprintf('      ++++++++++++++++++++++++++++++++++++\n');
end

%fonction extraction reponse metamodele
function REP=ext_rep(X,approx,meta)
ZZ=eval_meta(X,approx,meta);
REP=ZZ.Z;
end

%fonction extraction variance metamodele
function VARIANCE=ext_var(X,approx,meta)
ZZ=eval_meta(X,approx,meta);
VARIANCE=-ZZ.var;
end

