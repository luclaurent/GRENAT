%% Class for building Kernel Matrix for classical and gradient-enhanced kernel-based surrogate model
% L. LAURENT -- 27/04/2016 -- luc.laurent@lecnam.net
% class version - 18/07/2017

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
        %%constructor
        function obj=KernMatrix(fct,sampling,val,parallel)
            %load arguments
            obj.fctKern=fct;
            obj.paraVal=val;
            obj.sampling=sampling;
            if nargin>3;obj.parallelW=parallel;end
        end
        %% setter and getter
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
            if ~all(oldpV==pV)
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
        
        
        %% other methods
        %initialize all flag
        function init(obj)
            obj.requireRun=true;     % flag if a full building is required
            obj.requireUpdate=false; % flag if an update is required
            obj.requireIndices=true; % flag if an update of indices is required
        end
        %check matrices
        function f=checkMatrix(obj)
            %check symetry
            fS=all(all(obj.KK==obj.KK'));
            %check eye
            fE=all(diag(obj.KK)==1);
            %check the adding process
            KKold=obj.KK;
            obj.sampling=[obj.sampling;obj.newSample];
            obj.requireRun=true;
            obj.requireIndices=true;
            KKnew=obj.buildMatrix();
            fA=all(all(KKold==KKnew));
            %
            f=(fS&&fE&&fA);
            %
            fprintf('Matrix ');
            if f; fprintf('OK'); else, fprintf('NOK');end
            fprintf('\n');
            if ~f;keyboard;end
        end
        %load list Kernel functions
        function l=loadKern(obj)
            l=obj.listKernel;
        end
        %new run required
        function fRun(obj);obj.requireRun=true;end
        %force gradients matrices computation
        function fGrad(obj);obj.forceGrad=true;end
        %force indices computation
        function fIX(obj);obj.requireIndices=true;end
        %compute number of required internal parameters
        function nbP=computeNbPara(obj)
            switch obj.fctKern
                case {'sexp','matern32','matern52'}
                    nbP=unique([1,obj.nP]);
                case {'matern'}
                    nbP=[1,obj.nP]+1;
            end
        end
        %
        %manual getters for matrices
        function K=getKK(obj)
            if isempty(obj.KK)||obj.requireRun||obj.requireUpdate
                K=obj.updateMatrix();
            else
                K=obj.KK;
            end
        end
        function K=getKKd(obj)
            obj.fGrad;
            obj.fIX;
            if isempty(obj.KKd)||obj.requireRun||obj.requireUpdate
                [~,K,~]=obj.updateMatrix();
            else
                K=obj.KKd;
            end
        end
        function K=getKKdd(obj)
            obj.fGrad;
            obj.fIX;
            if isempty(obj.KKd)||obj.requireRun||obj.requireUpdate
                [~,~,K]=obj.updateMatrix();
            else
                K=obj.KKdd;
            end
        end
        %show the list of available kernel functions
        function showKernel(obj)
            fprintf('List of available kernel functions\n');
            dispTableTwoColumns(obj.listKernel,obj.listKernelTxt)
        end
    end
end



%% function display table with two columns of text
function dispTableTwoColumnsStruct(tableFieldIn,structIn)
%size of every components in tableA
sizeA=cellfun(@numel,tableFieldIn);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableFieldIn)
    if isfield(structIn,tableFieldIn{itT})
        fprintf('%s%s%s\n',tableFieldIn{itT},spaceTxt(ones(1,spaceA(itT))),structIn.(tableFieldIn{itT}));
    end
end
end

%% function display table with two columns of text
function dispTableTwoColumns(tableA,tableB)
%size of every components in tableA
sizeA=cellfun(@numel,tableA);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableA)
    fprintf('%s%s%s\n',tableA{itT},spaceTxt(ones(1,spaceA(itT))),tableB{itT});
end
end

