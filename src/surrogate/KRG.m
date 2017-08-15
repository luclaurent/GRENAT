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
        sig2=[];            % variance of the Gaussian Process
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
        matrices;            % structure for storage of matrices (classical and factorized version)
        %
        factK='LU';      % factorization strategy (fastest: LL (Cholesky))
        %
        debugCV=false;      % flag for the debugging process of the Cross-Validation
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
        function obj=KRG(samplingIn,respIn,gradIn,orderIn,kernIn,varargin)
            %load data
            obj.sampling=samplingIn;
            obj.resp=respIn;
            if nargin>2;obj.grad=gradIn;end
            if nargin>3;obj.polyOrder=orderIn;end
            if nargin>4;obj.kernelFun=kernIn;end
            if nargin>5;obj.manageOpt(varargin);end
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
            obj.krgLS=xLS(obj.sampling,obj.resp,obj.grad,obj.polyOrder,obj.missData);
            %initialize kernel matrix
            obj.kernelMatrix=KernMatrix(obj.kernelFun,obj.sampling,obj.getParaVal);
        end
        
        %% build kernel matrix and remove missing part
        function K=buildMatrix(obj,paraValIn)
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
                %coefficient for reconditionning (co)kriging matrix
                coefRecond=(10+size(obj.krgLS.XX,1))*eps;
                %
                obj.K=obj.K+coefRecond*speye(size(obj.K));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %remove missing parts
            if obj.checkMiss
                if obj.flagGKRG
                    obj.K=obj.missData.removeGRM(obj.K);
                else
                    obj.K=obj.missData.removeRM(obj.K);
                end
            end
            %
            K=obj.K;
            %
        end
        
        %% core of kriging computation using QR factorization
        function [detK,logDetK]=coreQR(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %QR factorization
            [obj.matrices.QK,obj.matrices.RK,obj.matrices.PK]=qr(obj.K);
            %
            diagRK=diag(obj.matrices.RK);
            detK=abs(prod(diagRK)); %Q is an unitary matrix
            logDetK=sum(log(abs(diagRK)));
            %
            obj.matrices.QtK=obj.matrices.QK';
            yQ=obj.matrices.QtK*obj.YY;
            fctQ=obj.matrices.QtK*obj.krgLS.XX;
            obj.matrices.fcK=obj.krgLS.XX'*obj.matrices.PK/obj.matrices.RK;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute beta coefficient
            obj.matrices.fcCfct=obj.matrices.fcK*fctQ;
            block2=obj.matrices.fcK*yQ;
            obj.beta=obj.matrices.fcCfct\block2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute gamma coefficient
            obj.gamma=obj.matrices.PK*(obj.matrices.RK\(yQ-fctQ*obj.beta));
        end
        %% core of kriging computation using LU factorization
        function [detK,logDetK]=coreLU(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %LU factorization
            [obj.matrices.LK,obj.matrices.UK,obj.matrices.PK]=lu(obj.K,'vector');
            %
            diagUK=diag(obj.matrices.UK);
            detK=prod(diagUK); %L is a quasi-triangular matrix and contains ones on the diagonal
            logDetK=sum(log(abs(diagUK)));
            %
            yP=obj.YY(obj.matrices.PK,:);
            fctP=obj.krgLS.XX(obj.matrices.PK,:);
            yL=obj.matrices.LK\yP;
            fctL=obj.matrices.LK\fctP;
            obj.matrices.fcU=obj.krgLS.XX'/obj.matrices.UK;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute beta coefficient
            obj.matrices.fcCfct=obj.matrices.fcU*fctL;
            block2=obj.matrices.fcU*yL;
            obj.beta=obj.matrices.fcCfct\block2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute gamma coefficient
            obj.gamma=obj.matrices.UK\(yL-fctL*obj.beta);
        end
        %% core of kriging computation using Cholesky (LL) factorization
        function [detK,logDetK]=coreLL(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Cholesky's fatorization
            %%% to be degugged
            obj.matrices.LK=chol(obj.K,'lower');
            %
            diagLK=diag(obj.matrices.LK);
            detK=prod(diagLK)^2;
            logDetK=2*sum(log(abs(diagLK)));
            %
            LtK=obj.matrices.LK';
            yL=obj.matrices.LK\obj.YY;
            fctL=obj.matrices.LK\obj.krgLS.XX;
            obj.matrices.fcL=obj.krgLS.XX'/LtK;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute beta coefficient
            obj.matrices.fcCfct=obj.matrices.fcL*fctL;
            block2=obj.matrices.fcL*yL;
            obj.beta=obj.matrices.fcCfct\block2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute gamma coefficient
            obj.gamma=LtK\(yL-fctL*obj.beta);
        end
        %% core of kriging computation using no factorization
        function [detK,logDetK]=coreClassical(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %classical approach
            eigVal=eig(obj.K);
            detK=prod(eigVal);
            logDetK=sum(log(eigVal));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute gamma and beta coefficients
            obj.matrices.fcC=obj.krgLS.XX'/obj.K;
            obj.matrices.fcCfct=obj.matrices.fcC*obj.krgLS.XX;
            block2=((obj.krgLS.XX'/obj.K)*obj.YY);
            obj.beta=obj.matrices.fcCfct\block2;
            obj.gamma=obj.K\(obj.YY-obj.krgLS.XX*obj.beta);
        end
        
        
        %% build factorization, solve the kriging problem and evaluate the log-likelihood
        function [detK,logDetK]=compute(obj,paraValIn)
            if nargin==1;paraValIn=obj.paraVal;end
            %build the kernel Matrix
            obj.buildMatrix(paraValIn);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Factorization of the matrix
            switch obj.factK
                case 'QR'
                    [detK,logDetK]=obj.coreQR;
                case 'LU'
                    [detK,logDetK]=obj.coreLU;
                case 'LL'
                    [detK,logDetK]=obj.coreLL;
                otherwise
                    [detK,logDetK]=obj.coreClassical;
            end
        end
        
        %% function evaluate likelihood
        function [logLi,Li,liSack]=likelihood(obj,paraValIn)
            if nargin==1;paraValIn=obj.paraVal;end
            %compute matrices
            [detK,logDetK]=obj.compute(paraValIn);
            %size of the kernel matrix
            sizeK=size(obj.K,1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %variance of the Gaussian process
            obj.sig2=1/sizeK*...
                ((obj.YY-obj.krgLS.XX*obj.beta)'*obj.gamma);
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
        function [crit,cv]=cv(obj,type)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %various situations
            modFinal=false;
            if nargin==2
                switch type
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
            switch obj.factK
                case 'QR'
                    fcC=obj.matrices.fcK*obj.matrices.QtK;
                    diagMK=diag(obj.matrices.RK\obj.matrices.QtK)-...
                        diag(fcC'*(obj.matrices.fcCfct\fcC));
                case 'LU'
                    fcC=obj.matrices.fcU/obj.matrices.LK;
                    diagMK=diag(obj.matrices.UK\inv(obj.matrices.LK))-...
                        diag(fcC'*(obj.matrices.fcCfct\fcC));
                case 'LL'
                    fcC=obj.matrices.fcL/obj.matrices.LK;
                    diagMK=diag(obj.matrices.LK\inv(obj.matrices.LK))-...
                        diag(fcC'*(obj.matrices.fcCfct\fcC));
                otherwise
                    diagMK=diag(inv(obj.K))-...
                        diag(obj.matrices.fcC'*(obj.matrices.fcCfct\obj.matrices.fcC));
            end
            %vectors of the distances on removed sample points (reponses and gradients)
            % formula from Rippa 1999/Dubrule 1983/Zhang 2010/Bachoc 2011
            esI=coefKRG./diagMK;
            esR=esI(1:ns);
            if availGrad;esG=esI(ns+1:end);end
            %vectors of the variance on removed sample points
            evI=obj.sig2./diagMK;
            evR=evI(1:ns);
            if availGrad;evG=evI(ns+1:end);end
            
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
                        cv.then.eloor=1/numel(esR)*(cv.then.press);
                        cv.then.eloog=1/(numel(esR)*np)*(esG'*esG);
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
                        cv.then.eloor=1/numel(esR)*max(esR(:));
                        cv.then.eloog=1/(numel(esR)*np)*max(esG(:));
                        cv.press=cv.then.press;
                        cv.eloor=cv.then.eloor;
                        cv.eloog=cv.then.eloog;
                    end
            end
            %SCVR Keane 2005/Jones 1998
            cv.scvr=(esI.^2)./evI;
            cv.scvr_min=min(cv.scvr(:));
            cv.scvr_max=max(cv.scvr(:));
            cv.scvr_mean=mean(cv.scvr(:));
            %scores from Bachoc 2011-2013/Zhang 2010
            cv.mse=cv.eloot;                    %minimize
            cv.wmse=1/numel(esI)*sum(cv.scvr);  %find close to 1
            cv.lpp=-sum(log(evI)+cv.scvr);      %maximize
            %%criterion of adequation (CAUTION of the norm!!!>> squared difference)
            diffA=esR.*esR./evR;
            cv.adequ=1/numel(esR)*sum(diffA);
            %mean of bias
            cv.bm=1/numel(esR)*sum(esR);
            %display information
            if modDebug||modFinal
                Gfprintf('\n=== CV-LOO using Rippa''s methods (1999, extension by Bompard 2011)\n');
                %prepare cells for display
                txtC{1}='+++ Used norm for calculate CV-LOO';
                varC{1}=obj.normLOO;
                if availGrad
                    txtC{end+1}='+++ Error on responses';
                    varC{end+1}=cv.then.eloor;
                    txtC{end+1}='+++ Error on gradients';
                    varC{end+1}=cv.then.eloog;
                end
                txtC{end+1}='+++ Total error (MSE)';
                varC{end+1}=cv.then.eloot;
                txtC{end+1}='+++ PRESS';
                varC{end+1}=cv.then.press;
                txtC{end+1}='+++ mean SCVR';
                varC{end+1}=cv.scvr_mean;
                txtC{end+1}='+++ max SCVR';
                varC{end+1}=cv.scvr_max;
                txtC{end+1}='+++ min SCVR';
                varC{end+1}=cv.scvr_min;
                txtC{end+1}='+++ adequation';
                varC{end+1}=cv.adequ;
                txtC{end+1}='+++ mean of bias';
                varC{end+1}=cv.bm;
                txtC{end+1}='+++ WMSE';
                varC{end+1}=cv.wmse;
                txtC{end+1}='+++ LPP';
                varC{end+1}=cv.lpp;
                dispTableTwoColumns(txtC,varC,'-');
            end
            %%
            obj.cv=cv;
            %
            switch type
                case 'mse'
                    crit=cv.mse;
                case 'wmse'
                    crit=cv.wmse;
                case 'lpp'
                    crit=cv.lpp;
            end
            
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if modFinal;countTime.stop;end
        end
        
        %% Show the result of the CV
        function showCV(obj)
            %use QQ-plot
            opt.newfig=false;
            figure;
            subplot(1,3,1);
            opt.title='Normalized data (CV R)';
            QQplot(obj.resp,cvZR,opt);
            subplot(1,3,2);
            opt.title='Normalized data (CV F)';
            QQplot(obj.resp,cvZ,opt);
            subplot(1,3,3);
            opt.title='SCVR (Normalized)';
            opt.xlabel='Predicted' ;
            opt.ylabel='SCVR';
            SCVRplot(cvZR,cv.scvr,opt);
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
            obj.paraEstim=EstimPara(obj.nP,obj.metaData,@(x)obj.likelihood(x));
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
            %
            obj.cv();
            %
            if obj.metaData.cvDisp
                obj.showCV();
            end
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
            %% KRG/GKRG
            %%compute response provided by the metamodel at the non sample point
            %definition des dimensions of the matrix/vector for KRG or GKRG
            if obj.flagGKRG
                sizeMatVec=ns*(np+1);
            else
                sizeMatVec=ns;
            end
            
            %kernel (correlation) vector between sample point and the non sample point
            rr=zeros(sizeMatVec,1);
            if calcGrad
                jr=zeros(sizeMatVec,np);
            end
            
            %KRG/GKRG
            if obj.flagGKRG
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
                    rr(ns+1:sizeMatVec)=reshape(dev',1,ns*np);
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
            %regression matrix at the non-sample points
            if calcGrad
                [ff,jf]=obj.krgLS.buildMatrixNonS(X);
            else
                [ff]=obj.krgLS.buildMatrixNonS(X);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %evaluation of the surrogate model at point X
            trZ=ff*obj.beta;
            stoZ=rr'*obj.gamma;
            Z=trZ+stoZ;
            if calcGrad
                %%verif in 2D+
                trGZ=jf*obj.beta;
                stoGZ=jr'*obj.gamma;
                GZ=trGZ+stoGZ;
            end
            %compute variance
            if nargout >=3
                variance=obj.computeVariance(rr,ff);
            end
        end
        
        %% compute MSE
        function variance=computeVariance(obj,rr,ff)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %compute the prediction variance (MSE) (Lophaven, Nielsen & Sondergaard
            %2004 / Marcelet 2008 / Chauvet 1999)
            if ~dispWarning;warning off all;end
            %depending on the factorization
            switch obj.factKK
                case 'QR'
                    rrP=rr'*obj.PK;
                    Qrr=obj.QtK*rr;
                    u=obj.fcR*Qrr-ff';
                    variance=obj.sig2*(1-(rrP/obj.RK)*Qrr+...
                        u'/obj.fcCfct*u);
                case 'LU'
                    rrP=rr(obj.PK,:);
                    Lrr=obj.LK\rrP;
                    u=obj.fcU*Lrr-ff';
                    variance=obj.sig2*(1-(rr'/obj.UK)*Lrr+...
                        u'/obj.fcCfct*u);
                case 'LL'
                    Lrr=obj.LK\rr;
                    u=obj.fcL*Lrr-ff';
                    variance=obj.sig2*(1-(rr'/obj.LtK)*Lrr+...
                        u'/obj.fcCfct*u);
                otherwise
                    rKrr=obj.KK \ rr;
                    u=obj.fc*rKrr-ff';
                    variance=obj.sig2*(1+u'/obj.fcCfct*u - rr'*rKrr);
            end
            if ~dispWarning;warning on all;end
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
                    Gfprintf(' ++ Update KRG\n');
                case {'cv','CV'}
                case {'end','End','END'}
                    Gfprintf(' ++ END building KRG\n');
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
        mask='%s%s%5.4e\n';
    end
    %
    Gfprintf(mask,tableA{itT},[' ' spaceTxt(ones(1,spaceA(itT))) ' '],tableB{itT});
end
end
