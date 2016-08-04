%% function for evaluating the gradient-based and non-gradient-based SVR surrogate model at many points
% SVR: w/o gradient
% GSVR: w/- gradients
% L. LAURENT -- 24/05/2016 -- luc.laurent@lecnam.net

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

function [Z,GZ,variance]=SVREval(U,metaData,specifSampling)

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
        [ev,dev,ddev]=multiKernel(metaData.build.kern,distS,metaData.build.para.Val);
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
        [ev,dev]=multiKernel(metaData.build.kern,distS,metaData.build.para.Val);
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
        [rr,jr]=multiKernel(metaData.build.kern,distS,metaData.build.para.Val);
    else %otherwise
        rr=feval(metaData.build.kern,distS,metaData.build.para.Val);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute the prediction variance (Bompard 2011, Gao et al. 2002)
if nargout >=3
    %intrinsic variance
    c0=metaData.build.c0;
    e0=metaData.build.e0;
    varianceI=2/c0^+1/3*e0^2*(3+e0*c0)/(e0*c0+1);
    
    %reduction to the unbounded support vectors
    %depending on gradient- or none-gradient-based GSVR
    iXsvUSV=metaData.build.iXsvUSV;
    %remove bounded supports vectors
    rrUSV=rr(iXsvUSV(:));
    PsiUSV=metaData.build.PsiR(iXsvUSV(:),iXsvUSV(:));
    
    %variance due to the approximation
    varianceS=1-rrUSV'/PsiUSV*rrUSV;
    variance=varianceI+varianceS;
end

end