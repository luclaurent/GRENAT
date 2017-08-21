%% class for Support Vector Regression metamodel
% SVR: Support Vector Regression
% GSVR: gradient-based Support Vector Regression
% L. LAURENT -- 18/08/2017 -- luc.laurent@lecnam.net

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

classdef SVR  < handle
    properties
        sampling=[];        % sample points
        resp=[];            % sample responses
        grad=[];            % sample gradients
        %
        missData;           % class for missing data
        kernelMatrix;       % class for kernel matrix
        metaData;           % class for parameter of the metamodels
        %
        paraEstim;          % structure for all information obtained from the estimation of the internal parameters
        %
        YY=[];              % vector of responses
        YYD=[];             % vector of gradients
        YYtot=[];           % full vector of responses and gradients
        K=[];               % kernel matrix
        %
        PsiT=[];            % matrix of SVR convex quadratic problem
        %
        fVal;               % value of the objective function obtained after solving QP
        exitFlag;           % status flag of the QP optimizer
        CC;                 % second member of QP
        AineqR;              % inequality constraint matrix of QP
        bineqR;              % inequality constraint vector of QP
        AineqG;              % inequality constraint matrix of QP
        bineqG;              % inequality constraint vector of QP
        Aineq;              % inequality constraint matrix of QP
        bineq;              % inequality constraint vector of QP
        AeqR;                % equality constraint matrix of QP
        AeqG;                % equality constraint matrix of QP
        Aeq;                % equality constraint matrix of QP
        beq;                % equality vector of QP
        lbR;                 % lower bound of QP variables
        lbG;                 % lower bound of QP variables
        lb;                 % lower bound of QP variables
        ubR;                 % upper bound of QP variables
        ubG;                 % upper bound of QP variables
        ub;                 % upper bound of QP variables
        %
        alphaRAW;           % RAW alpha variables solution of QP (SVR)
        alphaPM;            % differences of alpha_i
        alphaPP;            % sums of alpha_i
        lambdaRAW;          % RAW lambda variables solution of QP (GSVR)
        lambdaPM;           % differences of lambda_i
        lambdaPP;           % sum of lambda_i
        FullAlphaLambdaPM;  % full vector of differences alpha_i and lambda_i
        FullAlphaLambdaPP;  % full vector of sum alpha_i and lambda_i
        FullAlphaLambdaRAW; % full RW vector of alpha_i and lambda_i
        xiTau;              % slack variables
        %
        e;                  % epsilon parameter
        SVRmu;              % mu parameter
        %
        nbUSV;              % number of unbounded SVs
        nbBSV;              % number of bounded SVs
        iXsvUSV;            % indices of unbounded SVs
        iXsvBSV;            % indices of bounded SVs
        %
        PsiUSV;             % matrix of quadratic problem w/o the bounded SVs
        KUSV;               % extended PsiUSV
        iKUSV;              % inverse of KUSV
        %
        polyOrder=0;        % polynomial order
        kernelFun='sexp';   % kernel function
        %
        paraVal=1;         % internal parameters used for building (fixed or estimated)
        lVal=[];            % internal parameters: length
        pVal=[];            % internal parametersfor generalized squared exponential
        nuVal=[];           % internal parameter for Matern function
        %
        normLOO='L2';       % norm used for Leave-One-Out cross-validation
        debugLOO=false;     % flag for debug in Leave-One-Out cross-validation
        cvResults;          % structure used for storing the CV results
    end
    
    properties (Access = private)
        respV=[];            % responses prepared for training
        gradV=[];            % gradients prepared for training
        %
        flagG=false;      % flag for computing matrices with gradients
        parallelW=1;         % number of workers for using parallel version
        %
        requireRun=true;     % flag if a full building is required
        requireUpdate=false; % flag if an update is required
        forceGrad=false;     % flag for forcing the computation of 1st and 2nd derivatives of the kernel matrix
        %
        matrices;            % structure for storage of matrices (classical and factorized version)
        %
        factK='LL';      % factorization strategy (fastest: LL (Cholesky))
        %
        debugCV=false;      % flag for the debugging process of the Cross-Validation
        %
        requireCompute=true;   % flag used for establishing the status of computing
    end
    properties (Dependent,Access = private)
        nS;                 % number of sample points
        nP;               % dimension of the problem
        parallelOk=false;    % flag for using parallel version
        estimOn=false;      %flag for estimation of the internal parameters
        %
        typeLOO;            % type of LOO criterion used (mse (default),wmse,lpp)
    end
    properties (Dependent)
        Kcond;              % condition number of the kernel matrix
    end
    
    methods
        %% Constructor
        function obj=SVR(samplingIn,respIn,gradIn,kernIn,varargin)
            %load data
            obj.sampling=samplingIn;
            obj.resp=respIn;
            if nargin>2;obj.grad=gradIn;end
            if nargin>3;obj.kernelFun=kernIn;end
            if nargin>4;obj.manageOpt(varargin);end
            %if everything is ok then train
            obj.train();
        end
        
        %% function for dealing with the the input arguments of the class
        function manageOpt(obj,optIn)
            fun=@(x)isa(x,'MissData');
            %look for the missing data class (MissData)
            sM=find(cellfun(fun,optIn)~=false);
            if ~isempty(sM);obj.missData=optIn{sM};end
            %look for the information concerning the metamodel (class initMeta)
            fun=@(x)isa(x,'initMeta');
            sM=find(cellfun(fun,optIn)~=false);
            if ~isempty(sM);obj.metaData=optIn{sM};end
        end
        
        %% setters
        function set.paraVal(obj,pVIn)
            if isempty(obj.paraVal)
                obj.fCompute;
            else
                if ~all(obj.paraVal==pVIn)
                    obj.fCompute;
                    obj.paraVal=pVIn;
                end
            end
        end
        
        %% getters
        function nS=get.nS(obj)
            nS=numel(obj.resp);
        end
        function nP=get.nP(obj)
            nP=size(obj.sampling,2);
        end
        function fl=get.estimOn(obj)
            fl=false;
            if ~isempty(obj.metaData)
                fl=obj.metaData.estim.on;
            end
        end
        
        %% getter for GSVR building
        function flagG=get.flagG(obj)
            flagG=~isempty(obj.grad);
        end
        
        %% getter for the condition number of the kernel matrix
        function valC=get.Kcond(obj)
            valC=condest(obj.K);
        end
        
        %% getter for the type of LOO criterion
        function tt=get.typeLOO(obj)
            typeG=obj.metaData.estim.type;
            tt='mse';   %default value
            if ~isempty(regexp(typeG,'cv','ONCE'))c
                if numel(typeG)>2
                    tt=typeG(3:end);
                end
            end
        end
        
        %% add new sample points, new responses and new gradients
        function addSample(obj,newS)
            obj.sampling=[obj.sampling;newS];
        end
        function addResp(obj,newR)
            obj.resp=[obj.resp;newR];
        end
        function addGrad(obj,newG)
            obj.grad=[obj.grad;newG];
        end
        
        %% check if there is missing data
        function flagM=checkMiss(obj)
            flagM=false;
            if ~isempty(obj.missData)
                flagM=obj.missData.on;
            end
        end
        %% check if there is missing newdata
        function flagM=checkNewMiss(obj)
            flagM=false;
            if ~isempty(obj.missData)
                flagM=obj.missData.onNew;
            end
        end
        
        %% fix flag for computing
        function fCompute(obj)
            obj.requireCompute=true;
        end
        
        %% get value of the internal parameters
        function pV=getParaVal(obj)
            if isempty(obj.paraVal)
                %w/o estimation, the initial values of hyperparameters are chosen
                switch obj.kernelFun
                    case {'expg','expgg'}
                        obj.paraVal=[obj.metaData.para.l.Val obj.metaData.para.p.Val];
                    case {'matern'}
                        obj.paraVal=[obj.metaData.para.l.Val obj.metaData.para.nu.Val];
                    otherwise
                        obj.paraVal=obj.metaData.para.l.Val;
                end
            end
            pV=obj.paraVal;
        end
        
        
        
        %% build kernel matrix and remove missing part
        function K=buildMatrix(obj,paraValIn)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Build of the SVR/GSVR matrix
            if obj.flagG
                %for GSVR
                [KK,KKd,KKdd]=obj.kernelMatrix.buildMatrix(paraValIn);
                %remove missing data
                if obj.checkMiss
                    KK=obj.missData.removeRM(KK);
                    KKd=obj.missData.removeRV(KKd);
                    KKdd=obj.missData.removeGM(KKdd);
                end
                %assemble matrices
                obj.K=[KK -KKd;-KKd' -KKdd];
                Psi=[KK -KK;-KK KK];
                PsiDo=-[KKd -KKd; -KKd KKd];
                PsiDDo=-[KKdd -KKdd;-KKdd KKdd];
                obj.PsiT=[Psi PsiDo;PsiDo' PsiDDo];
            else
                [obj.K]=obj.kernelMatrix.buildMatrix(paraValIn);
                %remove missing data
                if obj.checkMiss
                    obj.K=obj.missData.removeRM(obj.K);
                end
                %
                obj.PsiT=[obj.K -obj.K;-obj.K obj.K];
            end
            %
            K=obj.K;
            %
        end
        

        %% core of SVR computation using no factorization
        function coreClassical(obj)
            %coefficients for detecting Support vector
            epsM=eps;
            %load data
            ns=obj.nS;
            np=obj.nP;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Solving the Convex Constrained Quadaratic Optimization problem
            [solQP, obj.fVal, obj.exitFlag, lmQP]=ExecQP(obj.PsiT,obj.CC,...
                obj.Aineq,obj.bineq,...
                obj.Aeq,obj.beq,...
                obj.lb,obj.ub);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Specific data for none-gradient-based SVR
            obj.alphaRAW=solQP(1:2*ns);
            obj.alphaPM=obj.alphaRAW(1:ns)-obj.alphaRAW(ns+1:2*ns);
            obj.alphaPP=obj.alphaRAW(1:ns)+obj.alphaRAW(ns+1:2*ns);
           
            %find support vectors with specific property
            svPM=find(abs(obj.alphaPM)>obj.lb(1:ns)+epsM);
            svPP=find(obj.alphaPP>obj.lb(1:ns)+epsM);
            
            %Unbounded SV's or free SV's
            svUSV=find(obj.alphaPP>obj.lb(1:ns)+epsM & obj.alphaPP<obj.ub(1:ns)-epsM);
            %Bounded SV's
            svBSV=find(obj.alphaPP<obj.lb(1:ns)+epsM | obj.alphaPP>obj.ub(1:ns)-epsM);
            
            %finding SV's corresponding to value of alpha situated in the middle of
            %[lb,ub]
            [svMidP,svMidPIX]=min(abs(abs(obj.alphaRAW(1:ns))-obj.ub(1:ns)/2));
            [svMidM,svMidMIX]=min(abs(abs(obj.alphaRAW(ns+1:2*ns))-obj.ub(ns+1:2*ns)/2));
            
            %in the case of gradient-based approach
            obj.lambdaPM=[];
            obj.lambdaPP=[];
            obj.lambdaRAW=[];
            iXsvT=svPM;
            iXsvPM=svPM;
            iXsvPP=svPP;
            obj.iXsvUSV=svUSV;
            obj.iXsvBSV=svBSV;
            %
            if obj.flagG
                obj.lambdaRAW=solQP(2*ns+1:end);
                obj.lambdaPM=obj.lambdaRAW(1:ns*np)-obj.lambdaRAW(ns*np+1:end);
                obj.lambdaPP=obj.lambdaRAW(1:ns*np)+obj.lambdaRAW(ns*np+1:end);
                %compute indexes of the the gradients associated to the support vectors
                liNp=1:np;
                repI=ones(np,1);
                iXDsvI=liNp(ones(numel(iXsvT),1),:)+np*(iXsvT(:,repI)-1);
                iXDsvI=iXDsvI';
                iXsvT=[svPM;ns+iXDsvI(:)];
                
                %find support vectors dedicated to gradients
                svDI=find(abs(obj.lambdaPM)>epsM);
                [svMiddP,svMiddPIX]=min(abs(abs(obj.lambdaRAW(1:ns*np)-obj.ub(2*ns+1:ns*(np+2))/2)));
                [svMiddM,svMiddMIX]=min(abs(abs(obj.lambdaRAW(ns*np+1:2*ns*np)-obj.ub(ns*(np+2)+1:2*ns*(1+np))/2)));
                
            end
            %Full data
            obj.FullAlphaLambdaPM=[obj.alphaPM;obj.lambdaPM];
            obj.FullAlphaLambdaPP=[obj.alphaPP;obj.lambdaPP];
            obj.FullAlphaLambdaRAW=solQP;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute epsilon
            %eM=0.5*(dataIn.used.resp(svMidPIX)...
            %    -dataIn.used.resp(svMidMIX)...
            %    -FullAlphaLambdaPM(iXsvT)'*PsiR(svMidPIX,iXsvT)'...
            %    +FullAlphaLambdaPM(iXsvT)'*PsiR(iXsvT,svMidMIX));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute the base term
            % SVRmuM=dataIn.used.resp(svMidPIX)...
            %     -eM*sign(alphaPM(svMidPIX))...
            %     -FullAlphaLambdaPM(iXsvT)'*PsiR(iXsvT,svMidPIX);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %lagrange multipliers give the values of mu and epsilon
            obj.e=lmQP.ineqlin(1);
            obj.xiTau=lmQP.lower;
            %e
            obj.SVRmu=lmQP.eqlin;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Number of Unbounded and Bounded SVs
            obj.nbUSV=numel(obj.iXsvUSV);
            obj.nbBSV=numel(obj.iXsvBSV);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Build matrices
            %remove bounded supports vectors
            obj.PsiUSV=obj.K(obj.iXsvUSV(:),obj.iXsvUSV(:));
            obj.KUSV=[obj.PsiUSV ones(obj.nbUSV,1);ones(1,obj.nbUSV) 0];
            obj.iKUSV=inv(obj.KUSV);
        end
        
        %% build factorization, solve the SVR problem and evaluate the log-likelihood
        function compute(obj,paraValIn)
            if nargin==1
                paraValIn=obj.paraVal;
            else
                obj.paraVal=paraValIn;
            end
            %
            if obj.requireCompute
                %build the kernel Matrix
                obj.buildMatrix(paraValIn);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %solve the SVR problem
                obj.coreClassical;
                %
            end
        end
        
        %% Compute the the Span Bound of the LOO error for SVR/GSVR
        %from Vapnik & Chapelle 2000 / Chapelle, Vapnik, Bousquet & S. Mukherjee 2002/Chang & Lin 2005
        function spanBound=sb(obj,paraValIn,type)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %various situations
            modFinal=true;
            if nargin==3
                switch type
                    case 'final'    %final mode (compute variances)
                        modFinal=true;
                    otherwise
                        modFinal=false;
                end
            end
            if modFinal;countTime=mesuTime;end
            %%
            if nargin==1;paraValIn=obj.paraVal;end
            %compute matrices
            obj.compute(paraValIn);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %size of the kernel matrix
            sizePsi=size(obj.K,1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Compute St
            %diagonal of inverse of KUSV 
            DiKSV=diag(obj.iKUSV);
            %compute St^2
            St2b=zeros(sizePsi,1);
            St2b(obj.iXsvUSV)=1./DiKSV(1:obj.nbUSV);
            if obj.nbBSV>0
                PsiBSV=obj.K(obj.iXsvBSV(:),obj.iXsvBSV(:));
                Vb=[obj.K(obj.iXsvUSV,obj.iXsvBSV); ones(1,obj.nbBSV)];
                St2b(obj.iXsvBSV)=diag(PsiBSV)-diag(Vb'*obj.iKUSV*Vb);
            end;
            
            spanBound=1/sizePsi...
                *(St2b'*obj.FullAlphaLambdaPP...
                +sum(obj.xiTau))...
                +obj.metaData.e0;
            
            if modFinal;countTime.stop;end
        end
        
        %% Compute Cross-Validation
        function cv=cv(obj)
            if ~obj.checkMiss
                obj.showInfo('cv');
                %
                countTime=mesuTime;
                %
                dataCV=obj.metaData;
                dataCV.estimOn=false;
                %store the values of the hyperparameters
                
                % Compute responses
                ZCV=zeros(size(obj.resp));
                varCV=zeros(size(obj.resp));
                GCV=zeros(size(obj.sampling));
                %
                for itS=1:obj.nS
                    %remove data
                    samplingCV=obj.sampling([1:(itS-1) (itS+1):end],:);
                    respCV=obj.resp([1:(itS-1) (itS+1):end]);
                    %
                    gradCV=[];
                    if ~isempty(obj.grad)
                        gradCV=obj.grad([1:(itS-1) (itS+1):end],:);
                    end
                    %
                    SVRCV=SVR(samplingCV,respCV,gradCV,obj.kernelFun,dataCV);
                    %
                    [ZCV(itS),GCV(itS,:),varCV(itS)]=SVRCV.eval(obj.sampling(itS,:));
                end
                % compute CV criteria
                cv=LOOCalcError(obj.resp,ZCV,varCV,obj.grad,GCV,obj.nS,obj.nP,obj.normLOO);
                %
                obj.showInfo('cvend');
                %
                %prepare cells for display
                txtC{1}='+++ Used norm for calculate CV-LOO';
                varC{1}=obj.normLOO;
                if obj.flagG
                    txtC{end+1}='+++ Error on responses';
                    varC{end+1}=cv.eloor;
                    txtC{end+1}='+++ Error on gradients';
                    varC{end+1}=cv.eloog;
                end
                txtC{end+1}='+++ Total error (MSE)';
                varC{end+1}=cv.eloot;
                txtC{end+1}='+++ PRESS';
                varC{end+1}=cv.press;
                txtC{end+1}='+++ mean SCVR (Total)';
                varC{end+1}=cv.scvr_mean;
                txtC{end+1}='+++ max SCVR (Total)';
                varC{end+1}=cv.scvr_max;
                txtC{end+1}='+++ min SCVR (Total)';
                varC{end+1}=cv.scvr_min;
                txtC{end+1}='+++ Adequation (Total)';
                varC{end+1}=cv.adequ;
                txtC{end+1}='+++ Mean of bias (Total)';
                varC{end+1}=cv.bm;
                dispTableTwoColumns(txtC,varC,'-');
                %
                countTime.stop;
            else
                Gfprintf(' +++ Missing data: unable to compute the CV criteria\n');
            end
        end           
                    
        %% Show the result of the CV
        function showCV(obj)
            %use QQ-plot
            opt.newfig=false;
            figure;
            subplot(1,3,1);
            opt.title='Normalized data (CV R)';
            QQplot(obj.resp,obj.cvResults.cvZR,opt);
            subplot(1,3,2);
            opt.title='Normalized data (CV F)';
            QQplot(obj.resp,obj.cvResults.cvZ,opt);
            subplot(1,3,3);
            opt.title='SCVR (Normalized)';
            opt.xlabel='Predicted' ;
            opt.ylabel='SCVR';
            SCVRplot(obj.cvResults.cvZR,obj.cvResults.scvrR,opt);
        end
        
        %% Estimate internal parameters
        function estimPara(obj)
            fun=@(x)obj.sb(x,'estim');
            
            obj.paraEstim=EstimPara(obj.nP,obj.metaData,fun);
            obj.lVal=obj.paraEstim.l.Val;
            obj.paraVal=obj.paraEstim.Val;
            if isfield(obj.paraEstim,'p')
                obj.pVal=obj.paraEstim.p.Val;
            end
            if isfield(obj.paraEstim,'nu')
                obj.nuVal=obj.paraEstim.nu.Val;
            end
        end
        
        %% prepare data for building (deal with missing data)
        function setData(obj)
            %load data
            ns=obj.nS;
            np=obj.nP;
            c0l=obj.metaData.c0;
            ckl=obj.metaData.ck;
            nuSVRl=obj.metaData.nuSVR;
            nuGSVRl=obj.metaData.nuGSVR;
            %Responses and gradients at sample points
            YYT=obj.resp;
            %remove missing response(s)
            if obj.checkMiss
                YYT=obj.missData.removeRV(YYT);
            end
            %
            der=[];
            if obj.flagG
                tmp=obj.grad';
                der=tmp(:);
                %remove missing gradient(s)
                if obj.checkMiss
                    der=obj.missData.removeGV(der);
                end
            end
            obj.YY=YYT;
            obj.YYD=der;
            %
            obj.YYtot=[YYT;der];
            obj.CC=[-YYT;YYT;-der;der];
            %initialize kernel matrix
            obj.kernelMatrix=KernMatrix(obj.kernelFun,obj.sampling,obj.getParaVal);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Bounds of the dual variables (R: responses and G: gradients)
            obj.lbR=zeros(ns,1);
            cv0=c0l/ns*ones(ns,1);
            obj.ubR=cv0;
            if obj.checkMiss
                obj.ubR=obj.missData.removeRV(obj.ubR);
                obj.lbR=obj.missData.removeRV(obj.lbR);
            end
            %
            obj.lbG=[];
            obj.ubG=[];
            if obj.flagG
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Conditioning data for gradient-based approach
                if numel(ckl)==1
                    ck=ckl(:,ones(1,np));
                end
                obj.lbG=zeros(np*ns,1);
                ckV=ckl(:,ones(1,np*ns))/ns;
                obj.ubG=ckV(:);
                %
                if obj.checkMiss
                    obj.ubG=obj.missData.removeGV(obj.ubG);
                    obj.lbG=obj.missData.removeGV(obj.lbG);
                end
            end
            obj.ub=[obj.ubR;obj.ubR;obj.ubG;obj.ubG];
            obj.lb=[obj.lbR;obj.lbR;obj.lbG;obj.lbG];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Build equality constraints
            obj.AeqR=ones(1,ns);
            if obj.checkMiss
                obj.AeqR=obj.missData.removeRV(obj.AeqR');
                obj.AeqR=obj.AeqR';
            end
            obj.beq=0;
            obj.AeqG=[];
            if obj.flagG
                obj.AeqG=zeros(1,ns*np);
                if obj.checkMiss
                    obj.AeqG=obj.missData.removeGV(obj.AeqG');
                    obj.AeqG=obj.AeqG';
                end
            end
            obj.Aeq=[obj.AeqR -obj.AeqR obj.AeqG -obj.AeqG];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Build inequality constraints
            obj.AineqR=ones(1,ns);
            if obj.checkMiss
                obj.AineqR=obj.missData.removeRV(obj.AineqR');
                obj.AineqR=obj.AineqR';
            end
            obj.bineqR=c0l*nuSVRl;
            obj.bineqG=[];
            obj.AineqG=[];
            if obj.flagG
                obj.bineqG=ck(:)*nuGSVRl;
                obj.AineqG=repmat(eye(np),1,ns);
                %
                if obj.checkMiss
                    obj.AineqG=obj.missData.removeGV(obj.AineqG');
                    obj.AineqG=obj.AineqG';
                end
            end
            if ~isempty(obj.AineqG)
                sizA=size(obj.AineqG);
                obj.Aineq=[obj.AineqR obj.AineqR zeros(1,2*sizA(2));
                    zeros(sizA(1),2*ns) obj.AineqG obj.AineqG];
            else
                obj.Aineq=[obj.AineqR obj.AineqR];
            end
            obj.bineq=[obj.bineqR;obj.bineqG];
        end
        
        %% Prepare data for building (deal with missing data)
        function updateData(obj,samplingIn,respIn,gradIn)
            %number of new data
            NnS=numel(respIn);
            %load data
            np=obj.nP;
            c0l=obj.metaData.c0;
            ckl=obj.metaData.ck;
            %Responses and gradients at sample points
            YYT=respIn;
            %remove missing response(s)
            if obj.checkNewMiss
                YYT=obj.missData.removeRV(YYT,'n');
            end
            %
            der=[];
            if obj.flagG
                tmp=gradIn';
                der=tmp(:);
                %remove missing gradient(s)
                if obj.checkNewMiss
                    der=obj.missData.removeGV(der,'n');
                end
            end
            obj.YY=[obj.YY;-YYT];
            obj.YYD=[obj.YYD;-der];
            %
            obj.YYtot=[obj.YY;obj.YYD];
            obj.CC=[-obj.YY;obj.YY;-obj.YYD;obj.YYD];
            %initialize kernel matrix
            obj.kernelMatrix.updateMatrix(samplingIn);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Bounds of the dual variables (R: responses and G: gradients)
            nlbR=zeros(NnS,1);
            cv0=c0l/obj.nS*ones(NnS,1);
            obj.ubR=obj.ubR*(obj.nS-NnS)/obj.nS;
            if obj.checkMiss
                nlbR=obj.missData.removeRV(nlbR,'n');
                cv0=obj.missData.removeRV(cv0,'n');
            end
            obj.lbR=[obj.lbR;nlbR];
            obj.ubR=[obj.ubR;cv0];
            %
            obj.lbG=[];
            obj.ubG=[];
            if obj.flagG
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Conditioning data for gradient-based approach
                if numel(ckl)==1
                    ckl=ckl(:,ones(1,np));
                end
                nlbG=zeros(np*NnS,1);
                ckV=ckl(:,ones(1,np*NnS))/NnS;
                nubG=ckV(:);
                obj.ubG=obj.ubG*(obj.nS-NnS)/obj.nS;
                %
                if obj.checkMiss
                    nubG=obj.missData.removeGV(nubG,'n');
                    nlbG=obj.missData.removeGV(nlbG,'n');
                end
                obj.lbG=[obj.lbG;nlbG];
                obj.ubG=[obj.ubG;nubG];
            end
            obj.ub=[obj.ubR;obj.ubR;obj.ubG;obj.ubG];
            obj.lb=[obj.lbR;obj.lbR;obj.lbG;obj.lbG];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Build equality constraints
            nAeqR=ones(1,NnS);
            if obj.checkMiss
                nAeqR=obj.missData.removeRV(nAeqR','n');
                nAeqR=nAeqR';
            end
            %
            obj.AeqR=[obj.AeqR nAeqR];
            if obj.flagG
                nAeqG=zeros(1,NnS*np);
                if obj.checkMiss
                    nAeqG=obj.missData.removeGV(nAeqG','n');
                    nAeqG=nAeqG';
                end
                obj.AeqG=[obj.AeqG nAeqG];
            end
            obj.Aeq=[obj.AeqR -obj.AeqR obj.AeqG -obj.AeqG];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Build inequality constraints
            nAineqR=ones(1,NnS);
            if obj.checkMiss
                nAineqR=obj.missData.removeRV(nAineqR','n');
                nAineqR=nAineqR';
            end
            %
            obj.AineqR=[obj.AineqR nAineqR];
            if obj.flagG
                nAineqG=repmat(eye(np),1,NnS);
                %
                if obj.checkMiss
                    nAineqG=obj.missData.removeGV(nAineqG','n');
                    nAineqG=nAineqG';
                end
                obj.AineqG=[obj.AineqG nAineqG];
            end
            if ~isempty(obj.AineqG)
                sizA=size(obj.AineqG);
                obj.Aineq=[obj.AineqR obj.AineqR zeros(1,2*sizA(2));
                    zeros(sizA(1),2*obj.nS) obj.AineqG obj.AineqG];
            else
                obj.Aineq=[obj.AineqR obj.AineqR];
            end
        end
        
        %% Building/training metamodel
        function train(obj)
            obj.showInfo('start');
            %Prepare data
            obj.setData;
            % estimate the internal parameters or not
            if obj.estimOn
                obj.estimPara;
            else
                obj.compute;
            end
            %
            obj.requireCompute=false;
            %
            obj.showInfo('end');
            %
            %obj.cv();
            %
            if obj.metaData.cvDisp
            %    obj.showCV();
            end
        end
        
        %% Building/training the updated metamodel
        function trainUpdate(obj,samplingIn,respIn,gradIn)
            %Prepare data
            obj.updateData(samplingIn,respIn,gradIn);
            % estimate the internal parameters or not
            if obj.estimOn
                obj.estimPara;
            else
                obj.compute;
            end
            %
            obj.requireCompute=false;
            %
            obj.showInfo('end');
            %
%            obj.cv();
            %
            if obj.metaData.cvDisp
 %               obj.showCV();
            end
        end
        
        
        %% Update metamodel
        function update(obj,newSample,newResp,newGrad,newMissData)
            obj.showInfo('update');
            obj.fCompute;
            %add new sample, responses and gradients
            obj.addSample(newSample);
            obj.addResp(newResp);
            if nargin>3;obj.addGrad(newGrad);end
            if nargin>4;obj.missData=newMissData;end
            if nargin<4;newGrad=[];end
            %update the data and compute
            obj.trainUpdate(newSample,newResp,newGrad);
        end
        
        %% Evaluation of the metamodel
        function [Z,GZ,variance]=eval(obj,X)
            %computation of thr gradients or not (depending on the number of output variables)
            if nargout>=2
                calcGrad=true;
            else
                calcGrad=false;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ns=obj.nS;
            np=obj.nP;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SVR/GSVR
            %%compute response provided by the metamodel at the non sample point
            %definition des dimensions of the matrix/vector for SVR or GSVR
            if obj.flagG
                sizeMatVec=ns*(np+1);
            else
                sizeMatVec=ns;
            end
            
            %kernel (correlation) vector between sample point and the non sample point
            rr=zeros(sizeMatVec,1);
            if calcGrad
                jr=zeros(sizeMatVec,np);
            end
            %SVR/GSVR
            if obj.flagG
                if calcGrad  %if compute gradients
                    %evaluate kernel function
                    [ev,dev,ddev]=obj.kernelMatrix.buildVector(X,obj.paraVal);
                    rr(1:ns)=ev;
                    rr(ns+1:sizeMatVec)=-reshape(dev',1,ns*np);
                    
                    %derivative of the kernel vector between sample point and the non sample point
                    jr(1:ns,:)=dev;
                    
                    % second derivatives
                    matDer=zeros(np,np*ns);
                    for mm=1:ns
                        matDer(:,(mm-1)*np+1:mm*np)=ddev(:,:,mm);
                    end
                    jr(ns+1:sizeMatVec,:)=-matDer';
                    
                    %if missing data
                    if obj.checkMiss
                        rr=obj.missData.removeGRV(rr);
                        jr=obj.missData.removeGRV(jr);
                    end
                else %otherwise
                    [ev,dev]=obj.kernelMatrix.buildVector(X,obj.paraVal);
                    rr(1:ns)=ev;
                    rr(ns+1:sizeMatVec)=-reshape(dev',1,ns*np);
                    %if missing data
                    if obj.checkMiss
                        rr=obj.missData.removeGRV(rr);
                    end
                end
            else
                if calcGrad  %if the gradients will be computed
                    [rr,jr]=obj.kernelMatrix.buildVector(X,obj.paraVal);
                    %if missing data
                    if obj.checkMiss
                        rr=obj.missData.removeRV(rr);
                        jr=obj.missData.removeRV(jr);
                    end
                else %otherwise
                    rr=obj.kernelMatrix.buildVector(X,obj.paraVal);
                    %if missing data
                    if obj.checkMiss
                        rr=obj.missData.removeRV(rr);
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %evaluation of the surrogate model at point X
            Z=obj.SVRmu+obj.FullAlphaLambdaPM'*rr;
            if calcGrad
                GZ=obj.FullAlphaLambdaPM'*jr;
            end
            %compute variance
            if nargout >=3
                variance=obj.computeVariance(rr);
            end
        end
        
        %% compute MSE
        function variance=computeVariance(obj,rr)
            %intrinsic variance
            c0=obj.metaData.c0;
            e0=obj.metaData.e0;
            varianceI=2/c0^+1/3*e0^2*(3+e0*c0)/(e0*c0+1);
            
            %reduction to the unbounded support vectors
            %depending on gradient- or none-gradient-based GSVR
            %remove bounded supports vectors
            rrUSV=rr(obj.iXsvUSV(:));
            
            %variance due to the approximation
            varianceS=1-rrUSV'/obj.PsiUSV*rrUSV;
            variance=varianceI+varianceS;
        end
        
        %% Show information in the console
        function showInfo(obj,type)
            switch type
                case {'start','START','Start'}
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Display Building information
                    textd='++ Type: ';
                    textf='';
                    Gfprintf('\n%s\n',[textd 'Support Vector Regression ((G)SVR)' textf]);
                    %
                    Gfprintf('>>> Building : ');
                    dispTxtOnOff(obj.flagG,'GSVR','SVR',true);
                    Gfprintf('>> Kernel function: %s\n',obj.kernelFun);
                    %
                    if dispTxtOnOff(obj.metaData.cv.on,'>> CV: ',[],true)
                        dispTxtOnOff(obj.metaData.cv.full,'>> Computation all CV criteria: ',[],true);
                        dispTxtOnOff(obj.metaData.cv.disp,'>> Show CV: ',[],true);
                    end
                    %
                    dispTxtOnOff(obj.metaData.recond,'>> Correction of matrix condition number:',[],true);
                    if dispTxtOnOff(obj.metaData.estim.on,'>> Estimation of the hyperparameters: ',[],true)
                        Gfprintf('>> Algorithm for estimation: %s\n',obj.metaData.estim.method);
                        Gfprintf('>> Bounds: [%d , %d]\n',obj.metaData.para.l.Min,obj.metaData.para.l.Max);
                        switch obj.kernelFun
                            case {'expg','expgg'}
                                Gfprintf('>> Bounds for exponent: [%d , %d]\n',obj.metaData.para.p.Min,obj.metaData.para.p.Max);
                            case 'matern'
                                Gfprintf('>> Bounds for nu (Matern): [%d , %d]\n',obj.metaData.para.nu.Min,obj.metaData.para.nu.Max);
                        end
                        dispTxtOnOff(obj.metaData.estim.aniso,'>> Anisotropy: ',[],true);
                        dispTxtOnOff(obj.metaData.estim.dispIterCmd,'>> Show estimation steps in console: ',[],true);
                        dispTxtOnOff(obj.metaData.estim.dispIterGraph,'>> Plot estimation steps: ',[],true);
                    else
                        Gfprintf('>> Value(s) hyperparameter(s):');
                        fprintf('%d',obj.metaData.para.l.Val);
                        fprintf('\n');
                        switch obj.kernelFun
                            case {'expg','expgg'}
                                Gfprintf('>> Value of the exponent:');
                                fprintf(' %d',obj.metaData.para.p.Val);
                                fprintf('\n');
                            case {'matern'}
                                Gfprintf('>> Value of nu (Matern): %d \n',obj.metaData.para.nu.Val);
                        end
                    end
                    %
                    Gfprintf('\n');
                case {'update'}
                    Gfprintf(' ++ Update SVR\n');
                case {'cv','CV'}
                    Gfprintf(' ++ Run final Cross-Validation\n');
                case {'cvend','CVend'}
                    Gfprintf(' ++ END computation of Cross-Validation\n');
                case {'end','End','END'}
                    Gfprintf(' ++ END building SVR\n');
            end
        end
    end
end


%% function for display information
function boolOut=dispTxtOnOff(boolIn,txtInTrue,txtInFalse,returnLine)
boolOut=boolIn;
if nargin==2
    txtInFalse=[];
    returnLine=false;
elseif nargin==3
    returnLine=false;
end
if isempty(txtInFalse)
    Gfprintf('%s',txtInTrue);if boolIn; fprintf('Yes');else, fprintf('No');end
else
    if boolIn; fprintf('%s',txtInTrue);else, fprintf('%s',txtInFalse);end
end
if returnLine
    fprintf('\n');
end
end

%function display table with two columns (first must be text)
function dispTableTwoColumns(tableA,tableB,separator)
%size of every components in tableA
sizeA=cellfun(@numel,tableA);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+2;
if nargin>2
    spaceTxt=separator;
else
    spaceTxt=' ';
end
%display table
for itT=1:numel(tableA)
    if ischar(tableB{itT})
        mask='%s%s%s\n';
    elseif isinteger(tableB{itT})
        mask='%s%s%i\n';
    else
        mask='%s%s%+5.4e\n';
    end
    %
    Gfprintf(mask,tableA{itT},[' ' spaceTxt(ones(1,spaceA(itT))) ' '],tableB{itT});
end
end

%specific execution of Quadratic Programming depending on Matlab/Octave
function [solQP, fval, exitflag, lmQP]=ExecQP(PsiT,CC,AA,bb,Aeq,beq,lb,ub)
if isOctave
[solQP, fval, info, lambda] = qp(zeros(size(CC)),PsiT,CC,Aeq,beq,lb,ub,[], AA, bb);
exitflag=info.info;
lmQP.ineqlin=lambda((end-numel(bb)+1):end);
lmQP.eqlin=-lambda(1:numel(beq));
lmQP.lower=lambda(numel(beq)+(1:numel(lb)));
lmQP.upper=lambda(numel(beq)+numel(lb)+(1:numel(ub)));
else
opts = optimoptions('quadprog','Diagnostics','off','Display','none');
[solQP,fval,exitflag,~,lmQP]=quadprog(PsiT,CC,AA,bb,Aeq,beq,lb,ub,[],opts);
end
end
