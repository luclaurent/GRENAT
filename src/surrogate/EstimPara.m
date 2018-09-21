%% Function for estimating hyperparameters
% L. LAURENT -- 24/01/2012 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function paraEstim=EstimPara(nPIn,dataMeta,funObj)
% display warning or not
dispWarning=false;

%value of the criteria for stopping minimization
critOpti=dataMeta.estim.critOpti;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gfprintf(' - - - - - - - - - - - - - - - - - - - - \n');
Gfprintf('    > Estimation of hyperparameters <\n');
Gfprintf(' - - - - - - - - - - - - - - - - - - - - \n');
countTime=mesuTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the parameters for minimization
[lb,...
    ub,...
    ~,...
    nbPOptim,...
    nbP,...
    funCondPara]=definePara(...
    nPIn,...
    dataMeta.kern,...
    dataMeta.para,...
    dataMeta.estim.aniso,...
    'estim');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Manual definition of the initial population using LHS/IHS (GA)
nbSampInit=10*nbPOptim;
sampManuOn=dataMeta.estim.sampManuOn;
if sampManuOn
    nbSampleSpecif=false;
    if isfield(dataMeta.estim,'nbSampInit');if ~isempty(dataMeta.estim.nbSampInit);nbSampleSpecif=false;end, end
    if nbSampleSpecif;nbSampInit=dataMeta.estim.nbSampInit;end
