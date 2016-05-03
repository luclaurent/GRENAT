%% Function for estimating RBF hyperparameters
% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function paraEstim=RBFEstimPara(dataProb,dataMeta)
% display warning or not
dispWarning=false;

%value of the criteria for stopping minimization
critOpti=dataMeta.para.critOpti;

%stop the display of CV 
cvOld=dataMeta.cv;
dispCvOld=dataMeta.cv.disp;
dataMeta.cv.disp=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')
fprintf('    > Estimation of hyperparameters <\n');
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')
[tMesu,tInit]=mesuTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the parameters for minimization
% Number of hyperparameters to estimate
%anisotropy
if dataMeta.para.aniso
    nbP=dataProb.in.nb_var;
    nbPOptim=nbP;
else
    nbP=1;
    nbPOptim=nbP;
end

%definition the bounds of the space
% deal with specific cases (depending on the kernel function)
switch dataMeta.kern
    case 'expg'
        lb=[dataMeta.para.l.min*ones(1,nbP) dataMeta.para.p.min];
        ub=[dataMeta.para.l.max*ones(1,nbP) dataMeta.para.p.max];
        nbPOptim=nbP+1;
    case 'expgg'
        lb=[dataMeta.para.l.min*ones(1,nbP) dataMeta.para.p.min*ones(1,nbP)];
        ub=[dataMeta.para.l.max*ones(1,nbP) dataMeta.para.p.max*ones(1,nbP)];
        nbPOptim=2*nbP;
    otherwise
        lb=dataMeta.para.l.min*ones(1,nbP);
        ub=dataMeta.para.l.max*ones(1,nbP);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Manual definition of the initial population using LHS/IHS (GA)
popInitManu=dataMeta.para.popManu;
if popInitManu
    nbpopspecif=false;
    if isfield(dataMeta.para,'nbPopInit');if ~isempty(dataMeta.para.nbPopInit);nbpopspecif=false;end, end
    if nbpopspecif;nbPopInit=dataMeta.para.nbPopInit;else nbPopInit=10*nbPOptim; end
end
%definition valeur de depart de la variable
x0=0.1*(ub-lb);
%function to minimised
fun=@(para)RBFBloc(dataProb,dataMeta,para,'estim');
%options depending on the algorithm
options_fmincon = optimset(...
    'Display', 'iter',...        %display evolution
    'Algorithm','interior-point',... %choice of the type of algorithm
    'OutputFcn',@stop_estim,...      %function usedfonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','',...
    'TolFun',critOpti);
options_sqp = optimset(...
    'Display', 'iter',...        %display evolution
    'Algorithm','sqp',... %choix du type d'algorithme
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','',...   %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}
    'TolFun',critOpti);
options_fminbnd = optimset(...
    'Display', 'iter',...        %display evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','');
options_ga = gaoptimset(...
    'Display', 'iter',...        %display evolution
    'OutputFcn','',...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'UseParallel','never',...
    'PopInitRange',[lb(:)';ub(:)'],...  %zone de definition de la population initiale
    'PlotFcns','',...
    'TolFun',critOpti,...
    'StallGenLimit',20);
options_fminsearch = optimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'TolFun',critOpti,...
    'PlotFcns','');
%%%%% PSOt
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
%variation des parametres
PSOT_varrange=[lb(:) ub(:)];
%minimisation
PSOT_minmax=0;

%%%%%

%affichage des iterations
if ~dataMeta.para.aff_iter_graph
    options_fmincon=optimset(options_fmincon,'OutputFcn','');
    options_sqp=optimset(options_sqp,'OutputFcn','');
    options_fminbnd=optimset(options_fminbnd,'OutputFcn','');
    options_fminsearch=optimset(options_fminbnd,'OutputFcn','');
    options_ga=gaoptimset(options_ga,'OutputFcn','');
else
    figure
end

