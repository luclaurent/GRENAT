%% Procedure de recherche du minimum de l'approximation construite
%% L.LAURENT -- 25/06/2012 -- laurent@lmt.ens-cachan.fr

function [Zap_min,X_min]=rech_min_meta(meta,approx,optim,type)

[tMesu,tInit]=mesu_time;

fprintf('+++++++++++++++++++++++++++++++++++++++++\n');
%%type de minimum recherche (par defaut minimisation fonction
if nargin==3
    type='rep';
end

switch type
    case 'rep'
        fprintf('  >>> RECHERCHE MINIMUM METAMODELE <<<\n');
    case 'var'
        fprintf('>>> RECHERCHE MAXIMUM VARIANCE METAMODELE <<<\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global doe
%definition des bornes de l'espace de recherche
lb=doe.Xmin;ub=doe.Xmax;
%nombre parametres
nb_para=numel(doe.Xmin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Definition manuelle de la population initiale par LHS (Ga/PSO)
if optim.popInitManu
    nbpopspecif=false;
    if isfield(optim,'nbPopInit');if ~isempty(optim.nbPopInit);nbpopspecif=false;end, end
    if nbpopspecif;nbPopInit=optim.nbPopInit;else nbPopInit=10*nb_para+10; end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% definition de la strategie d'optimisation et de ses parametres
% en fonction du type d'algo souhaite
switch optim.algo
    %pour une recherche locale
    case 'fmincon'
        
    case 'ga'
        
        %Options algo pour chaque fonction de minimisation
        %declaration des options de la strategie de minimisation
        options_ga = gaoptimset(...
            'Display', 'iter',...        %affichage evolution
            'OutputFcn','',...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
            'UseParallel','always',...
            'PopInitRange',[lb(:)';ub(:)'],...    %zone de dï¿½finition de la population initiale
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
        if optim.popInitManu
            doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nbPopInit;doePop.aff=false;doePop.type=optim.popManu;
            tir_pop=gene_doe(doePop);
            options_ga=gaoptimset(options_ga,'PopulationSize',nbPopInit,'InitialPopulation',tir_pop);
        end
        
    case 'pso'
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
        ps=nbPopInit; %nb de particules
        errgoal=NaN;    %cible minimisation
        modl=3;         %type de PSO
        %                   0 = Common PSO w/intertia (default)
        %                 1,2 = Trelea types 1,2
        %                 3   = Clerc's Constricted PSO, Type 1"
        
        PSOT_options=...
            [shw epoch ps ac(1) ac(2) Iwt(1) Iwt(2) ...
            wt_end errgrad errgraditer errgoal modl PSOseed];
        
        
        %affichage informations interations algo (sous forme de plot
        if optim.aff_plot_algo
            PSOT_plot='goplotpso_perso1';
            PSOT_options(1)=10;
        end
        
        %specification manuelle de la population initiale (Ga)
        if optim.popInitManu
            doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nbPopInit;doePop.aff=false;doePop.type=optim.popManu;
            tir_pop=gene_doe(doePop);
            PSOT_tirage=tir_pop;
            PSOT_options(13)=1;
        else
            PSOT_options(13)=0;
        end
        %variation des parametres
        PSOT_varrange=[doe.Xmin doe.Xmax];
        %minimisation
        PSOT_minmax=0;
        
        
    case 'ANT'
        
        
        
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

%generation reference pour controle
if isfield(optim,'aff_ref')
    aff_ref=optim.aff_ref;
else
    aff_ref=false;
end
if aff_ref&&nb_para<=2
    fprintf(' >> Generation et affichage critere\n')
    %generation de la grille de reference
    ref.nbele=gene_nbele(nb_para);
    [grid_XY_ref,ref]=gene_aff(doe,ref);
    text_titre=[type ' ' num2str(approx.nb_val) ' pts'];
    text_file=[type '_' num2str(approx.nb_val) '_pts'];
    ref_tirages=approx.tirages;
    hhh=figure('Name',text_titre);
    %affichage de la fonction
    if nb_para==1
        ZZref=fun(grid_XY_ref);
        ZZtir=fun(ref_tirages);
        plot(grid_XY_ref,ZZref);
        hold on
        plot(ref_tirages,ZZtir,...
            'o','MarkerEdgeColor','g',...
            'MarkerFaceColor','g',...
            'MarkerSize',7);
        hold off
    elseif nb_para==2
        XX=grid_XY_ref(:,:,1);
        YY=grid_XY_ref(:,:,2);
        ZZ=fun([XX(:) YY(:)]);
        ZZref=zeros(size(XX));
        ZZref(:)=ZZ;
        ZZtir=fun(ref_tirages);
        subplot(121)
        surf(XX,YY,ZZref);
        hold on
        plot3(ref_tirages(:,1),ref_tirages(:,2),ZZtir,...
            'o','MarkerEdgeColor','g',...
            'MarkerFaceColor','g',...
            'MarkerSize',7);
        hold off
        subplot(122)
        contour(XX,YY,ZZref);
        hold on
        plot(ref_tirages(:,1),ref_tirages(:,2),...
            'o','MarkerEdgeColor','g',...
            'MarkerFaceColor','g',...
            'MarkerSize',7);
        hold off
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimisation
switch optim.algo
    case 'ga'
        [pts,fval,exitflag,output] = ga(fun,nb_para,[],[],[],[],lb,ub,[],options_ga);
        Zap_min=fval;
        X_min=pts;
    case 'pso'
        
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
        X_min=pso_out(1:end-1)';
        Zap_min=pso_out(end);
        exitflag=[];
        output.tr=tr;
        output.te=te;
    case 'fmincon'
    case 'sqp'
    case 'ANT'
        
end

%on ajoute le point sur le graphe
if aff_ref&&nb_para<=2&&exist('X_min','var')
    figure(hhh)
    hold on
    if nb_para==1
        plot(X_min,Zap_min,'rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','g',...
            'MarkerSize',10);
    elseif nb_para==2
        plot3(X_min(1),X_min(2),Zap_min,'rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','g',...
            'MarkerSize',10);
    end
    hold off
    global aff
    hgsave(hhh,[aff.doss '/' text_file '.fig'])
    saveas(hhh,[aff.doss  '/' text_file '.eps'],'eps')
end

mesu_time(tMesu,tInit);
fprintf('++++++++++++++++++++++++++++++++++++\n');
end

%fonction extraction reponse metamodele
function REP=ext_rep(X,approx,meta)
ZZ=eval_meta(X,approx,meta,false);
REP=ZZ.Z;
end

%fonction extraction variance metamodele
function VARIANCE=ext_var(X,approx,meta)
ZZ=eval_meta(X,approx,meta,false);
VARIANCE=-ZZ.var;
end

