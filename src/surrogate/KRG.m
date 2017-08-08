%% class for kriging/cokriging metamodel
% KRG: kriging
% GKRG: gradient-based kriging
% L. LAURENT -- 07/08/2017 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

classdef KRG < handle
    properties
        sampling=[];        % sample points
        resp=[];            % sample responses
        grad=[];            % sample gradients
        %
        missData;           % class for missing data
        krgLS;              % class for polynomial regression
        kernelMatrix;       % class for kernel matrix
        metaData;           % class for parameter of the metamodels
        %
        paraEstim;          % structure for all information obtained from the estimation of the internal parameters
        %
        YY=[];              % vector of responses and gradients
        K=[];               % kernel matrix
        %
        beta=[];            % regressors of the kriging generalized Least-Square
        gamma=[];           % coefficients of the stochastic prt of the kriging
        %
        polyOrder=0;        % polynomial order
        kernelFun='sexp';   % kernel function
        %
        paraVal=[];         % internal parameters used for building (fixed or estimated)
        lVal=[];            % internal parameters: length
        pVal=[];            % internal parametersfor generalized squared exponential
        nuVal=[];           % internal parameter for Matérn function
        %
        normLOO='L2';       % norm used for Leave-One-Out cross-validation
        debugLOO=false;     % flag for debug in Leave-One-Out cross-validation
    end
    
    properties (Access = private)
        respV=[];            % responses prepared for training
        gradV=[];            % gradients prepared for training
        %
        flagGKRG=false;      % flag for computing matrices with gradients
        parallelW=1;         % number of workers for using parallel version
        %
        requireRun=true;     % flag if a full building is required
        requireUpdate=false; % flag if an update is required
        forceGrad=false;     % flag for forcing the computation of 1st and 2nd derivatives of the kernel matrix
        %
        RK=[];                  % matrix from factorization
        PK=[];                  % matrix from factorization
        QK=[];              % matrix from factorization
        LK=[];              % matrix from factorization
        UK=[];              % matrix from factorization
    end
    properties (Dependent,Access = private)
        NnS;               % number of new sample points
        nS;                 % number of sample points
        nP;               % dimension of the problem
        parallelOk=false;    % flag for using parallel version
        estimOn=false;      %flag for estimation of the internal parameters
        %
    end
    properties (Dependent)
        Kcond;              % condition number of the kernel matrix
    end
    
    methods
        %% Constructor
        function obj=KRG(samplingIn,respIn,gradIn,orderIn,kernIn,optIn)
            %load data
            obj.sampling=samplingIn;
            obj.resp=respIn;
            if nargin>2;obj.grad=gradIn;end
            if nargin>3;obj.polyOrder=orderIn;end
            if nargin>4;obj.kernelFun=kernIn;end
            if nargin>5;obj.manageOpt(optIn);end
            %if everything is ok then train
            obj.train();
        end
        
        
        %% setters
        
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
        
        %% getter for GKRG building
        function flagG=get.flagGKRG(obj)
            flagG=~isempty(obj.grad);
        end
        
        %% getter for the condition number of the kernel matrix
        function valC=get.Kcond(obj)
            valC=condest(obj.K);
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
        
        %% manage options
        function manageOpt(obj,optIn)
            if isempty(obj.paraMeta);obj.paraMeta=optIn;end
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
                pV=obj.paraVal;
            end
        end
        
        %% prepare data for building (deal with missing data)
        function setData(obj)
            %Responses and gradients at sample points
            YYT=obj.resp;
            %remove missing response(s)
            if obj.checkMiss
                YYT=obj.missData.removeRV(YYT);
            end
            %
            der=[];
            if obj.flagGKRG
                tmp=obj.grad';
                der=tmp(:);
                %remove missing gradient(s)
                if obj.checkMiss
                    der=obj.missData.removeGV(der);
                end
            end
            obj.YY=[YYT;der];
            %build regression operators
            obj.krgLS=xLS(obj.sampling,obj.resp,obj.grad,obj.polyOrder);
            %initialize kenerl matrix
            obj.kernelMatrix=KernMatrix(obj.kernelFun,obj.sampling,obj.getParaVal);
        end
        
        
        %% build kernel matrix, factorization, solve the kriging problem and evaluate the log-likelihood
        function [logLi,Li,liSack]=compute(obj,paraValIn)
            %in the case of GKRG
            if obj.flagGKRG
                [KK,KKd,KKdd]=obj.kernelMatrix.buildMatrix(paraValIn);
                obj.K=[KK -KKd;-KKd' -KKdd];
            else
                [obj.K]=obj.kernelMatrix.buildMatrix(paraValIn);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Improve condition number of the KRG/GKRG Matrix
            if obj.metaData.recond
                obj.K=obj.K+coefRecond*speye(size(obj.K));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Factorization of the matrix
            switch factKK
                case 'QR'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %QR factorization
                    [obj.QK,obj.RK,obj.PK]=qr(obj.K);
                    %
                    diagRK=diag(obj.RK);
                    detK=abs(prod(diagRK)); %Q is an unitary matrix
                    logDetK=sum(log(abs(diagRK)));
                    %
                    QtK=obj.QK';
                    yQ=QtK*obj.YY;
                    fctQ=QtK*obj.krgLS.fct;
                    fcK=dataIn.build.fct'*obj.PK/obj.RK;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %compute beta coefficient
                    fcCfct=fcK*fctQ;
                    block2=fcK*yQ;
                    obj.beta=fcCfct\block2;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %compute gamma coefficient
                    obj.gamma=obj.PK*(obj.RK\(yQ-fctQ*obj.beta));
                case 'LU'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %LU factorization
                    [obj.LK,obj.UK,obj.PK]=lu(obj.K,'vector');
                    %
                    diagUK=diag(obj.UK);
                    detK=prod(diagUK); %L is a quasi-triangular matrix and contains ones on the diagonal
                    logDetK=sum(log(abs(diagUK)));
                    %
                    yP=obj.YY(obj.PK,:);
                    fctP=obj.krgLS.fct(obj.PK,:);
                    yL=obj.LK\yP;
                    fctL=obj.LK\fctP;
                    fcU=obj.krgLS.fct'/obj.UK;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %compute beta coefficient
                    fcCfct=fcU*fctL;
                    block2=fcU*yL;
                    obj.beta=fcCfct\block2;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %compute gamma coefficient
                    obj.gamma=obj.UK\(yL-fctL*obj.beta);
                case 'LL'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Cholesky's fatorization
                    %%% to be degugged
                    obj.LK=chol(obj.K,'lower');
                    %
                    diagLK=diag(obj.LK);
                    detK=prod(diagLK)^2;
                    logDetK=2*sum(log(abs(diagLK)));
                    %
                    LtK=obj.LK';
                    yL=obj.LK\obj.YY;
                    fctL=obj.LK\obj.krgLS.fct;
                    fcL=obj.krgLS.fct'/LtK;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %compute beta coefficient
                    fcCfct=fcL*fctL;
                    block2=fcL*yL;
                    obj.beta=fcCfct\block2;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %compute gamma coefficient
                    obj.gamma=LtK\(yL-fctL*obj.beta);
                otherwise
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %classical approach
                    eigVal=eig(obj.K);
                    detK=prod(eigVal);
                    logDetK=sum(log(eigVal));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %compute gamma and beta coefficients
                    fcC=obj.krgLS.fct'/obj.K;
                    fcCfct=fcC*obj.krgLS.fct;
                    block2=((obj.krgLS.fct'/KK)*obj.YY);
                    obj.beta=fcCfct\block2;
                    obj.gamma=obj.K\(obj.YY-obj.krgLS.fct*obj.beta);
            end
            %size of the kernel matrix
            sizeK=size(obj.K,1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %variance of the Gaussian process
            obj.sig2=1/sizeK*...
                ((obj.YY-obj.krgLS.fct*obj.beta)'*obj.gamma);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %computation of the log-likelihood (Jones 1993 / Leary 2004)
            logLi=sizeK/2*log(2*pi*obj.sig2)+1/2*logDetK+sizeK/2;
            if nargout>=2
                %computation of the likelihood (Jones 1993 / Leary 2004)
                Li=1/((2*pi*obj.sig2)^(sizeK/2)*sqrt(detK))*exp(-sizeK/2);
            end
            %computation of the log-likelihood from Sacks 1989
            if nargout==3
                liSack=abs(detK)^(1/sizeK)*obj.sig2;
            end
            if isinf(logLi)||isnan(logLi)
                logLi=1e16;
            end
        end
        
        %% Compute Cross-Validation
        function cv(obj,type)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %various situations
            modDebug=debugP;modStudy=obj.metaData.cv.full;modFinal=false;
            if nargin==2
                switch type
                    case 'debug'  %debug mode (display criteria)
                        Gfprintf('+++ CV KRG in DEBUG mode\n');
                        modDebug=true;
                    case 'study'  %study mode (use both methods for calculating criteria)
                        modStudy=true;
                    case 'estim'  %estimation mode
                        modStudy=false;
                    case 'final'    %final mode (compute variances)
                        modFinal=true;
                end
            else
                modFinal=true;
            end
            if modFinal;countTime=mesuTime;end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %load variables
            np=obj.nP;
            ns=obj.nS;
            availGrad=obj.flagGKRG;            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Adaptation of the Rippa's method (Rippa 1999/Fasshauer 2007) form M. Bompard (Bompard 2011)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %coefficient of (co)Kriging
            coefKRG=obj.gamma;
            %partial extraction of the diagonal of the inverse of the kernel matrix
            switch obj.factKK
                case 'QR'
                    fcC=obj.fcK*obj.QtK;
                    diagMK=diag(obj.RK\obj.QtK)-...
                        diag(fcC'*(obj.fcCfct\fcC));
                case 'LU'
                    fcC=obj.fcU/obj.LK;
                    diagMK=diag(obj.UK\inv(obj.LK))-...
                        diag(fcC'*(obj.fcCfct\fcC));
                case 'LL'
                    fcC=obj.fcL/obj.LK;
                    diagMK=diag(obj.LK\inv(obj.LK))-...
                        diag(fcC'*(obj.fcCfct\fcC));
                otherwise
                    diagMK=diag(inv(obj.K))-...
                        diag(obj.fcC'*(obj.fcCfct\obj.fcC));
            end
            %vectors of the distances on removed sample points (reponses et gradients)
            esI=coefKRG./diagMK;
            esR=esI(1:ns);
            if availGrad;esG=esI(ns+1:end);end
            
            %computation of the LOO criteria (various norms)
            switch obj.normLOO
                case 'L1'
                    cv.then.press=esI'*esI;
                    cv.then.eloot=1/numel(esI)*sum(abs(esI));
                    cv.press=cv.then.press;
                    cv.eloot=cv.then.eloot;
                    if availGrad
                        cv.then.eloor=1/ns*sum(abs(esR));
                        cv.then.eloog=1/(ns*np)*sum(abs(esG));
                        cv.eloor=cv.then.eloor;
                        cv.eloog=cv.then.eloog;
                    end
                    
                case 'L2' %MSE
                    cv.then.press=esI'*esI;
                    cv.then.eloot=1/numel(esI)*(cv.then.press);
                    cv.press=cv.then.press;
                    cv.eloot=cv.then.eloot;
                    if availGrad
                        cv.then.press=esR'*esR;
                        cv.then.eloor=1/ns*(cv.then.press);
                        cv.then.eloog=1/(ns*np)*(esG'*esG);
                        cv.press=cv.then.press;
                        cv.eloor=cv.then.eloor;
                        cv.eloog=cv.then.eloog;
                    end
                case 'Linf'
                    cv.then.press=esI'*esI;
                    cv.then.eloot=1/numel(esI)*max(esI(:));
                    cv.press=cv.then.press;
                    cv.eloot=cv.then.eloot;
                    if availGrad
                        cv.then.press=esR'*esR;
                        cv.then.eloor=1/ns*max(esR(:));
                        cv.then.eloog=1/(ns*np)*max(esG(:));
                        cv.press=cv.then.press;
                        cv.eloor=cv.then.eloor;
                        cv.eloog=cv.then.eloog;
                    end
            end
            %mean of bias
            cv.bm=1/ns*sum(esR);
            %display information
            if modDebug||modFinal
                Gfprintf('\n=== CV-LOO using Rippa''s methods (1999, extension by Bompard 2011)\n');
                Gfprintf('+++ Used norm for calculate CV-LOO: %s\n',obj.normLOO);
                if availGrad
                    Gfprintf('+++ Error on responses %4.2e\n',cv.then.eloor);
                    Gfprintf('+++ Error on gradients %4.2e\n',cv.then.eloog);
                end
                Gfprintf('+++ Total error %4.2e\n',cv.then.eloot);
                Gfprintf('+++ PRESS %4.2e\n',cv.then.press);
            end
            
            
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if modFinal;countTime.stop;end
end
        end
        
        %% Show the result of the CV
        function showCV(obj)
            %use QQ-plot
            opt.newfig=false;
            figure;
            subplot(1,3,1);
            opt.title='Normalized data (CV R)';
            QQplot(dataBloc.used.resp,cvZR,opt);
            subplot(1,3,2);
            opt.title='Normalized data (CV F)';
            QQplot(dataBloc.used.resp,cvZ,opt);
            subplot(1,3,3);
            opt.title='SCVR (Normalized)';
            opt.xlabel='Predicted' ;
            opt.ylabel='SCVR';
            SCVRplot(cvZR,cv.final.scvr,opt);
        end

        
        
        %% Prepare data for building (deal with missing data)
        function updateData(obj,respIn,gradIn)
            %Responses and gradients at sample points
            YYT=respIn;
            %remove missing response(s)
            if obj.checkNewMiss
                YYT=obj.missData.removeRV(YYT,'n');
            end
            %
            der=[];
            if obj.flagGLS
                tmp=gradIn';
                der=tmp(:);
                %remove missing gradient(s)
                if obj.checkNewMiss
                    der=obj.missData.removeGV(der,'n');
                end
            end
            obj.YY=[obj.YY;YYT];
            obj.YYD=[obj.YYD;der];
        end
        
        %% Estimate internal parameters
        function estimPara(obj)
            obj.paraEstim=EstimPara(obj.nP,obj.metaData,obj.compute);
            obj.lVal=obj.paraEstim.l.Val;
            obj.paraVal=obj.paraEstim.Val;
            if isfield(obj.paraEstim,'p')
                obj.pVal=obj.paraEstim.p.Val;
            end
            if isfield(obj.paraEstim,'nu')
                obj.nuVal=obj.paraEstim.nu.Val;
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
            obj.showInfo('end');
        end
        
        %% Building/training the updated metamodel
        function trainUpdate(obj,samplingIn,respIn,gradIn)
            %Prepare data
            obj.updateData(respIn,gradIn);
            %Build regression matrix (for the trend model)
            
            %depending on the availability of the gradients
            if ~obj.flagGLS
                newVal=MultiMono(samplingIn,obj.polyOrder);
                if obj.checkNewMiss
                    %remove missing response(s)
                     newVal=obj.missData.removeRV(newVal,'n');
                end
                obj.valFunPoly=[obj.valFunPoly;newVal];
            else
                %gradient-based
                [MatX,MatDX]=MultiMono(samplingIn,obj.polyOrder);
                %remove lines associated to the missing data
                if obj.checkNewMiss
                    MatX=obj.missData.removeRV(MatX,'n');
                    MatDX=obj.missData.removeGV(MatDX,'n');
                end
                obj.valFunPoly=[obj.valFunPoly;MatX];
                obj.valFunPolyD=[obj.valFunPolyD;MatDX];
            end
            %compute regressors
            obj.compute();
        end
                         
        
        %% Update metamodel
        function update(obj,newSample,newResp,newGrad,newMissData)
            obj.showInfo('update');
            %add new sample, responses and gradients
            obj.addSample(newSample);
            obj.addResp(newResp);
            if nargin>3;obj.addGrad(newGrad);end
            if nargin>4;obj.missData=newMissData;end
            if nargin<4;newGrad=[];end
            %update the data and compute
            obj.trainUpdate(newSample,newResp,newGrad);
            obj.showInfo('end');
        end
        
        %% Evaluation of the metamodel
        function [Z,GZ]=eval(obj,U)
            calcGrad=false;
            if nargout>1
                calcGrad=true;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %regression matrix at the non-sample points
            if calcGrad
                [ff,jf]=MultiMono(U,obj.polyOrder);
            else
                [ff]=MultiMono(U,obj.polyOrder);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %evaluation of the surrogate model at point X
            Z=ff*obj.beta;
            if calcGrad
                %%verif in 2D+
                GZ=jf*obj.beta;
            end
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
                    Gfprintf('\n%s\n',[textd 'Kriging ((G)KRG)' textf]);
                    %
                    Gfprintf('>>> Building : ');
                    dispTxtOnOff(obj.flagGKRG,'GKRG','KRG',true);
                    Gfprintf('>> Kernel function: %s\n',obj.kernelFun);
                    Gfprintf('>> Deg : %i ',obj.polyOrder);
                    dispTxtOnOff(obj.polyOrder==0,'(Ordinary)','(Universal)',true);
                    %
                    if dispTxtOnOff(obj.cv.on,'>> CV: ',[],true)
                        dispTxtOnOff(obj.cv.full,'>> Computation all CV criteria: ',[],true);
                        dispTxtOnOff(obj.cv.disp,'>> Show CV: ',[],true);
                    end
                    %
                    dispTxtOnOff(obj.recond,'>> Correction of matrix condition:',[],true);
                    if dispTxtOnOff(obj.estim.on,'>> Estimation of the hyperparameters: ',[],true)
                        Gfprintf('>> Algorithm for estimation: %s\n',obj.estim.method);
                        Gfprintf('>> Bounds: [%d , %d]\n',obj.para.l.Min,obj.para.l.Max);
                        switch obj.kernelFun
                            case {'expg','expgg'}
                                Gfprintf('>> Bounds for exponent: [%d , %d]\n',obj.para.p.Min,obj.para.p.Max);
                            case 'matern'
                                Gfprintf('>> Bounds for nu (Matern): [%d , %d]\n',obj.para.nu.Min,obj.para.nu.Max);
                        end
                        dispTxtOnOff(obj.estim.aniso,'>> Anisotropy: ',[],true);
                        dispTxtOnOff(obj.estim.dispIterCmd,'>> Show estimation steps in console: ',[],true);
                        dispTxtOnOff(obj.estim.dispIterGraph,'>> Plot estimation steps: ',[],true);
                    else
                        Gfprintf('>> Value(s) hyperparameter(s):');
                        fprintf('%d',obj.para.l.Val);
                        fprintf('\n');
                        switch obj.kernelFun
                            case {'expg','expgg'}
                                Gfprintf('>> Value of the exponent:');
                                fprintf(' %d',obj.para.p.Val);
                                fprintf('\n');
                            case {'matern'}
                                Gfprintf('>> Value of nu (Matern): %d \n',obj.para.nu.Val);
                        end
                    end
                    %
                    Gfprintf('\n');
                case {'update'}
                    Gfprintf(' ++ Update xLS\n');
                case {'cv','CV'}
                case {'end','End','END'}
                    Gfprintf(' ++ END building xLS\n');
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