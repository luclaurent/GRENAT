%% class for kriging/cokriging metamodel
% KRG: kriging
% GKRG: gradient-based kriging
% L. LAURENT -- 07/08/2017 -- luc.laurent@lecnam.net

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
        YY=[];              % vector of responses
        YYD=[];             % vector of gradients
        YYtot=[];           % full vector of responses and gradients
        K=[];               % kernel matrix
        %
        beta=[];            % regressors of the kriging generalized Least-Square
        gamma=[];           % coefficients of the stochastic prt of the kriging
        sig2=[];            % variance of the Gaussian Process
        %
        polyOrder=0;        % polynomial order
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
        requireRun=true;     % flag if a full building is required
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
        estimOn=false;       %flag for estimation of the internal parameters
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
        % - orderIn: order of the polynomial regression
        % - kernIn: chosen kernel function
        % - varargin: specified in any order the missing data (MissData
        % class) and the options of the metamodel (initMeta class)
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
        
        %% getter for GKRG building
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
    end
end