end
%definition starting point
x0=0.01*(ub-lb);
%function to minimised
fun=@(para)funObj(funCondPara(para));
%options depending on the algorithm
optionsFmincon = optimsetMOD(...
    'Display', 'iter',...        %display evolution
    'Algorithm','interior-point',... %choice of the type of algorithm
    'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
    'FunValCheck','off',...      %check value of the function (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','',...
    'TolFun',critOpti);
optionsSQP = optimsetMOD(...
    'Display', 'iter',...        %display evolution
    'Algorithm','sqp',... %choice of the type of algorithm
    'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
    'FunValCheck','off',...      %check value of the function (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','',...   %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}
    'TolFun',critOpti);
optionsFminbnd = optimsetMOD(...
    'Display', 'iter',...        %display evolution
    'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
    'FunValCheck','off',...      %check value of the function (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','');
optionsGA = gaoptimsetMOD(...
    'Display', 'iter',...        %display evolution
    'OutputFcn','',...      %function used for following the algorithm and dealing with the various status of it
    'UseParallel','never',...
    'PopInitRange',[lb(:)';ub(:)'],...  %definition area of the initial population
    'PlotFcns','',...
    'TolFun',critOpti,...
    'StallGenLimit',20);
optionsFminsearch = optimsetMOD(...
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
errGrad = eps;   % lowest error gradient tolerance
errGradIter=100; % max # of epochs without error change >= errgrad
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
if ~dataMeta.estim.dispIterGraph
    optionsFmincon=optimsetMOD(optionsFmincon,'OutputFcn','');
    optionsSQP=optimsetMOD(optionsSQP,'OutputFcn','');
    optionsFminbnd=optimsetMOD(optionsFminbnd,'OutputFcn','');
    optionsFminsearch=optimsetMOD(optionsFminbnd,'OutputFcn','');
    optionsGA=gaoptimsetMOD(optionsGA,'OutputFcn','');
else
    figure;
end

if ~dataMeta.estim.dispIterCmd
    optionsFmincon=optimsetMOD(optionsFmincon,'Display','final');
    optionsSQP=optimsetMOD(optionsSQP,'Display', 'final');
    optionsFminbnd=optimsetMOD(optionsFminbnd,'Display','final');
    optionsFminsearch=optimsetMOD(optionsFminbnd,'Display', 'final');
    optionsGA=gaoptimsetMOD(optionsGA,'Display','final');
end

%display information of the algorithm on a graph
if dataMeta.estim.dispPlotAlgo
    optionsFmincon=optimsetMOD(optionsFmincon,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    optionsSQP=optimsetMOD(optionsSQP,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    optionsFminbnd=optimsetMOD(optionsFminbnd,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    optionsGA=gaoptimsetMOD(optionsGA,'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,...
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
[wordFind]=strfind(dataMeta.estim.method,patternS);
if isempty(wordFind)
    methodOptim=dataMeta.estim.method;
    sampleMinOk=false;
else
    methodOptim=dataMeta.estim.method((wordFind+numel(patternS)):end);
    sampleMinOk=true;
end
% if SampleMin_ than a sampling is achieved for finding a initialization
% point of the algorithm
if sampleMinOk
    nbSample=nbPOptim*10;
    samplingType='LHS_O1';
    Gfprintf('||SampleMin + opti||  Sampling %s on %i points\n',samplingType,nbSample);
    samplePop=buildDOE(samplingType,nbSample,lb,ub);    
    critS=zeros(1,nbSample);
    for tir=1:nbSample
        critS(tir)=fun(samplePop(tir,:));
    end
    [fval1,IX]=min(critS);
    x0=samplePop(IX,:);    
end
%manual definition of the initial population for GA or PSOt
if sampManuOn&&sampleMinOk    
    samplePop=buildDOE(dataMeta.para.sampManu,nbSampInit,lb,ub);
    optionsGA=gaoptimsetMOD(optionsGA,'PopulationSize',nbSampInit,'InitialPopulation',samplePop);
    %PSOt
    PSOTsampling=samplePop.sorted;
    PSOTOptions(13)=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimisation of the chosen objective function
switch methodOptim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'simplex'  %simplix method
        Gfprintf('||Simplex|| Starting point:\n');
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
        Gfprintf('||SampleMin||  Sample %s on %i points\n',samplingType,nbSample);
        samplePop=buildDOE(samplingType,nbSample,lb,ub);
        critS=zeros(1,nbSample);
        for itSample=1:nbSample
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
        Gfprintf('||Fmincon (SQP)|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %deal with undefined starting point
        if ~dispWarning;warning off all;end
        %minimization
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],optionsSQP);
        %stop minimiszation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            Gfprintf('Issue SQP\n');
        end
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminbnd'
        Gfprintf('||Fminbnd|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimization
        if ~dispWarning;warning off all;end
        [x,fval,exitflag,output] = fminbnd(fun,lb,ub,optionsFminbnd);
        if ~dispWarning;warning on all;end
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            Gfprintf('Issue SQP\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminsearch'
        Gfprintf('||Fminsearch|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimization
        [x,fval,exitflag,output] = fminsearch(fun,x0,optionsFminsearch);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            Gfprintf('Issue Fminsearch\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fmincon'
        Gfprintf('||Fmincon|| Starting point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %deal with undefined starting point
        if ~dispWarning;warning off all;end
        %minimization
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],optionsFmincon);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist(fval1,'var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            Gfprintf('Issue Fmincon\n');
        end
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'ga'
        Gfprintf('||Ga|| Initialisation with sampling %s:\n',sampManuOn);
        if ~dispWarning;warning off all;end
        [x,fval,exitflag,output] = ga(fun,nbPOptim,[],[],[],[],lb,ub,[],optionsGA);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
            if exist('fval1','var');paraEstim.outAlgo.fval1=fval1;end
        elseif exitflag==-2
            Gfprintf('Issue Ga\n');
        end
        
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'pso'
        if sampManuOn;Gfprintf('||PSOt|| Initialisation with sampling %s:\n',sampManuOn);end
        if ~dispWarning;warning off all;end
        %vectorized version of PSOt
        [psoOut,...    %minimum point and associated responses
            tr,...      %minimum point at each iteration
            te...       %epoch iterations
            ]=pso_Trelea_mod(...
            fun,...             %function
            nbPOptim,...         %number variables
            PSOTmv,...         %maximal speed particles (def. 4)
            PSOTVarRange,...   %matrix of the range of the parameters
            PSOTMinMax,...     %minimization (=0 def), maximization (=1) or other (=2)
            PSOTOptions,...    %vector of options
            PSOTplot,...       %plotting function (optional)
            PSOTsampling);     %initial random sampling (=0) other iuser defined  (=1)
        
        %store information of algorithm
        Xmin=psoOut(1:end-1)';
        Zmin=psoOut(end);
        exitflag=[];
        output.tr=tr;
        output.te=te;
        disp('Stop');
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

%recondtionning final parameters values
paraFinal=funCondPara(x);
%store obtained value of the hyperparameters obtained with the minimization
paraEstim.Val=paraFinal;
%deal with various kind of kernel functions
paraEstim.l.Val=paraFinal(1:nbP);
paraEstim.p.Val=NaN;
paraEstim.nu.Val=NaN;

switch dataMeta.kern
    case 'matern'
        paraEstim.nu.Val=paraFinal(end);
    case 'expg'
        paraEstim.p.Val=paraFinal(end);
    case 'expgg'
        paraEstim.p.Val=paraFinal(nbP+1:end);
end
%display values of HyperParameters
Gfprintf(' >>> Optimal HyperParameters\n');
dispHyperParameter('l ',paraEstim.l.Val);
if ~isnan(paraEstim.p.Val);dispHyperParameter('p ',paraEstim.p.Val);end
if ~isnan(paraEstim.nu.Val);dispHyperParameter('nu',paraEstim.nu.Val);end
%
countTime.stop;
Gfprintf(' - - - - - - - - - - - - - - - - - - - - \n');
end

%function for displaying hyperparameters in the command window
function dispHyperParameter(nameHP,valHP)
Gfprintf(' >> %s:',nameHP);
if numel(valHP)==1
    fprintf(' %g',valHP);
else
    fprintf(' %g |',valHP(1:end-1));
    fprintf(' %g',valHP(end));
end
fprintf('\n');
end

%wrapper to optimset and gaoptimset function (actual functions requires the
%Matlab's optimization toolbox)
function varargout=optimsetMOD(varargin)
if exist('optimset','file')&&~isOctave
    [varargout{1:nargout}] = optimset( varargin{:} );
else
    varargout{1}=[];
end
end

function varargout=gaoptimsetMOD(varargin)
if exist('gaoptimset','file')&&~isOctave
    [varargout{1:nargout}] = gaoptimset( varargin{:} );
else
    varargout{1}=[];
end
end
