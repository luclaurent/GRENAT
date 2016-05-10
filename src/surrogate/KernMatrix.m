%% Function for building Kernel Matrix for classical and gradient-enhanced kernel-based surrogate model
% L. LAURENT -- 27/04/2016 -- luc.laurent@lecnam.net

function [KK,KKd,KKdd]=KernMatrix(fctKern,dataIn,paraVal,parallelW)

if nargin<4;parallelW=1;end
%kernel derivatives matrices required
if nargout>1;KerMatrixD=true;else KerMatrixD=false;end
%extract data
distC=dataIn.used.dist;
ns=dataIn.used.ns;
np=dataIn.used.np;
%if derivatives required
if KerMatrixD
    %if parallel workers are available
    if parallelW>=2
        %%%%%% PARALLEL %%%%%%
        %various parts of the Kernel Matrix
        KK=zeros(ns,ns);
        KKa=cell(1,ns);
        KKi=cell(1,ns);
        
        parfor ii=1:ns
            %Building by column & evaluation of the Kernel function
            [ev,dev,ddev]=multiKernel(fctKern,distC(:,ii),paraVal);
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
        [ev,dev,ddev]=multiKernel(fctKern,distC,paraVal);        
        %various parts of the kernel Matrix
        KK=zeros(ns,ns);
        KKd=zeros(ns,np*ns);
        KKdd=zeros(ns*np,ns*np);
        %classical part
        KK(dataIn.ix.matrix)=ev;
        %correction of the duplicated terms on the diagonal
        KK=KK+KK'-eye(dataIn.used.ns);
        %first and second derivatives of the kernel function
        KKd(dataIn.ix.matrixA)=-dev(dataIn.ix.dev);
        KKd(dataIn.ix.matrixAb)=dev(dataIn.ix.devb);
        KKdd(dataIn.ix.matrixI)=ddev(:);
        %extract diagonal (process for avoiding duplicate terms)
        diago=0;   % //!!\\ corrections possible here
        val_diag=spdiags(KKdd,diago);
        KKdd=KKdd+KKdd'-spdiags(val_diag,diago,zeros(size(KKdd))); %correction of the duplicated terms on the diagonal
    end
else
    if parallelW>=2
        %%%%%% PARALLEL %%%%%%
        %classical kernel matrix by column
        KK=zeros(ns,ns);
        parfor ii=1:ns
            % evaluate kernel function
            [ev]=multiKernel(fctKern,distC(:,ii),paraVal);
            % kernel matrix by column
            KK(:,ii)=ev;
        end
    else
        %classical kernel matrix (lower triangular matrix)
        %without diagonal
        KK=zeros(ns,ns);
        % evaluate kernel function
        [ev]=multiKernel(fctKern,distC,paraVal);
        KK(dataIn.ix.matrix)=ev;
        %Build full kernel matrix
        KK=KK+KK'+eye(ns);
    end
end