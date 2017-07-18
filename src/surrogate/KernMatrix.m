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
        KK=[];              % matrix of kernel
        KKd=[];             % matrix of first derivatives
        KKdd=[];            % matrix of second derivatives
        %        
        paraVal=[];         % values of the internal parameters
        sampling=[];        % sampling points
        newSample=[];       % in the cas of adding new sample points
        distC=[];           % vector of inter-points distances
        fctKern='sexp';     % chosen kernel function    
    end
    properties (Dependent)
            
    end
    
    properties (Access = private)
        computeD=false;      % flag for computing matrices with gradients
        parallelW=1;         % number of workers for using parallel version
        %
        iX;                  % structure of indices
        NiX;                 % structure of indices for new sampling points
        requireRun=true;     % flag if a full building is required
        requireUpdate=false; % flag if an update is required
        requireIndices=true; % flag if an update of indices is required
        %
        nbParaOk=[];         %number of acceptable internal parameters
        listKernel={'sexp','matern','matern32','matern52'};  %list of available kernel functions
        listKernelTxt={'Squared exponential','Matern','Matern 3/2','Matern 5/2'};  %list of available kernel functions
    end
    properties (Dependent,Access = private)
        NnS;               % number of new sample point
        nS;               % number of sample point
        nP;               % dimension of the problem
        parallelOk=false;    % flag for using parallel version
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
        %load list Kernel functions
        function l=loadKern(obj)
            l=obj.listKernel;
        end
        %compute indices
        function iX=computeIX(obj)
            keyboard
            if obj.requireIndices
                ns=obj.nS;
                np=obj.nP;
                % Building indexes system
                if obj.computeD
                    %
                    sizeMatRc=(ns^2+ns)/2;
                    sizeMatRa=np*sizeMatRc;
                    sizeMatRi=np^2*sizeMatRc;
                    iXmatrix=zeros(sizeMatRc,1);
                    iXmatrixA=zeros(sizeMatRa,1);
                    iXmatrixAb=zeros(sizeMatRa,1);
                    iXmatrixI=zeros(sizeMatRi,1);
                    iXdev=zeros(sizeMatRa,1);
                    iXsampling=zeros(sizeMatRc,2);
                    
                    tmpList=zeros(sizeMatRc,np);
                    tmpList(:)=1:sizeMatRa;
                    
                    ite=0;
                    iteA=0;
                    iteAb=0;
                    pres=0;
                    %table of indexes for inter-lengths (1), responses (1) and 1st
                    %derivatives (2)
                    tmpIX=allcomb(1:ns,1:ns);
                    iXsampling=tmpIX(tmpIX(:,1)<tmpIX(:,2),:);
                    iXmatrix=(iXsampling(:,1)-1)*ns+iXsampling(:,2);
                    for ii=1:ns
                        
                        ite=ite(end)+(1:(ns-ii+1));
                        iteAb=iteAb(end)+(1:((ns-ii+1)*np));
                        
                        debb=(ii-1)*np*ns+ii;
                        finb=ns^2*np-(ns-ii);
                        lib=debb:ns:finb;
                        
                        iXmatrixAb(iteAb)=lib;
                        
                        for jj=1:np
                            iteA=iteA(end)+(1:(ns-ii+1));
                            decal=(ii-1);
                            deb=pres+decal;
                            li=deb + (1:(ns-ii+1));
                            iXmatrixA(iteA)=li;
                            pres=li(end);
                            list_tmpB=reshape(tmpList',[],1);
                            iXdev(iteA)=tmpList(ite,jj);
                        end
                    end
                    %table of indexes for second derivatives
                    a=zeros(ns*np,np);
                    decal=0;
                    precI=0;
                    for ii=1:ns
                        li=1:ns*np^2;
                        a(:)=decal+li;
                        decal=a(end);
                        b=a';
                        
                        iteI=precI+(1:(np^2*(ns-(ii-1))));
                        
                        debb=(ii-1)*np^2+1;
                        finb=np^2*ns;
                        iteb=debb:finb;
                        iXmatrixI(iteI)=b(iteb);
                        precI=iteI(end);
                    end
                else
                    %table of indexes for inter-lenghts  (1), responses (1)
                    tmpIX=allcomb(1:ns,1:ns);
                    iXsampling=tmpIX(tmpIX(:,1)<tmpIX(:,2),:);
                    iXmatrix=(iXsampling(:,1)-1)*ns+iXsampling(:,2);
%                     bmax=ns-1;
%                     iXmatrix=zeros(ns*(ns-1)/2,1);
%                     iXsampling=zeros(ns*(ns-1)/2,2);
%                     ite=0;
%                     for ii=1:bmax
%                         ite=ite(end)+(1:(ns-ii));
%                         iXmatrix(ite)=(ns+1)*ii-ns+1:ii*ns;
%                         iXsampling(ite,:)=[ii(ones(ns-ii,1)) (ii+1:ns)'];
%                     end
                end
                %
                iX.iXsampling=iXsampling;
                obj.iX=iX;
                %
                keyboard
                obj.requireIndices=false;
            else
                iX=obj.iX;
            end
            keyboard
        end
        %compute new indices (after adding new sample points)
        function iX=computeNewIX(obj)
            oldNs=obj.nS;
            newNs=obj.NnS;
            np=obj.nP;
            % Building indexes system
            if obj.computeD
                %
                sizeMatRc=newNs*(oldNs+1);
                sizeMatRa=np*sizeMatRc;
                sizeMatRi=np^2*sizeMatRc;
                iXmatrix=zeros(sizeMatRc,1);
                %iXmatrixA=zeros(sizeMatRa,1);
                %iXmatrixAb=zeros(sizeMatRa,1);
                %iXmatrixI=zeros(sizeMatRi,1);
                %iXdev=zeros(sizeMatRa,1);
                iXsampling=zeros(sizeMatRc,2);
                
                tmpList=zeros(sizeMatRc,np);
                tmpList(:)=1:sizeMatRa;
                
                ite=0;
                iteA=0;
                iteAb=0;
                pres=0;
                %table of indexes for inter-lengths (1), responses (1) and 1st
                %derivatives (2)
                %                     for ii=1:ns
                %
                %                         ite=ite(end)+(1:(ns-ii+1));
                %                         iXmatrix(ite)=(ns+1)*ii-ns:ii*ns;
                %                         iXsampling(ite,:)=[ii(ones(ns-ii+1,1)) (ii:ns)'];
                %                         iteAb=iteAb(end)+(1:((ns-ii+1)*np));
                %
                %                         debb=(ii-1)*np*ns+ii;
                %                         finb=ns^2*np-(ns-ii);
                %                         lib=debb:ns:finb;
                %
                %                         iXmatrixAb(iteAb)=lib;
                %
                %                         for jj=1:np
                %                             iteA=iteA(end)+(1:(ns-ii+1));
                %                             decal=(ii-1);
                %                             deb=pres+decal;
                %                             li=deb + (1:(ns-ii+1));
                %                             iXmatrixA(iteA)=li;
                %                             pres=li(end);
                %                             list_tmpB=reshape(tmpList',[],1);
                %                             iXdev(iteA)=tmpList(ite,jj);
                %                         end
                %                     end
                %                     %table of indexes for second derivatives
                %                     a=zeros(ns*np,np);
                %                     decal=0;
                %                     precI=0;
                %                     for ii=1:ns
                %                         li=1:ns*np^2;
                %                         a(:)=decal+li;
                %                         decal=a(end);
                %                         b=a';
                %
                %                         iteI=precI+(1:(np^2*(ns-(ii-1))));
                %
                %                         debb=(ii-1)*np^2+1;
                %                         finb=np^2*ns;
                %                         iteb=debb:finb;
                %                         iXmatrixI(iteI)=b(iteb);
                %                         precI=iteI(end);
                %                     end
            else
                %table of indexes for inter-lenghts  (1), responses (1)
                keyboard
                tmpIX=allcomb(1:newNs,1:oldNs);
                iXsampling=tmpIX(tmpIX(:,1)<tmpIX(:,2),:);
                iXmatrix=(iXsampling(:,1)-1)*(newNs+oldNs)+iXsampling(:,2);
                %
                keyboard
%                 bmax=ns-1;
%                 iXmatrix=zeros(newNs*(oldNs+1),1);
%                 iXsampling=zeros(newNs*(oldNs+1),2);
%                 ite=0;
%                 for ii=1:bmax
%                     ite=ite(end)+(1:(ns-ii));
%                     iXmatrix(ite)=(ns+1)*ii-ns+1:ii*ns;
%                     iXsampling(ite,:)=[ii(ones(ns-ii,1)) (ii+1:ns)'];
%                 end
            end
            %
            iX.iXsampling=iXsampling;
            obj.NiX=iX;
        end
        
        %compute inter-points distances
        function distC=computeDist(obj)
            keyboard
            distC=obj.sampling(obj.iX.iXsampling(:,1),:)-obj.sampling(obj.iX.iXsampling(:,2),:);
            obj.distC=distC;
        end
        %new run required
        function fRun(obj);obj.requireRun=true;end
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
        function [KK,KKd,KKdd]=buildMatrix(obj)
            %depending on the number of output arguments
            if nargout>1;obj.computeD=true;end
            %if already computed, then load it otherwise calculate it
            if obj.requireRun
                %compute indices and distances
                obj.computeIX;
                obj.computeDist;                
                %
                ns=obj.nS;
                np=obj.nP;
                %
                fctK=obj.fctKern;
                dC=obj.distC;
                pVl=obj.paraVal;
                %if derivatives required
                if obj.computeD
                    %if parallel workers are available
                    if obj.parallelOk
                        %%%%%% PARALLEL %%%%%%
                        %various parts of the Kernel Matrix
                        KK=zeros(ns,ns);
                        KKa=cell(1,ns);
                        KKi=cell(1,ns);                    
                        %
                        parfor ii=1:ns
                            %Building by column & evaluation of the Kernel function
                            [ev,dev,ddev]=multiKernel(fctK,dC(:,ii),pVl);
                            %classical part
                            KK(:,ii)=ev;
                            %part of the first derivatives
                            KKa{ii}=dev;
                            %part of the second derivatives
                            KKi{ii}=reshape(ddev,np,ns*np);
                        end
                        %Reordering matrices
                        KKd=horzcat(KKa{:});
                        KKdd=vertcat(KKi{:});
                    else
                        %evaluation of the kernel function for all inter-points
                        [ev,dev,ddev]=multiKernel(fctK,dC,pVl);
                        %various parts of the kernel Matrix
                        KK=zeros(ns,ns);
                        KKd=zeros(ns,np*ns);
                        KKdd=zeros(ns*np,ns*np);
                        %classical part
                        KK(dataIn.ix.matrix)=ev;
                        %correction of the duplicated terms on the diagonal
                        KK=KK+KK'-eye(ns);
                        %first and second derivatives of the kernel function
                        KKd(obj.iX.matrixA)=-dev(obj.iX.dev);
                        KKd(obj.iX.matrixAb)=dev(obj.iX.devb);
                        KKdd(obj.iX.matrixI)=ddev(:);
                        %extract diagonal (process for avoiding duplicate terms)
                        diago=0;   % //!!\\ corrections possible here
                        val_diag=spdiags(KKdd,diago);
                        KKdd=KKdd+KKdd'-spdiags(val_diag,diago,zeros(size(KKdd))); %correction of the duplicated terms on the diagonal
                    end
                else
                    if obj.parallelOk
                        %%%%%% PARALLEL %%%%%%
                        %classical kernel matrix by column
                        KK=zeros(ns,ns);
                        parfor ii=1:ns
                            % evaluate kernel function
                            [ev]=multiKernel(fctK,dC(:,ii),pVl);
                            % kernel matrix by column
                            KK(:,ii)=ev;
                        end
                    else
                        %classical kernel matrix (lower triangular matrix)
                        %without diagonal
                        KK=zeros(ns,ns);
                        % evaluate kernel function
                        [ev]=multiKernel(fctK,dC,pVl);
                        KK(obj.iX.matrix)=ev;
                        %Build full kernel matrix
                        KK=KK+KK'+eye(ns);
                    end
                end
                obj.requireRun=false;
            else
                %if already computed then load it
                KK=obj.KK;
                KKd=obj.KKd;
                KKdd=obj.KKdd;
            end
        end
        %add new sample points
        function addSample(obj,newS)
            obj.newSample=newS;
        end
        
        %function for updating the 
        function [KK,KKd,KKdd]=updateMatrix(obj,newS)
            %depending on the number of output arguments
            if nargout>1
                obj.computeD=true;
                %if the first and second derivatives matrices have not been
                %calculated before, we calculate it yet
                if isempty(obj.KKd)
                    obj.sampling=[obj.sampling;newS];
                    obj.requireRun=true;
                    obj.requireIndices=true;
                    [KK,KKd,KKdd]=obj.buildMatrix;
                end
            end
            %store the new sample points
            obj.addSample(newS);
            %calculation of the new distances and indices
            obj.computeNewIX();
            obj.computeNewdist();
            
        end
        %show the list of available kernel functions
        function showKernel(obj)
            fprintf('List of available kernel functions\n');
            dispTableTwoColumns(obj.listKernel,obj.listKernelTxt)
        end
    end
end

%function display table with two columns of text
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

%function display table with two columns of text
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

