%% GRENAT class for manipulating gradient-enhanced metamodels
% L. LAURENT -- 26/06/2016 -- luc.laurent@lecnam.net

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

classdef GRENAT < handle
    properties (SetObservable)
        %building
        sampling=[];                % Sample points
        resp=[];                    % responses
        grad=[];                    % gradients
    end
    properties
        %%load directories on the path
        dirGRENAT=initDirGRENAT;
        %
        samplingN=[];               % normalized sample points
        respN=[];                   % normalized responses
        gradN=[];                   % normalized gradients
        %evaluating
        nonSamplePts=[];            % non sample points
        nonSampleResp=[];           % non sample responses
        nonSampleGrad=[];           % non sample gradients
        nonSamplePtsOrder=[];       %
        nonSampleRespOrder=[];      %
        nonSampleGradOrder=[];      %
        nonSamplePtsN=[];           % normalized non sample points
        nonSampleRespN=[];          % normalized non sample responses
        nonSampleGradN=[];          % normalized non sample gradient
        sizeNonSample=zeros(1,3);   % size of the non sample points
        nonSampleVar=[];            % non sample variance
        nonSampleVarN=[];           % normalized non sample variance
        nonSampleVarOrder=[];       %
        nonSampleCI=struct('ci68',[],'ci95',[],'ci99',[]);  % confidence intervals
        nonSampleEI=[];             % expected improvement
        %
        sig2N=0;                    % normalized variance of process (kriging...)
        sig2=0;                     % variance of process (kriging...)
        %
        err=[];                     % errors of approximation (multiples criteria)
        %reference
        sampleRef=[];               % sample points for reference
        respRef=[];                 % reference responses
        gradRef=[];                 % refernece gradients
        %structures & class for storing configuration and data
        confMeta=initMeta;          % metamodel configuration
        dataTrain;                  % training data
        confDisp=initDisp;          % display configuration
        miss=MissData;              % missing data
        norm=NormRenorm;            % normalization data (NormRenorm class)
        type;                       % type of metamodel
    end
    properties (Dependent)
        %normalization data
        normMeanS;                  % mean of sample points
        normStdS;                   % standard deviation of sample points
        normMeanR;                  % mean of responses
        normStdR;                   % standard deviation of responses
        %
        nS;                         % number of sample points
        nP;                         % number of design parameters
    end
    
    properties (Access = private)
        runTrain=true;              % flag for checking if the training is obsolete
        runEval=true;               % flag for checking if the training is obsolete
        gradAvail=false;            % flag for availability of the gradients
        gradUsed=false;             % flag for use of the gradients
        inGrad=false;               % flag for use of indirect gradients
        runErr=true;                % flag for computation of the error
        %      normSamplePtsIn=false;      % flag for checking if the input data are normalized
        %      normRespIn=false;           % flag for checking if the input data are normalized
        runMissingData=true;        % flag for checking missing data
        nbSubplot=0;                % number of subplot for display
        requireUpdate=false;        % flag for checking if GRENAT requires an update
        infoProp;     % list of properties and description
    end
    
    methods
        %% Constructor
        % INPUTS:
        % - typeIn: type of metamodel
        % - samplingIn: array of sample points
        % - respIn: vector of responses
        % - gradIn: array of gradients
        function obj=GRENAT(typeIn,samplingIn,respIn,gradIn)
            %initialize GRENAT
            obj.initGRENAT;
            %specific configuration
            if nargin>0;obj.type=typeIn;end
            if nargin>1;obj.sampling=samplingIn;end
            if nargin>2;obj.resp=respIn;end
            if nargin>3;obj.grad=gradIn;end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %setter for the sampling
        function set.sampling(obj,samplingIn)
            %update the sampling, normalize it
            obj.sampling=obj.updateSampling(samplingIn);
        end
        %setter for the responses
        function set.resp(obj,respIn)
            %update the responses, normalize them
            obj.resp=obj.updateResp(respIn);
        end
        %setter for the gradients
        function set.grad(obj,gradIn)
            %update the gradients, normalize them
            obj.grad=obj.updateGrad(gradIn);
        end
        %setter for the non sample points
        function set.nonSamplePts(obj,samplingIn)
            obj.nonSamplePts=samplingIn;
            %update non sample points
            obj.updateNonSamplePts(samplingIn);
        end
        %setter for the non sample normalized responses
        function set.nonSampleRespN(obj,respIn)
            obj.nonSampleRespN=respIn;
            %update non sample normalized responses
            obj.updateNonSampleResp(respIn);
        end
        %setter for the non sample normalized gradients
        function set.nonSampleGradN(obj,gradIn)
            obj.nonSampleGradN=gradIn;
            %update non sample normalized gradients
            obj.updateNonSampleGrad(gradIn);
        end
        %setter for the non sample normalized variance
        function set.nonSampleVarN(obj,varIn)
            obj.nonSampleVarN=varIn;
            %update non sample normalized variance
            obj.updateNonSampleVar(varIn);
        end
        %setter for the type of metamodel
        function set.type(obj,typeIn)
            obj.setTypeConf(typeIn);
            obj.type=typeIn;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %getter for checking if GRENAT could be updated
        function s=get.requireUpdate(obj);s=obj.checkUpdate();end        
        %getter for the number of sample points
        function s=get.nS(obj);s=size(obj.sampling,1);end
        %getter for the number of design parameters
        function s=get.nP(obj);s=size(obj.sampling,2);end        
        %getter for the type of metamodel
        function type=get.type(obj);type=obj.confMeta.type;end        
        %getter for normalized sample points
        function out=get.samplingN(obj)
            %if normalization is requested
            if obj.confMeta.normOn
                out=obj.norm.samplingN;
            else
                %no normalization
                out=obj.sampling;
            end
        end
        %getter for normalized sample points
        function out=get.respN(obj)
            %if normalization is requested
            if obj.confMeta.normOn
                out=obj.norm.respN;
            else
                %no normalization
                out=obj.resp;
            end
        end
        %getter for normalized sample points
        function out=get.gradN(obj)
            %if normalization is requested
            if obj.confMeta.normOn
                out=obj.norm.gradN;
            else
                %no normalization
                out=obj.grad;
            end
        end        
        %getter for the non sample points
        function PtS=get.nonSamplePtsOrder(obj)
            PtS=obj.orderData(obj.nonSamplePts,'sampleIn');
        end
        %getter for the responses at the non sample points
        function Z=get.nonSampleResp(obj)
            if obj.runEval;eval(obj);end
            Z=obj.orderData(obj.nonSampleRespOrder,'respOut');
        end
        %getter for the gradients at the non sample points
        function GZ=get.nonSampleGrad(obj)
            if obj.runEval;eval(obj);end
            GZ=obj.orderData(obj.nonSampleGradOrder,'gradOut');
        end
        %getter for the variance at the non sample points
        function variance=get.nonSampleVar(obj)
            if obj.runEval;eval(obj);end
            variance=obj.orderData(obj.nonSampleVarOrder,'respOut');
        end
        %getter for error values
        function err=get.err(obj)
            if obj.runErr;errCalc(obj);end
            err=obj.err;
        end
        % getters for normalization data for sample points
        function nMS=get.normMeanS(obj);nMS=obj.norm.meanS;end
        function nSS=get.normStdS(obj);nSS=obj.norm.stdS;end
        % getters for normalization data for responses
        function nMR=get.normMeanR(obj);nMR=obj.norm.meanR;end
        function nSR=get.normStdR(obj);nSR=obj.norm.stdR;end
        
        %% Check interpolation
        [statusR,statusG]=checkInterp(obj);
        %% Check if all data is available for displaying the reference
        [okAll,okSample,okResp,okGrad]=checkRef(obj);
        %% Check if update could be done
        s=checkUpdate(obj);
        %% Define properties
        conf(obj,varargin);
        %% Define the configuration for the display
        defineDisp(obj,varargin);
        %% Define the reference surface
        defineRef(obj,varargin);
        %% Compute and show the errors of the metamodel
        err=errCalc(obj);
        %% Evaluate the metamodel
        [Z,GZ,variance]=eval(obj,evalPts,Verb);
        %% Evaluate the CI of the metamodel
        [ci68,ci95,ci99]=evalCI(obj,nonSamplePts);
        %% Compute infill criterion
        [ZI,detI]=evalInfill(obj,nonSamplePts,Verb);
        %% Initialize GRENAT's class
        initGRENAT(obj);
        %% Initialize flag for availability of the gradients
        initGradAvail(obj,flag);
        %% Initialize flag for evaluation
        initRunEval(obj,flag);
        %% Initialize flag for training
        initRunTrain(obj,flag);
        %% Ordering data (for manipulating nd-arrays)
        dataOut=orderData(obj,dataIn,type);
        %% Update GRENAT toolbox
        s=selfUpdate(obj,flag);
        %% Set the type of metamodel in the configuration and initialize
        setTypeConf(obj,typeIn);
        %% Show results
        show(obj,varargin);
        %% Show 1D results
        show1D(obj);
        %% Show 2D results
        show2D(obj);
        %% Show the confidence intervals approximated by the metamodel
        showCI(obj,ciVal,nonSamplePts);
        %% Display information in the console
        showData(obj,typeIn);
        %% Show the gradients approximated by the metamodel
        showGrad(obj,nbG);
        %% Show the reference gradients
        showGradRef(obj,nbG);
        %% Show the response approximated by the metamodel
        showResp(obj);
        %% Show the reference response
        showRespRef(obj);
        %% Train the metamodel
        train(obj);
        %% Update the metamodel by adding sample points and associated
        update(obj,samplingIn,respIn,gradIn,paraFind,varargin);
        %% Update gradients (normalized if necessary)
        gradOk=updateGrad(obj,newGrad);
        %% Update unormalized gradients (renormalized if necessary)
        updateNonSampleGrad(obj,newGrad);
        %% Declare non sample points
        updateNonSamplePts(obj,samplePtsIn);
        %% Update unormalized responses (renormalized if necessary)
        updateNonSampleResp(obj,newResp);
        %% Update unormalized variance (renormalized if necessary)
        updateNonSampleVar(obj,newVar);
        %% Update responses (normalized if necessary)
        respOk=updateResp(obj,newResp);
        %% Update sample points (normalized if necessary)
        sampleOk=updateSampling(obj,newSample);
        
    end
    methods (Static)
        %% Function for declaring the purpose of each properties
        info=affectTxtProp();
        %% Function for checking if the surrogate model is a classical
        [Indirect,Classical,typeOk]=CheckGE(typeSurrogate);
    end
end


