%% Function for estimating hyperparameters
% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function paraEstim=EstimPara(dataProb,dataMeta,funObj)
% display warning or not
dispWarning=false;

%value of the criteria for stopping minimization
critOpti=dataMeta.para.critOpti;

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
    nbP=dataProb.in.np;
    nbPOptim=nbP;
else
    nbP=1;
    nbPOptim=nbP;
end

%definition the bounds of the space
% deal with specific cases (depending on the kernel function)
switch dataMeta.kern
    case 'matern'
        lb=[dataMeta.para.l.min*ones(1,nbP) dataMeta.para.nu.min];
        ub=[dataMeta.para.l.max*ones(1,nbP) dataMeta.para.nu.max];
        nbPOptim=nbP+1;
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
nbSampInit=10*nbPOptim;
sampManuOn=dataMeta.para.sampManuOn;
if sampManuOn
    nbSampleSpecif=false;
    if isfield(dataMeta.para,'nbSampInit');if ~isempty(dataMeta.para.nbSampInit);nbSampleSpecif=false;end, end
    if nbSampleSpecif;nbSampInit=dataMeta.para.nbSampInit;end
end
%definition valeur de depart de la variable
x0=0.1*(ub-lb);
%function to minimised
fun=@(para)feval(funObj,dataProb,dataMeta,para,'estim');
%options depending on the algorithm
optionsFmincon = optimset(...
    'Display', 'iter',...        %display evolution
    'Algorithm','interior-point',... %choice of the type of algorithm
    'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
    'FunValCheck','off',...      %check value of the function (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','',...
    'TolFun',critOpti);
optionsSQP = optimset(...
    'Display', 'iter',...        %display evolution
    'Algorithm','sqp',... %choice of the type of algorithm
    'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
    'FunValCheck','off',...      %check value of the function (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','',...   %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}
    'TolFun',critOpti);
optionsFminbnd = optimset(...
    'Display', 'iter',...        %display evolution
    'OutputFcn',@stop_estim,...      %function used for following the algorithm and dealing with the various status of it
    'FunValCheck','off',...      %check value of the function (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','');
optionsGA = gaoptimset(...
    'Display', 'iter',...        %display evolution
    'OutputFcn','',...      %function used for following the algorithm and dealing with the various status of it
    'UseParallel','never',...
    'PopInitRange',[lb(:)';ub(:)'],...  %definition area of the initial population
    'PlotFcns','',...
    'TolFun',critOpti,...
    'StallGenLimit',20);
optionsFminsearch = optimset(...
    'Display', 'iter',...        %display evolution    'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
    'FunValCheck','off',...      %check value of the function (Nan,Inf)
    'TolFun',critOpti,...
    'PlotFcns','');
%%%%% PSOt
%options of the PSO algorithm from the PSOt toolbox
ac      = [2.1,2.1];% acceleration constants, only used for modl=0
Iwt     = [0.9,0.6];  % intertia weights, only used for modl=0
epoch   = 2000; % max iterations
wtEnd  = 100; % iterations it takes to go from Iwt(1) to Iwt(2), only for modl=0
errGrad = 1e-25;   % lowest error gradient tolerance
errGradIter=150; % max # of epochs without error change >= errgrad
PSOseed = 0;    % if=1 then can input particle starting positions, if= 0 then all random
% starting particle positions (first 20 at zero, just for an example)
PSOTplot=[];
PSOTsampling = [];
PSOTmv=4; %maximum speed of the particles (=4 def)
shw=0;      %update display at each iteration (0 for no display)
ps=nbSampInit; %nb of particules
errGoal=NaN;    %cible minimisation
modl=3;         %type of PSO
%                   0 = Common PSO w/intertia (default)
%                 1,2 = Trelea types 1,2
%                 3   = Clerc's Constricted PSO, Type 1"

PSOTOptions=...
    [shw epoch ps ac(1) ac(2) Iwt(1) Iwt(2) ...
    wtEnd errGrad errGradIter errGoal modl PSOseed];
%range of the parameters
PSOTVarRange=[lb(:) ub(:)];
%minimization
PSOTMinMax=0;

%%%%%

%display iterations
if ~dataMeta.para.dispIterGraph
    optionsFmincon=optimset(optionsFmincon,'OutputFcn','');
    optionsSQP=optimset(optionsSQP,'OutputFcn','');
    optionsFminbnd=optimset(optionsFminbnd,'OutputFcn','');
    optionsFminsearch=optimset(optionsFminbnd,'OutputFcn','');
    optionsGA=gaoptimset(optionsGA,'OutputFcn','');
else
    figure
end

if ~dataMeta.para.dispIterCmd
    optionsFmincon=optimset(optionsFmincon,'Display','final');
    optionsSQP=optimset(optionsSQP,'Display', 'final');
    optionsFminbnd=optimset(optionsFminbnd,'Display','final');
    optionsFminsearch=optimset(optionsFminbnd,'Display', 'final');
    optionsGA=gaoptimset(optionsGA,'Display','final');
end

%display information of the algorithm on a graph
if dataMeta.para.dispPlotAlgo
    optionsFmincon=optimset(optionsFmincon,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    optionsSQP=optimset(optionsSQP,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    optionsFminbnd=optimset(optionsFminbnd,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    optionsGA=gaoptimset(optionsGA,'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,...
        @gaplotexpectation,@gaplotmaxconstr,@gaplotrange,@gaplotselection,...
        @gaplotscorediversity,@gaplotscores,@gaplotstopping});
    %%PSOT
    PSOTplot='goplotpso_perso1';
    PSOTOptions(1)=10;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Deal with 'SampleMin_xxxx' strategies
%look for the 'SampleMin_' pattern
patternS='SampleMin_';
[wordFind]=strfind(dataMeta.para.method,patternS);
if isempty(wordFind)
    methodOptim=dataMeta.para.method;
    sampleMinOk=false;
else
    methodOptim=dataMeta.para.method((wordFind+numel(patternS)):end);
    sampleMinOk=true;
end
% if SampleMin_ than a sampling is achieved for finding a initialization
% point of the algorithm
if sampleMinOk
    nbSample=nbP*10;
    samplingType='LHS_O1';
    fprintf('||SampleMin + opti||  Sampling %s on %i points\n',samplingType,nbSample);
    doePop.Xmin=lb;doePop.Xmax=ub;doePop.nbSamples=nbSample;doePop.disp=false;doePop.type=samplingType;
    samplePop=buildDOE(doePop);
    critS=zeros(1,nbSample);
    parfor tir=1:nbSample
        critS(tir)=fun(samplePop(tir,:));
    end
    [fval1,IX]=min(critS);
    x0=samplePop(IX,:);
end
%manual definition of the initial population for GA or PSOt
if ~isempty(sampManuOn)&&sampleMinOk
    doePop.Xmin=lb;doePop.Xmax=ub;doePop.nbSamples=nbSampInit;doePop.disp=false;doePop.type=dataMeta.para.popManu;
    samplePop=gene_doe(doePop);
    optionsGA=gaoptimset(optionsGA,'PopulationSize',nbSampInit,'InitialPopulation',samplePop);
    %PSOt
    PSOTsampling=samplePop;
    PSOTOptions(13)=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimisation of the chosen objective function
switch methodOptim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'simplex'  %simplix method
        fprintf('||Simplex|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        if ~dispWarning;warning off all;end
        [x, fmax, nf] = nmsmax(fun, x0, [], []);
        %store results from the algorithm
        paraEstim.outAlgo.fmax=fmax;
        paraEstim.outAlgo.nf=nf;
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'SampleMin'
        nbSample=nbP*50;
        samplingType='LHS_O1';
        fprintf('||SampleMin||  Sample %s on %i points\n',samplingType,nbSample);
        doePop.Xmin=lb;doePop.Xmax=ub;doePop.nbSamples=nbSample;doePop.disp=false;doePop.type=samplingType;
        samplePop=buildDOE(doePop);
        critS=zeros(1,nbSample);
        parfor itSample=1:nbSample
            critS(itSample)=fun(samplePop(itSample,:));
        end
        [fval,IX]=min(critS);
        x=samplePop(IX,:);
        
        %store results from the algorithm
        paraEstim.outAlgo.fval=fval;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'sqp'
        fprintf('||Fmincon (SQP)|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %deal with undefined starting point
        if ~dispWarning;warning off all;end
        %minimization
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],optionsSQP);
        %stop minimiszation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop')
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Issue SQP\n');
        end
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminbnd'
        fprintf('||Fminbnd|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimization
        if ~dispWarning;warning off all;end
        [x,fval,exitflag,output] = fminbnd(fun,lb,ub,optionsFminbnd);
        if ~dispWarning;warning on all;end
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop')
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Issue SQP\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminsearch'
        fprintf('||Fminsearch|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimization
        [x,fval,exitflag,output] = fminsearch(fun,x0,optionsFminsearch);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop')
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Issue Fminsearch\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fmincon'
        fprintf('||Fmincon|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %deal with undefined starting point
        if ~dispWarning;warning off all;end
        %minimization
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],optionsFmincon);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop')
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist(fval1,'var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Issue Fmincon\n');
        end
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'ga'
        fprintf('||Ga|| Initialisation with sampling %s:\n',sampManuOn);
        if ~dispWarning;warning off all;end
        [x,fval,exitflag,output] = ga(fun,nbPOptim,[],[],[],[],lb,ub,[],optionsGA);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop')
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            fprintf('Issue Ga\n');
        end
        
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'pso'
        fprintf('||PSOt|| Initialisation with sampling %s:\n',sampManuOn);
        if ~dispWarning;warning off all;end        
        %vectorized version of PSOt
        [pso_out,...    %minimum point and associated responses
            tr,...      %minimum point at each iteration
            te...       %epoch iterations
            ]=pso_Trelea_mod(...
            fun,...             %function
            nbP,...         %number variables
            PSOTmv,...         %maximal speed particles (def. 4)
            PSOTVarRange,...   %matrix of the range of the parameters
            PSOTMinMax,...     %minimization (=0 def), maximization (=1) or other (=2)
            PSOTOptions,...    %vector of options
            PSOTplot,...       %plotting function (optional)
            PSOTsampling);     %initial random sampling (=0) other iuser defined  (=1)
        
        %store information of algorithm
        Xmin=pso_out(1:end-1)';
        Zmin=pso_out(end);
        exitflag=[];
        output.tr=tr;
        output.te=te;
        disp('Stop')
        paraEstim.outAlgo=output;
        paraEstim.outAlgo.xval=Xmin;
        paraEstim.outAlgo.fval=Zmin;
        paraEstim.outAlgo.exitflag=exitflag;
        x=Xmin;
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
        error(['Wrong kind of minimization method (',mfilename,')']);
end


mesuTime(tMesu,tInit);
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')

%store obtained value of the hyperparameters obtained with the minimization
paraEstim.val=x;
%deal with various kind of kernel functions
paraEstim.l.val=x(1:nbP);
paraEstim.p.val=NaN;
paraEstim.nu.val=NaN;
switch dataMeta.kern
    case 'matern'
        paraEstim.nu.val=x(end);
    case 'expg'
        paraEstim.nu.val=x(end);
    case 'expgg'
        paraEstim.nu.val=x(nbP+1:end);
end
end