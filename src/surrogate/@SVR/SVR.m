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
        sampling=[];         % sample points
        resp=[];             % sample responses
        grad=[];             % sample gradients
        %
        missData;            % class for missing data
        kernelMatrix;        % class for kernel matrix
        metaData;            % class for parameter of the metamodels
        %
        paraEstim;           % structure for all information obtained from the estimation of the internal parameters
        %
        YY=[];               % vector of responses
        YYD=[];              % vector of gradients
        YYtot=[];            % full vector of responses and gradients
        K=[];                % kernel matrix
        %
        PsiT=[];             % matrix of SVR convex quadratic problem
        %
        fVal;                % value of the objective function obtained after solving QP
        exitFlag;            % status flag of the QP optimizer
        CC;                  % second member of QP
        AineqR;              % inequality constraint matrix of QP
        bineqR;              % inequality constraint vector of QP
        AineqG;              % inequality constraint matrix of QP
        bineqG;              % inequality constraint vector of QP
        Aineq;               % inequality constraint matrix of QP
        bineq;               % inequality constraint vector of QP
        AeqR;                % equality constraint matrix of QP
        AeqG;                % equality constraint matrix of QP
        Aeq;                 % equality constraint matrix of QP
        beq;                 % equality vector of QP
        lbR;                 % lower bound of QP variables
        lbG;                 % lower bound of QP variables
        lb;                  % lower bound of QP variables
        ubR;                 % upper bound of QP variables
        ubG;                 % upper bound of QP variables
        ub;                  % upper bound of QP variables
        %
        alphaRAW;            % RAW alpha variables solution of QP (SVR)
        alphaPM;             % differences of alpha_i
        alphaPP;             % sums of alpha_i
        lambdaRAW;           % RAW lambda variables solution of QP (GSVR)
        lambdaPM;            % differences of lambda_i
        lambdaPP;            % sum of lambda_i
        FullAlphaLambdaPM;   % full vector of differences alpha_i and lambda_i
        FullAlphaLambdaPP;   % full vector of sum alpha_i and lambda_i
        FullAlphaLambdaRAW;  % full RW vector of alpha_i and lambda_i
        xiTau;               % slack variables
        %
        e;                   % epsilon parameter
        SVRmu;               % mu parameter
        %
        nbUSV;               % number of unbounded SVs
        nbBSV;               % number of bounded SVs
        iXsvUSV;             % indices of unbounded SVs
        iXsvBSV;             % indices of bounded SVs
        %
        PsiUSV;              % matrix of quadratic problem w/o the bounded SVs
        KUSV;                % extended PsiUSV
        iKUSV;               % inverse of KUSV
        %
        polyOrder=0;         % polynomial order
        kernelFun='sexp';    % kernel function
        %
        paraVal=1;           % internal parameters used for building (fixed or estimated)
        lVal=[];             % internal parameters: length
        pVal=[];             % internal parametersfor generalized squared exponential
        nuVal=[];            % internal parameter for Matern function
        %
        normLOO='L2';        % norm used for Leave-One-Out cross-validation
        debugLOO=false;      % flag for debug in Leave-One-Out cross-validation
        cvResults;           % structure used for storing the CV results
    end
    
    properties (Access = private)
        respV=[];            % responses prepared for training
        gradV=[];            % gradients prepared for training
        %
        flagG=false;         % flag for computing matrices with gradients
        parallelW=1;         % number of workers for using parallel version
        %
        requireUpdate=false; % flag if an update is required
        forceGrad=false;     % flag for forcing the computation of 1st and 2nd derivatives of the kernel matrix
        %
        matrices;            % structure for storage of matrices (classical and factorized version)
        %
        factK='LL';          % factorization strategy (fastest: LL (Cholesky))
        %
        debugCV=false;       % flag for the debugging process of the Cross-Validation
        %
        requireCompute=true; % flag used for establishing the status of computing
    end
    properties (Dependent,Access = private)
        nS;                 % number of sample points
        nP;                 % dimension of the problem
        parallelOk=false;   % flag for using parallel version
        estimOn=false;      %flag for estimation of the internal parameters
        %
        typeLOO;            % type of LOO criterion used (mse (default),wmse,lpp)
    end
    properties (Dependent)
        Kcond;              % condition number of the kernel matrix
    end
    
    methods
               %% Constructor
        % INPUTS:
        % - samplingIn: array of sample points
        % - respIn: vector of responses
        % - gradIn: array of gradients
        % - varargin: specified in any order
        %       - the missing data (MissData class)
        %       - the options of the metamodel (initMeta class)
        %       - the chosen kernel function (string)
        function obj=SVR(samplingIn,respIn,gradIn,varargin)
            %load data
            flagTrain=false;
            %load data
            if nargin>0;obj.sampling=samplingIn;end
            if nargin>1
                obj.resp=respIn;
                flagTrain=true;
            end
            if nargin>2;obj.grad=gradIn;end
            if nargin>3;obj.manageOpt(varargin);end
            %check if a configuration has been loaded if not load the
            %default
            obj.loadDefaultConf;
            %if everything is ok then train
            if flagTrain
                obj.train();
            end;
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
        
        %% Add new gradients
        addGrad(obj,newG);
        %% Add new responses
        addResp(obj,newR);
        %% Add new sample points
        addSample(obj,newS);
        %% Build kernel matrix and remove missing part
        K=buildMatrix(obj,paraValIn);
        %% Check if there is missing data
        flagM=checkMiss(obj);
        %% Check if there is new missing data
        flagM=checkNewMiss(obj);
        %% Build factorization, solve the SVR problem
        compute(obj,paraValIn);
        %% Compute variance
        variance=computeVariance(obj,rr)
        %% Core of kriging computation using no factorization
        coreClassical(obj);
        %% Compute Leave-One-Out Cross-Validation
        cv=cv(obj);
        %% Estimate internal parameters
        estimPara(obj);
        %% Evaluation of the metamodel
        [Z,GZ,variance]=eval(obj,X);
        %% Force the computation
        fCompute(obj);
        %% Get value of the internal parameters
        pV=getParaVal(obj);
        %%  for dealing with the the input arguments of the class
        manageOpt(obj,varargin);
        %% Compute the the Span Bound of the LOO error for SVR/GSVR
        %from Vapnik & Chapelle 2000 / Chapelle, Vapnik, Bousquet & S. Mukherjee 2002/Chang & Lin 2005
        spanBound=sb(obj,paraValIn,type);
        %% prepare data for building (deal with missing data)
        setData(obj);
        %% Show the result of the CV
        showCV(obj);
        %% Show information in the console
        showInfo(obj,type);
        %% Building/training metamodel
        train(obj);
        %% Building/training the updated metamodel
        trainUpdate(obj,samplingIn,respIn,gradIn);
        %% Update metamodel and train it
        update(obj,newSample,newResp,newGrad,newMissData);
        %% Update data for building (deal with missing data)
        updateData(obj,samplingIn,respIn,gradIn);
    end
end