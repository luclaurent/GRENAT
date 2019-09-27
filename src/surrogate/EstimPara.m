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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gfprintf(' - - - - - - - - - - - - - - - - - - - - \n');
Gfprintf('    > Estimation of hyperparameters <    \n');
Gfprintf(' - - - - - - - - - - - - - - - - - - - - \n');
%
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
    [paraEstim.outAlgo.fval1,IX]=min(critS);
    x0=samplePop(IX,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%manual definition of the initial population for GA or PSOt
if sampManuOn&&sampleMinOk
    samplePop=buildDOE(dataMeta.para.sampManu,nbSampInit,lb,ub);
    %load configuration for optimizer
    optionsOpti=loadConf(methodOptim,lb,ub,dataMeta.estim,nbSampInit,samplePop);
else
    %load configuration for optimizer
    optionsOpti=loadConf(methodOptim,lb,ub,dataMeta.estim);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimisation of the chosen objective function
switch methodOptim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'simplex'  %simplix method
        Gfprintf('||Simplex|| Starting point: ');
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
        Gfprintf('||Fmincon (SQP)|| Starting point: ');
        fprintf('%g ',x0); fprintf('\n');
        %deal with undefined starting point
        if ~dispWarning;warning off all;end
        %minimization
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],optionsOpti);
        %stop minimiszation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
        elseif exitflag==-2
            Gfprintf('Issue SQP\n');
        end
        if ~dispWarning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminbnd'
        if numel(lb)>1
            error('Fminbnd only usable for 1-dimensional problem')
        end
        Gfprintf('||Fminbnd|| Starting point: ');
        fprintf('%g ',x0); fprintf('\n');
        %minimization
        if ~dispWarning;warning off all;end
        [x,fval,exitflag,output] = fminbnd(fun,lb,ub,optionsOpti);
        if ~dispWarning;warning on all;end
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
        elseif exitflag==-2
            Gfprintf('Issue SQP\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminsearch'
        Gfprintf('||Fminsearch|| Starting point: ');
        fprintf('%g ',x0); fprintf('\n');
        %minimization
        [x,fval,exitflag,output] = fminsearch(fun,x0,optionsOpti);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
        elseif exitflag==-2
            Gfprintf('Issue Fminsearch\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fmincon'
        Gfprintf('||Fmincon|| Starting point: ');
        fprintf('%g ',x0); fprintf('\n');
        %deal with undefined starting point
        if ~dispWarning;warning off all;end
        %minimization
        [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],optionsOpti);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
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
        [x,fval,exitflag,output] = ga(fun,nbPOptim,[],[],[],[],lb,ub,[],optionsOpti);
        %stop minimization
        if exitflag==1||exitflag==0||exitflag==2
            disp('Stop');
            paraEstim.outAlgo=output;
            paraEstim.outAlgo.fval=fval;
            paraEstim.outAlgo.exitflag=exitflag;
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
        %precise number of samples
        optionsOpti.opt(3)=nbSampInit;
        %vectorized version of PSOt
        [psoOut,...     %minimum point and associated responses
            tr,...      %minimum point at each iteration
            te...       %epoch iterations
            ]=pso_Trelea_mod(...
            fun,...                     %function
            nbPOptim,...                %number variables
            optionsOpti.PSOTmv,...         %maximal speed particles (def. 4)
            optionsOpti.PSOTVarRange,...   %matrix of the range of the parameters
            optionsOpti.PSOTMinMax,...     %minimization (=0 def), maximization (=1) or other (=2)
            optionsOpti.opt,...    %vector of options
            optionsOpti.PSOTplot,...       %plotting function (optional)
            optionsOpti.PSOTsampling);     %initial random sampling (=0) other iuser defined  (=1)
        
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

%Plot function used for estimate parameters (only if there is 1 or 2
%hyperparameter(s))
if dataMeta.estim.disp
    plotEstimFun(fun,nbPOptim,lb,ub);
    %reeavaluate the optimization function for the optimal values of the
    %hyperparameters
    fun(x);
end

%reconditionning final parameters values
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

%function for plotting the estimation function
function plotEstimFun(fun,nbPOptim,lb,ub)
if nbPOptim==1
    Gfprintf('Evaluate the estimation function for display\n');
    %number of plotting point
    nbPlotingPts=500;
    %prepare ploting grid
    gridH=linspace(lb,ub,nbPlotingPts);
    estFun=zeros(size(gridH));
    %evaluation of the estimation function at the points of the grid
    for itP=1:numel(gridH)
        estFun(itP)=fun(gridH(itP));
        textProgressbar(itP,numel(gridH));
    end
    %plot function
    figure;
    plotFun='plot';
    if all(estFun>0)
        plotFun='semilogy';
    end
    feval(plotFun,gridH,estFun,'r','LineWidth',2);
    xlabel('$l$','Interpreter','latex')
    ylabel('$f_\textrm{estim}$','Interpreter','latex')
    
elseif nbPOptim==2
    Gfprintf('Evaluate the estimation function for display\n');
    %number of plotting point
    nbPlotingPts=25;
    %prepare ploting grid
    gridX=linspace(lb(1),ub(1),nbPlotingPts);
    gridY=linspace(lb(2),ub(2),nbPlotingPts);
    [gridHX,gridHY]=meshgrid(gridX,gridY);
    estFun=zeros(size(gridHX));
    %evaluation of the estimation function at the points of the grid
    for itP=1:numel(gridHX)
        estFun(itP)=fun([gridHX(itP),gridHY(itP)]);
        textProgressbar(itP,numel(gridHX));
    end
    keyboard
    %plot function
    figure;
    subplot(121)
    surf(gridHX,gridHY,estFun);
    %
    colorbar
    %
    if all(estFun>0);set(gca,'ZScale','log');title('log scale');end
    xlabel('$l_1$','Interpreter','latex')
    ylabel('$l_2$','Interpreter','latex')
    zlabel('$f_\textrm{estim}$','Interpreter','latex')
    %
    subplot(122)
    estPlot=estFun;
    if all(estFun>0);estPlot=log(estFun);end
    %
    contourf(gridHX,gridHY,estPlot);
    %
    if all(estFun>0)
        title('log scale');
        chb=colorbar;
        colormap(jet);
        lblValue=get(chb,'YTick');
        newlblValue=num2cell(exp(lblValue));
        txtValue=cellfun(@(x)num2str(x,'%e'),newlblValue,'UniformOutput',false);
        set(chb,'YTickLabel',txtValue');
    end
    %
    contourf(gridHX,gridHY,estPlot,10);
    %
    xlabel('$l_1$','Interpreter','latex')
    ylabel('$l_2$','Interpreter','latex')
    zlabel('$f_\textrm{estim}$','Interpreter','latex')
end
end

%% load configurations of optimizers
function optOptim=loadConf(methodOptim,lb,ub,optEstim,nbSampInit,samplePop)
%options depending on the algorithm
switch methodOptim
    case 'sqp'
        optOptim = optimsetMOD(...
            'Display', 'iter',...           %display evolution
            'Algorithm','sqp',...           %choice of the type of algorithm
            'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
            'FunValCheck','off',...         %check value of the function (Nan,Inf)
            'UseParallel','never',...
            'PlotFcns','',...               %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}
            'TolFun',optEstim.critOpti);
    case 'fminbnd'
        optOptim = optimsetMOD(...
            'Display', 'iter',...           %display evolution
            'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
            'FunValCheck','off',...         %check value of the function (Nan,Inf)
            'UseParallel','never',...
            'PlotFcns','');
    case 'fminsearch'
        optOptim = optimsetMOD(...
            'Display', 'iter',...           %display evolution    'OutputFcn',@stopEstim,...      %function used for following the algorithm and dealing with the various status of it
            'FunValCheck','off',...         %check value of the function (Nan,Inf)
            'TolFun',optEstim.critOpti,...
            'PlotFcns','');
    case 'fmincon'
        optOptim = optimsetMOD(...
            'Display', 'iter',...            %display evolution
            'Algorithm','interior-point',... %choice of the type of algorithm
            'OutputFcn',@stopEstim,...       %function used for following the algorithm and dealing with the various status of it
            'FunValCheck','off',...          %check value of the function (Nan,Inf)
            'UseParallel','never',...
            'PlotFcns','',...
            'TolFun',optEstim.critOpti);
    case 'ga'
        optOptim = gaoptimsetMOD(...
            'Display', 'iter',...           %display evolution
            'OutputFcn','',...              %function used for following the algorithm and dealing with the various status of it
            'UseParallel','never',...
            'PopInitRange',[lb(:)';ub(:)'],...  %definition area of the initial population
            'PlotFcns','',...
            'TolFun',optEstim.critOpti,...
            'StallGenLimit',20);
    case 'pso'
        %%%%% PSOt
        %options of the PSO algorithm from the PSOt toolbox
        ac      = [2.1,2.1];    % acceleration constants, only used for modl=0
        Iwt     = [0.9,0.6];    % intertia weights, only used for modl=0
        epoch   = 2000;         % max iterations
        wtEnd  = 100;           % iterations it takes to go from Iwt(1) to Iwt(2), only for modl=0
        errGrad = eps;          % lowest error gradient tolerance
        errGradIter=100;        % max # of epochs without error change >= errgrad
        PSOseed = 0;            % if=1 then can input particle starting positions, if= 0 then all random
        % starting particle positions (first 20 at zero, just for an example)
        optOptim.PSOTplot=[];
        optOptim.PSOTsampling = [];
        optOptim.PSOTmv=4;      %maximum speed of the particles (=4 def)
        shw=0;                  %update display at each iteration (0 for no display)
        ps=10;                  %nb of particules
        errGoal=NaN;            %cible minimisation
        modl=3;                 %type of PSO
        %    0 = Common PSO w/intertia (default)
        %    1,2 = Trelea types 1,2
        %    3   = Clerc's Constricted PSO, Type 1"
        
        optOptim.opt=...
            [shw epoch ps ac(1) ac(2) Iwt(1) Iwt(2) ...
            wtEnd errGrad errGradIter errGoal modl PSOseed];
        %range of the parameters
        optOptim.PSOTVarRange=[lb(:) ub(:)];
        %minimization
        optOptim.PSOTMinMax=0;
        %%%%%
end

%display iterations
if ~optEstim.dispIterGraph
    switch methodOptim
        case 'ga'
        case 'pso'
        otherwise
            optOptim=optimsetMOD(optOptim,'OutputFcn','');
    end
end
if ~optEstim.dispIterCmd
    switch methodOptim
        case 'ga'
        case 'pso'
        otherwise
            optOptim=optimsetMOD(optOptim,'Display','final');
    end
end
%display information of the algorithm on a graph
if optEstim.dispPlotAlgo
    switch methodOptim
        case 'ga'
            optOptim=gaoptimsetMOD(optOptim,...
                'PlotFcns',{@gaplotbestf,...
                @gaplotbestindiv,...
                @gaplotdistance,...
                @gaplotexpectation,...
                @gaplotmaxconstr,...
                @gaplotrange,...
                @gaplotselection,...
                @gaplotscorediversity,...
                @gaplotscores,...
                @gaplotstopping});
        case 'pso'
            %%PSOT
            optOptim.PSOTplot='goplotpso_perso1';
            optOptim.PSOTOptions(1)=10;
        otherwise
            optOptim=optimsetMOD(optOptim,'PlotFcns',{@optimplotx,...
                @optimplotfunccount,...
                @optimplotstepsize,...
                @optimplotfirstorderopt,...
                @optimplotconstrviolation,...
                @optimplotfval});
    end
end
%manual definition of the initial population for GA or PSOt
if nargin>=6
    switch methodOptim
        case 'ga'
            optOptim=gaoptimsetMOD(optOptim,'PopulationSize',nbSampInit,'InitialPopulation',samplePop);
        case 'pso'
            %PSOt
            optOptim.PSOTsampling=samplePop.sorted;
            optOptim.PSOTOptions(13)=1;
    end
end
end
