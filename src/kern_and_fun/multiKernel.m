%% function for evaluating multidimensional kernel function
% this function will call unidimensional kernel function (that give
% response, first and second derivatives)
% L. LAURENT -- 02/05/2016 -- luc.laurent@lecnam.net

% See Lockwood 2010 for an explanantion of U, L et M.

function [respK,derK,dderK,infoOut]=multiKernel(kernelFun,X,metaPara)

%number of required evaluations
nE=size(X,1);
%number of variables
nV=size(X,2);
%number of output variables
nbOut=nargout;

%manage hyperparameters (depending in the kernel function)
nP=numel(metaPara);
if nP==1
    metaParaOk=metaPara*ones(nE*nV,1);
elseif nP==nV
    metaPara=metaPara(:)';
    metaParaOk=metaPara(ones(nE,1),:);
    metaParaOk=metaParaOk(:);
elseif nP==nV+1
    metaPara=metaPara(:)';
    metaParaA=metaPara(1:end-1);
    metaParaB=metaPara(end);
    metaParaAOk=metaParaA(ones(nE,1),:);
    metaParaBOk=metaParaB*ones(nE*nV,1);
    metaParaOk=[metaParaAOk(:) metaParaBOk(:)];
elseif nP=2*nV
    metaPara=metaPara(:)';
    metaParaA=metaPara(1:nV);
    metaParaB=metaPara(nV+1:end);
    metaParaAOk=metaParaA(ones(nE,1),:);
    metaParaBOk=metaParaB(ones(nE,1),:);
    metaParaOk=[metaParaAOk(:) metaParaBOk(:)];
end

%%depending on the output variables
%calculation of the response
if nbOut==1
    uniR=zeros(nE,nV);
    uniR(:)=feval(kernelFun,X(:),metaParaOk);
    %response
    respK=prod(uniR,2);
end

%calculation of the response and first derivatives
if nbOut==2
    uniR=zeros(nE,nV);
    duniR=zeros(nE,nV);
    [uniR(:),duniR(:)]=feval(kernelFun,X(:),metaParaOk);
    %response
    respK=prod(uniR,2);
    %first derivatives
    L=[ones(nE,1) cumprod(uniR(:,1:end-1),2)];
    U=cumprod(uniR(:,end:-1:2),2);
    U=[U(:,end:-1:1) ones(nE,1)];
    derK=L.*U.*duniR;
end

%calculation of the response and first and second derivatives
if nbOut>2
    uniR=zeros(nE,nV);
    duniR=zeros(nE,nV);
    dduniR=zeros(nE,nV);
    [uniR(:),duniR(:),dduniR(:)]=feval(kernelFun,X(:),metaParaOk);
    %response
    respK=prod(uniR,2);
    %first derivatives
    L=[ones(nE,1) cumprod(uniR(:,1:end-1),2)];
    U=cumprod(uniR(:,end:-1:2),2);
    U=[U(:,end:-1:1) ones(nE,1)];
    LdU=L.*U;
    derK=LdU.*duniR;
    %second derivatives (depending of the number of required evaluations
    if nE==1
        % if only 1 evaluation is required the seconde derivative is given
        % using a matrix        
        prd=duniR'*duniR;
        prd(1:nV+1:nV^2)=dduniR;
        %
        if nV>1;maskM=[1 1];else maskM=1;end
        mm=[maskM uniR(2:nV-1)];
        %
        M=mm(ones(nb_comp,1),:);
        M=triu(M,2)+tril(ones(nV),1);
        M=cumprod(M,2);
        %
        LUMt=triu(L'*U.*M,1);
        LUM=LUMt+LUMt';
        LUM(1:nV+1:nV^2)=LdU;
        %second derivatives
        dderK=LUM.*prd;
    else
        % if many evaluation are required the second derivatives are given using an nD-array
        ixDiag=repmat(logical(eye(nV)),[1 1 nE]); %access to the diagonals of the nD-array
        %change to nD-array
        duniR=reshape(duniR',1,nV,nE);
        Lr=reshape(L',nV,1,nE); % + transpose
        Ur=reshape(U',1,nV,nE);
        %
        prd=multiTimes(duniR,duniR,2.1);
        prd(ixDiag)=dduniR';
        if nV>1;maskM=[1 1];else maskM=1;end
        mm=[maskM 3:nV];
        mask1=mm(ones(nV,1),:); %shift indexes
        mask1=triu(mask1,2)+tril(ones(nV),1);
        %
        pcc=reshape([ones(1,nE);uniR'],1,nV+1,nE);
        M=reshape(pcc(1,mask1,:),nV,nV,nE);
        %
        mask2=triu(ones(nV));
        M=cumprod(M,2);
        M=M.*repmat(mask2,[1 1 nE]);
        LUMt=multiTimes(Lr,Ur,2).*M;
        LUM=LUMt+multitransp(LUMt);        
        LUM(ixDiag)=LdU';
        %second derivatives
        dderK=LUM.*prd;
    end
end


end