if ~dataMeta.para.aff_iter_cmd
    options_fmincon=optimset(options_fmincon,'Display','final');
    options_sqp=optimset(options_sqp,'Display', 'final');
    options_fminbnd=optimset(options_fminbnd,'Display','final');
    options_fminsearch=optimset(options_fminbnd,'Display', 'final');
    options_ga=gaoptimset(options_ga,'Display','final');
end

%affichage informations interations algo (sous forme de plot
if dataMeta.para.aff_plot_algo
    options_fmincon=optimset(options_fmincon,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    options_sqp=optimset(options_sqp,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    options_fminbnd=optimset(options_fminbnd,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    options_ga=gaoptimset(options_ga,'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,...
        @gaplotexpectation,@gaplotmaxconstr,@gaplotrange,@gaplotselection,...
        @gaplotscorediversity,@gaplotscores,@gaplotstopping});
    %%PSOT
    PSOT_plot='goplotpso_perso1';
    PSOT_options(1)=10;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% traitement des strategie de type tir_min_xxxx
%on recherche si le motif tir_min_ est present dans le nom de strategie
motif='tir_min_';
[motfind]=strfind(dataMeta.para.method,motif);
if isempty(motfind)
    method_optim=dataMeta.para.method;
    tir_min_ok=false;
else
    method_optim=dataMeta.para.method((motfind+numel(motif)):end);
    tir_min_ok=true;
end
% si tir_min alors on fait un tirage pour rechercher un point
% d'initialisation de l'algorithme
if tir_min_ok
    nb_pts=nbP*10;
    type_tir='LHS_O1';
    fprintf('||Tir_min + opti||  Tirage %s de %i points\n',type_tir,nb_pts);
    doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nb_pts;doePop.aff=false;doePop.type=type_tir;
    tir_pop=gene_doe(doePop);
    crit=zeros(1,nb_pts);
    parfor tir=1:nb_pts
        crit(tir)=fun(tir_pop(tir,:));
    end
    [fval1,IX]=min(crit);
    x0=tir_pop(IX,:);
end
%specification manuelle de la population initiale (Ga)
if ~isempty(popInitManu)&&tir_min_ok
    doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nbPopInit;doePop.aff=false;doePop.type=dataMeta.para.popManu;
    tir_pop=gene_doe(doePop);
    options_ga=gaoptimset(options_ga,'PopulationSize',nbPopInit,'InitialPopulation',tir_pop);
    %PSOt
    PSOT_tirage=tir_pop;
    PSOT_options(13)=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimisation de la log-vraisemblance suivant l'algorithme choisi

switch method_optim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'simplex'  %methode du simplexe
        fprintf('||Simplex|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        if ~dispWarning;warning off all;end
        [x, fmax, nf] = nmsmax(fun, x0, [], []);
        %stockage retour algo
        paraEstim.out_algo.fmax=fmax;
        paraEstim.out_algo.nf=nf;
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'tir_min'
        nb_pts=nbP*50;
        type_tir='LHS_O1';
        fprintf('||Tir_min||  Tirage %s de %i points\n',type_tir,nb_pts);
        doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nb_pts;doePop.aff=false;doePop.type=type_tir;
        tir_pop=gene_doe(doePop);
        crit=zeros(1,nb_pts);
        parfor tir=1:nb_pts
            crit(tir)=fun(tir_pop(tir,:));
        end
        [fval,IX]=min(crit);
        x=tir_pop(IX,:);
        
        %stockage retour algo
        paraEstim.out_algo.fval=fval;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'sqp'
        fprintf('||Fmincon (SQP)|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimisation avec traitement de point de depart non defini
        if ~dispWarning;warning off all;end
        %pas de recherche d'initialisation
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options_sqp);
        %arret minimisation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Arret')
            paraEstim.out_algo=output;
            paraEstim.out_algo.fval=fval;
            paraEstim.out_algo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.out_algo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Bug arret SQP\n');
        end
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminbnd'
        fprintf('||Fminbnd|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimisation
        if ~dispWarning;warning off all;end
        [x,fval,exitflag,output] = fminbnd(fun,lb,ub,options_fminbnd);
        if ~dispWarning;warning on all;end
        %arret minimisation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Arret')
            paraEstim.out_algo=output;
            paraEstim.out_algo.fval=fval;
            paraEstim.out_algo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.out_algo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Bug arret SQP\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminsearch'
        fprintf('||Fminsearch|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimisation
        [x,fval,exitflag,output] = fminsearch(fun,x0,options_fminsearch);
        %arret minimisation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Arret')
            paraEstim.out_algo=output;
            paraEstim.out_algo.fval=fval;
            paraEstim.out_algo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.out_algo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Bug arret Fminsearch\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fmincon'
        fprintf('||Fmincon|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimisation avec traitement de point de depart non defini
        if ~dispWarning;warning off all;end
        %pas de recherche d'initialisation
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options_fmincon);
        %arret minimisation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Arret')
            paraEstim.out_algo=output;
            paraEstim.out_algo.fval=fval;
            paraEstim.out_algo.exitflag=exitflag;
            if exist(fval1,'var');paraEstim.out_algo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Bug arret Fmincon\n');
        end
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'ga'
        fprintf('||Ga|| Initialisation par tirages %s:\n',popInitManu);
        if ~dispWarning;warning off all;end
        [x,fval,exitflag,output] = ga(fun,nbPOptim,[],[],[],[],lb,ub,[],options_ga);
        %arret minimisation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Arret')
            paraEstim.out_algo=output;
            paraEstim.out_algo.fval=fval;
            paraEstim.out_algo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.out_algo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Bug arret Ga\n');
        end
        
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'pso'
        fprintf('||PSOt|| Initialisation par tirages %s:\n',popInitManu);
        if ~dispWarning;warning off all;end
        %PSOt version vectorisee        
        [pso_out,...    %pt minimum et reponse associee
            tr,...      %pt minimum a chaque iteration
            te...       %epoch? iterations
            ]=pso_Trelea_mod(...
            fun,...             %fonction
            nbP,...         %nombre variables
            PSOT_mv,...         %vitesse maxi particules (def. 4)
            PSOT_varrange,...   %matrice des plages de variation des parametres
            PSOT_minmax,...     %minimisation (=0 def), maximisation (=1) ou autre (=2)
            PSOT_options,...    %vecteur options
            PSOT_plot,...       %fonction de tracee (optionnelle)
            PSOT_tirage);       %tirage initial aleatoire (=0) ou utilisateur (=1)
        
        %extraction infos
        Xmin=pso_out(1:end-1)';
        Zmin=pso_out(end);
        exitflag=[];
        output.tr=tr;
        output.te=te;
        disp('Arret')
        paraEstim.out_algo=output;
        paraEstim.out_algo.xval=Xmin;
        paraEstim.out_algo.fval=Zmin;
        paraEstim.out_algo.exitflag=exitflag;
        x=Xmin;
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
        error('Strategie de minimisation non prise en charge');
end

%reactivation affichage CV si c'etait le cas avant la phase d'estimation
dataMeta.cv_aff=dispCvOld;
dataMeta.cv=cvOld;

mesu_time(tMesu,tInit);
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')
%stockage valeur parametres obtenue par minimisation
if nbPOptim>nbP
    paraEstim.l_val=x(1:nbP);
    paraEstim.p_val=x(nbP+1:end);
else
    paraEstim.l_val=x;
end

if dataMeta.norm
    paraEstim.l_val_denorm=paraEstim.l_val.*dataProb.norm.std_tirages+dataProb.norm.moy_tirages;
    fprintf('\nValeur(s) parametre(s) RBF');
    fprintf(' %6.4f',paraEstim.l_val_denorm);
else
    fprintf('\n');
end
fprintf('\nValeur(s) parametre(s) RBF (brut)');
fprintf(' %6.4f',paraEstim.l_val);
fprintf('\n\n');
if nbPOptim>nbP
    fprintf('Valeur(s) longueur(s) puissance(s)');
    fprintf(' %6.4f',paraEstim.p_val);
    fprintf('\n\n');
end
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')
end