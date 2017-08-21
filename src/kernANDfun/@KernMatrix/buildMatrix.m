%% Method of KernMatrix class
% L. LAURENT -- 18/07/2017 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017-2017  Luc LAURENT <luc.laurent@lecnam.net>
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


%% Build the kernel matrices
% INPUTS:
% - paraV: values of the hyperparameters used for kernel computation
% (optional)
% OUTPUTS:
% - KK,KKd,KKdd: kernel matrices (KK: responses, KKd: gradients and KKdd:
% hessians) 

function [KK,KKd,KKdd]=buildMatrix(obj,paraV)
%changing the values of the internal parameters
if nargin>1;obj.paraVal=paraV;end
%depending on the number of output arguments
if nargout>1||obj.forceGrad;obj.computeD=true;end
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
            %%REWRITE
            %                         %%%%%% PARALLEL %%%%%%
            %                         %various parts of the Kernel Matrix
            %                         KK=zeros(ns,ns);
            %                         KKa=cell(1,ns);
            %                         KKi=cell(1,ns);
            %                         %
            %                         parfor ii=1:ns
            %                             %Building by column & evaluation of the Kernel function
            %                             [ev,dev,ddev]=multiKernel(fctK,dC(:,ii),pVl);
            %                             %classical part
            %                             KK(:,ii)=ev;
            %                             %part of the first derivatives
            %                             KKa{ii}=dev;
            %                             %part of the second derivatives
            %                             KKi{ii}=reshape(ddev,np,ns*np);
            %                         end
            %                         %Reordering matrices
            %                         KKd=horzcat(KKa{:});
            %                         KKdd=vertcat(KKi{:});
        else
            %evaluation of the kernel function for all inter-points
            %keyboard
            [ev,dev,ddev]=multiKernel(fctK,dC,pVl);
            %various parts of the kernel Matrix
            KK=zeros(ns,ns);
            KKd=zeros(ns,np*ns);
            KKdd=zeros(ns*np,ns*np);
            %classical part
            KK(obj.iX.matrix)=ev;
            %correction of the duplicated terms on the diagonal
            KK=KK+KK'-eye(ns);
            %first and second derivatives of the kernel function
            devT=dev';
            %KKd(obj.iX.matrixA)=-dev(obj.iX.dev);
            KKd(obj.iX.matrixAb)=devT(:);%dev(obj.iX.devb);
            %keyboard
            
            KKdT=reshape(permute(reshape(KKd',[np,ns,ns]),[2,1,3]),[ns ns*np 1]);
            KKd=KKd-KKdT;
            %
            KKdd(obj.iX.matrixI)=ddev(:);
            %extract diagonal (process for avoiding duplicate terms)
            diago=0;   % //!!\\ possible corrections here
            val_diag=spdiags(KKdd,diago);
            KKdd=KKdd+KKdd'-spdiags(val_diag,diago,zeros(size(KKdd))); %correction of the duplicated terms on the diagonal
            %keyboard
        end
        obj.KK=KK;
        obj.KKd=KKd;
        obj.KKdd=KKdd;
    else
        if obj.parallelOk
            %REWRITE
            %                         %%%%%% PARALLEL %%%%%%
            %                         %classical kernel matrix by column
            %                         KK=zeros(ns,ns);
            %                         parfor ii=1:ns
            %                             % evaluate kernel function
            %                             [ev]=multiKernel(fctK,dC(:,ii),pVl);
            %                             % kernel matrix by column
            %                             KK(:,ii)=ev;
            %                         end
        else
            %classical kernel matrix (lower triangular matrix)
            %without diagonal
            KK=zeros(ns,ns);
            % evaluate kernel function
            [ev]=multiKernel(fctK,dC,pVl);
            %keyboard
            KK(obj.iX.matrix)=ev;
            %Build full kernel matrix
            KK=KK+KK'-eye(ns);
        end
        obj.KK=KK;
    end
    obj.requireRun=false;
else
    %if already computed then load it
    KK=obj.KK;
    KKd=obj.KKd;
    KKdd=obj.KKdd;
end
end
