%% function for evaluating the gradient-based and non-gradient-based SVR surrogate model at many points
% SVR: w/o gradient
% GSVR: w/- gradients
% L. LAURENT -- 24/05/2016 -- luc.laurent@lecnam.net

%function [Z,GZ,variance,details]=SVREval(U,metaData,specifSampling)
function [Z,GZ]=SVREval(U,metaData,specifSampling)

% display warning or not
dispWarning=false;
%load varibales
ns=metaData.used.ns;
np=metaData.used.np;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of thr gradients or not (depending on the number of output variables)
if nargout>=2
    calcGrad=true;
else
    calcGrad=false;
end
% specific sampled points
if nargin==3
    sampling=specifSampling;
else
    sampling=metaData.used.sampling;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=U;
dimX=size(X,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%distance from evaluation point to sample points
distS=repmat(X,ns,1)-sampling;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVR/GSVR
%%compute response provided by the metamodel at the non sample point
%definition des dimensions of the matrix/vector for SVR or GSVR
if metaData.used.availGrad
    sizeMatVec=ns*(np+1);
else
    sizeMatVec=ns;
end

%kernel (correlation) vector between sample point and the non sample point
rr=zeros(sizeMatVec,1);
if calcGrad
    jr=zeros(sizeMatVec,np);
end

%SVR/GSVR
if metaData.used.availGrad
    if calcGrad  %if compute gradients
        %evaluate kernel function
        [ev,dev,ddev]=multiKernel(metaData.build.kern,distS,metaData.build.para.val);
        rr(1:ns)=ev;
        rr(ns+1:sizeMatVec)=-reshape(dev',1,ns*np);
        
        %derivative of the kernel vector between sample point and the non sample point
        jr(1:ns,:)=dev;
        
        % second derivatives
        matDer=zeros(np,np*ns);
        for mm=1:ns
            matDer(:,(mm-1)*np+1:mm*np)=ddev(:,:,mm);
        end
        jr(ns+1:sizeMatVec,:)=-matDer';
        
        %if missing responses
        if metaData.miss.resp.on
            rr(metaData.miss.resp.ixMiss)=[];
            jr(metaData.miss.resp.ixMiss,:)=[];
        end
        
        %if missing gradients
        if metaData.miss.grad.on
            repEv=metaData.used.ns-metaData.miss.resp.nb;
            rr(repEv+metaData.miss.grad.ixtMissLine)=[];
            jr(repEv+metaData.miss.grad.ixtMissLine,:)=[];
        end
        
    else %otherwise
        [ev,dev]=multiKernel(metaData.build.kern,distS,metaData.build.para.val);
        rr(1:ns)=ev;
        rr(ns+1:sizeMatVec)=reshape(dev',1,ns*np);
        %if missing data
        if metaData.miss.resp.on
            rr(metaData.miss.resp.ixMiss)=[];
            if metaData.miss.grad.on
                repEv=metaData.used.ns-metaData.miss.resp.nb;
                rr(repEv+metaData.miss.grad.ixtMissLine)=[];
            end
        end
    end
else
    if calcGrad  %if the gradients will be computed
        [rr,jr]=multiKernel(metaData.build.kern,distS,metaData.build.para.val);
    else %otherwise
        rr=feval(metaData.build.kern,distS,metaData.build.para.val);
    end
    %if missing data
    if metaData.miss.resp.on
        rr(metaData.miss.resp.ixMiss)=[];
        jr(metaData.miss.resp.ixMiss,:)=[];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation of the surrogate model at point X
Z=metaData.build.SVRmu+metaData.build.alphaLambdaPM'*rr;
if calcGrad
    GZ=metaData.build.alphaLambdaPM'*jr;
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %compute the prediction variance (MSE) (Lophaven, Nielsen & Sondergaard
% %2004 / Marcelet 2008 / Chauvet 1999)
% if nargout >=3
%     if ~dispWarning;warning off all;end
%     %depending on the factorization
%     switch metaData.build.factKK
%         case 'QR'
%             rrP=rr'*metaData.build.PK;
%             Qrr=metaData.build.QtK*rr;
%             u=metaData.build.fcR*Qrr-ff';
%             variance=metaData.build.sig2*(ones(dimX,1)-(rrP/metaData.build.RK)*Qrr+...
%                 u'/metaData.build.fcCfct*u);
%         case 'LU'
%             rrP=rr(metaData.build.PK,:);
%             Lrr=metaData.build.LK\rrP;
%             u=metaData.build.fcU*Lrr-ff';
%             variance=metaData.build.sig2*(ones(dimX,1)-(rr'/metaData.build.UK)*Lrr+...
%                 u'/metaData.build.fcCfct*u);
%         case 'LL'
%             Lrr=metaData.build.LK\rr;
%             u=metaData.build.fcL*Lrr-ff';
%             variance=metaData.build.sig2*(ones(dimX,1)-(rr'/metaData.build.LtK)*Lrr+...
%                 u'/metaData.build.fcCfct*u);
%         otherwise
%             rKrr=metaData.build.KK \ rr;
%             u=metaData.build.fc*rKrr-ff';
%             variance=metaData.build.sig2*(ones(dimX,1)+u'/metaData.build.fcCfct*u - rr'*rKrr);
%     end
%     if ~dispWarning;warning on all;end
%
% end

end