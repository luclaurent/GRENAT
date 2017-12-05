%% class for RBF/GRBF metamodel
% RBF: Radial Basis Function
% GRBF: Gradient-based Radial Basis Function
% L. LAURENT -- 15/08/2017 -- luc.laurent@lecnam.net

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

classdef RBF < handle
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
        W=[];               % coefficients of RBF/GRBF
        %
        kernelFun='sexp';   % kernel function
        %
        paraVal=1;          % internal parameters used for building (fixed or estimated)
        lVal=[];            % internal parameters: length
        pVal=[];            % internal parametersfor generalized squared exponential
        nuVal=[];           % internal parameter for Matérn function
        %
        normLOO='L2';       % norm used for Leave-One-Out cross-validation
        debugLOO=false;     % flag for debug in Leave-One-Out cross-validation
        cvResults;          % structure used for storing the CV results
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
        NnS;                 % number of new sample points
        nS;                  % number of sample points
        nP;                  % dimension of the problem
        parallelOk=false;    % flag for using parallel version
        estimOn=false;       % flag for estimation of the internal parameters
        %
        typeLOO;             % type of LOO criterion used (mse (default),wmse,lpp)
    end
    properties (Dependent)
        Kcond;               % condition number of the kernel matrix
    end
    
    methods
        %% Constructor
        % INPUTS:
        % - samplingIn: array of sample points
        % - respIn: vector of responses
        % - gradIn: array of gradients
        % - kernIn: chosen kernel function
        % - varargin: specified in any order
        %       - the missing data (MissData class)
        %       - the options of the metamodel (initMeta class)
        %       - the chosen kernel function (string)
        function obj=RBF(samplingIn,respIn,gradIn,varargin)
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
            end
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
        
        %% getter for kernel function
        function kFun=get.kernelFun(obj)
            %load default kernel function
            kFun=obj.kernelFun;
            %load specific configuration if it is available
            if ~isempty(obj.metaData.kern)
                kFun=obj.metaData.kern;
            end
        end
        
        %% getter for GRBF building
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
            if ~isempty(regexp(typeG,'cv','ONCE'))
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
        %% Build factorization, solve the RBF problem
        compute(obj,paraValIn);
        %% Compute variance
        variance=computeVariance(obj,rr);
        %% Core of RBF computation using no factorization
        coreClassical(obj);
        %% Core of RBF computation using Cholesky (LL) factorization
        coreLL(obj);
        %% Core of RBF computation using LU factorization
        coreLU(obj);
        %% Core of RBF computation using QR factorization
        coreQR(obj);
        %% Compute Leave-One-Out Cross-Validation
        [crit,cv]=cv(obj,paraValIn,type);
        %% Estimate internal parameters
        estimPara(obj);
        %% Evaluation of the metamodel
        [Z,GZ,variance]=eval(obj,X);
        %% Force the computation
        fCompute(obj);
        %% Get value of the internal parameters
        pV=getParaVal(obj);
        %% Load default configuration
        loadDefaultConf(obj);
        %%  for dealing with the the input arguments of the class
        manageOpt(obj,varargin);
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
