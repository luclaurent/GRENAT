%% Class for least-squares surrogate model
% LS: Least-Squares
% GLS: gradient-based Least Squares
% L. LAURENT -- 31/07/2017 -- luc.laurent@lecnam.net

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

classdef xLS < handle
    properties
        sampling=[];         % sample points
        resp=[];             % sample responses
        grad=[];             % sample gradients
        %
        missData;            % class for missing data
        %
        YY=[];               % vector of responses
        YYD=[];              % vector of gradients
        %
        polyOrder=0;         % polynomial order
        kernelFun='sexp';    % kernel function
        %
        beta=[];             % vector of the regressors
        valFunPoly=[];       % matrix of the evaluation of the monomial terms
        valFunPolyD=[];      % matrix of the evaluation of derivatives of the monomial terms
        %
        XX=[];               % full matrix of monomial terms
        YYtot=[];            % full vector of responses and gradients
        fct=[];              % computed matrix XX'*XX
        fcY=[];              % computed matrix XX*YYT
        nbMonomialTerms=0;   % number of monomial terms
        %
        R=[];                % matrices obtained from the QR factorization of the monomial matrix
        Q=[];                %
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
    end
    properties (Dependent,Access = private)
        NnS;                 % number of new sample points
        nS;                  % number of sample points
        nP;                  % dimension of the problem
        parallelOk=false;    % flag for using parallel version
        %
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
        % class) and a boolean for training or not directly the metamodel
        % (default train)
        function obj=xLS(samplingIn,respIn,gradIn,orderIn,varargin)
            flagRun=true;%default
            flagTrain=false;
            %load data
            if nargin>0;obj.sampling=samplingIn;end
            if nargin>1
                obj.resp=respIn;
                flagTrain=true;
            end
            if nargin>2;obj.grad=gradIn;end
            if nargin>3;obj.polyOrder=orderIn;end
            %
            if nargin>5;flagRun=obj.manageOpt(varargin);end
            %if everything is ok then train w/- or w/o running the
            %computation
            if flagTrain
                obj.train(flagRun);
            end
        end
        
        %% setters
        function set.missData(obj,dataIn)
            if ~isempty(dataIn)
                obj.missData=dataIn;
            end
        end
        function set.polyOrder(obj,pO)
            fl=false;
            if isnumeric(pO)
                if int32(pO)==pO
                    if pO>=0
                        obj.polyOrder=pO;
                        fl=true;
                    end
                end
            end
            if ~fl;Gfprintf(' Error on the chosen polynomial order (current %i)\n',obj.polyOrder);end
        end
        
        %% getters
        function nS=get.nS(obj)
            nS=numel(obj.resp);
        end
        function nP=get.nP(obj)
            nP=size(obj.sampling,2);
        end
        
        %% getter for GLS building
        function flagG=get.flagG(obj)
            flagG=~isempty(obj.grad);
        end
        
        %% Add new gradients
        addGrad(obj,newG);
        %% Add new responses
        addResp(obj,newR);
        %% Add new sample points
        addSample(obj,newS);
        %% Regression matrix at the non-sample point
        [ff,jf]=buildMatrixNonS(obj,U);
        %% Check if there is missing data
        flagM=checkMiss(obj);
        %% Check if there is new missing data
        flagM=checkNewMiss(obj);
        %% Compute regressors
        compute(obj,flagRun);
        %% Evaluation of the metamodel
        [Z,GZ]=eval(obj,U);
        %%  for dealing with the the input arguments of the class
        flagR=manageOpt(obj,varargin);
        %% Prepare data for building (deal with missing data)
        setData(obj);
        %% Show information in the console
        showInfo(obj,type);
        %% Building/training metamodel
        train(obj,flagRun);
        %% Building/training the updated metamodel
        trainUpdate(obj,samplingIn,respIn,gradIn);
        %% Update metamodel
        update(obj,newSample,newResp,newGrad,newMissData);
        %% prepare data for building (deal with missing data)
        updateData(obj,respIn,gradIn);
    end
end