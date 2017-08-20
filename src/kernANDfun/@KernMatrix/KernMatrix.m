%% Class for building Kernel Matrix for classical and gradient-enhanced kernel-based surrogate model
% L. LAURENT -- 27/04/2016 -- luc.laurent@lecnam.net
% class version - 18/07/2017

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

classdef KernMatrix < handle
    properties
        KK=[];                  % matrix of kernel
        KKd=[];                 % matrix of first derivatives
        KKdd=[];                % matrix of second derivatives
        %
        paraVal=[];             % values of the internal parameters
        sampling=[];            % sampling points
        newSample=[];           % in the cas of adding new sample points
        distC=[];               % vector of inter-points distances
        distN=[];               % vector of inter-points distances for new sample points
        distNO=[];              % vector of inter-points distances for new sample points (distance to the old ones)
        fctKern='sexp';         % chosen kernel function
    end
    properties (Dependent)
        
    end
    
    properties (Access = private)
        computeD=false;         % flag for computing matrices with gradients
        parallelW=1;            % number of workers for using parallel version
        %
        iX;                     % structure of indices
        NiX;                    % structure of indices for new sampling points
        requireRun=true;        % flag if a full building is required
        requireUpdate=false;    % flag if an update is required
        requireIndices=true;    % flag if an update of indices is required
        forceGrad=false;        % flag for forcing the computation of 1st and énd derivatives of the kernel matrix
        %
        nbParaOk=[];            %number of acceptable internal parameters
        listKernel={'sexp','matern','matern32','matern52'};  %list of available kernel functions
        listKernelTxt={'Squared exponential','Matern','Matern 3/2','Matern 5/2'};  %list of available kernel functions
    end
    properties (Dependent,Access = private)
        NnS;                    % number of new sample points
        nS;                     % number of sample points
        nP;                     % dimension of the problem
        parallelOk=false;       % flag for using parallel version
        %
    end
    %
    methods
        %% Constructor
        % fct: chosen kernel function
        % sampling: array of sample points
        % val: array of value of the hyperparameters of the kernel function
        % parallel: execParallel class
        
        function obj=KernMatrix(fct,sampling,val,parallel)
            %load arguments
            obj.fctKern=fct;
            obj.paraVal=val;
            obj.sampling=sampling;
            if nargin>3;obj.parallelW=parallel;end
        end
        %% setters and getters
        %setter for kernel function
        function set.fctKern(obj,fct)
            checkKernel=any(ismember(obj.loadKern,fct));
            if checkKernel
                obj.fctKern=fct;
            else
                fprintf('Kernel function %s not available (maintain %s)\n',fct,obj.fctKern);
                obj.showKernel;
            end
        end
        %setter for gradients calculations
        function set.computeD(obj,bool)
            oldFlag=obj.computeD;
            if ~oldFlag&&bool
                obj.fRun;
            end
            obj.computeD=bool;
        end
        %setter for internal parameter
        function set.paraVal(obj,pV)
            oldpV=obj.paraVal;
            if ~isempty(oldpV)
                if numel(oldpV(:))==numel(pV(:))
                    if ~all(oldpV(:)==pV(:))
                        obj.fRun;
                    end
                else
                    obj.fRun;
                end
            else
                obj.fRun;
            end
            obj.paraVal=pV;
        end
        %setter for the flag to force gradient-matrix computation
        function set.forceGrad(obj,boolIn)
            oldFG=obj.forceGrad;
            if ~oldFG&&boolIn
                obj.fRun;
            end
            obj.forceGrad=boolIn;
        end
        %getter for the number of acceptable internal parameters
        function nb=get.nbParaOk(obj)
            nb=obj.computeNbPara;
        end
        %getter for the number of sample points
        function nS=get.nS(obj)
            nS=size(obj.sampling,1);
        end
        %getter for the number of new sample points
        function nS=get.NnS(obj)
            nS=size(obj.newSample,1);
        end
        %getter for the dimension
        function nP=get.nP(obj)
            nP=size(obj.sampling,2);
        end
        %getter for the flag for parallel
        function pO=get.parallelOk(obj)
            pO=(obj.parallelW>1);
        end
        %%
        
        %% other methods %%
        
        %% initialize all flag
        init(obj);
        %% Check matrices
        f=checkMatrix(obj);
        %% Load list Kernel functions
        l=loadKern(obj);
        %% New run required
        fRun(obj);
        %% Force gradients matrices computation
        fGrad(obj);
        %% Force indices computation
        fIX(obj);
        %% Compute number of required internal parameters
        nbP=computeNbPara(obj);
        %% Manual getters for matrices
        K=getKK(obj);
        K=getKKd(obj);
        K=getKKdd(obj);
        %% Show the list of available kernel functions
        showKernel(obj);
        %% Add new sample points
        flag=addSample(obj,newS);
        %% Build the kernel matrices
        [KK,KKd,KKdd]=buildMatrix(obj,paraV);
        %% Build a correlation (kernel) vector depending on the distance between existing sample points and specific points
        [V,Vd,Vdd]=buildVector(obj,samplePts,paraV)
        %% Compute inter-distances between sample points
        distC=computeDist(obj);
        %% Compute structure of indices for building the kernel matrices
        iX=computeIX(obj);
        %% Compute new inter-points distances (since new sample points are added)
        [distN,distNO]=computeNewDist(obj);
        %% Compute new structure of indices (after adding new sample points)
        iX=computeNewIX(obj)
        %% Update existing kernel matrices
        [KK,KKd,KKdd]=updateMatrix(obj,newS)
    end
end