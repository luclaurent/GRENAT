%% function for evaluating the (co)Kriging surrogate model at many points
% KRG: w/o gradient
% GKRG: w/- gradients
% L. LAURENT -- 15/12/2011 -- luc.laurent@lecnam.net

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

function [Z,GZ,variance,details]=KRGEval(U,metaData,specifSampling)
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
%% KRG/GKRG
%%compute response provided by the metamodel at the non sample point
%definition des dimensions of the matrix/vector for KRG or GKRG
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

%KRG/GKRG
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
%regression matrix at the non-sample points
if calcGrad
    [ff,~,jf,~]=feval(metaData.build.funPoly,X);
    jf=vertcat(jf{:});
else
    ff=feval(metaData.build.funPoly,X);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation of the surrogate model at point X
trZ=ff*metaData.build.beta;
stoZ=rr'*metaData.build.gamma;
Z=trZ+stoZ;
if calcGrad
    %%verif in 2D+
    trGZ=jf*metaData.build.beta;
    stoGZ=jr'*metaData.build.gamma;
    GZ=trGZ+stoGZ;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute the prediction variance (MSE) (Lophaven, Nielsen & Sondergaard
%2004 / Marcelet 2008 / Chauvet 1999)
if nargout >=3
    if ~dispWarning;warning off all;end
    %depending on the factorization
    switch metaData.build.factKK
        case 'QR'
            rrP=rr'*metaData.build.PK;
            Qrr=metaData.build.QtK*rr;
            u=metaData.build.fcR*Qrr-ff';
            variance=metaData.build.sig2*(ones(dimX,1)-(rrP/metaData.build.RK)*Qrr+...
                u'/metaData.build.fcCfct*u);
        case 'LU'
            rrP=rr(metaData.build.PK,:);
            Lrr=metaData.build.LK\rrP;
            u=metaData.build.fcU*Lrr-ff';
            variance=metaData.build.sig2*(ones(dimX,1)-(rr'/metaData.build.UK)*Lrr+...
                u'/metaData.build.fcCfct*u);
        case 'LL'
            Lrr=metaData.build.LK\rr;
            u=metaData.build.fcL*Lrr-ff';
            variance=metaData.build.sig2*(ones(dimX,1)-(rr'/metaData.build.LtK)*Lrr+...
                u'/metaData.build.fcCfct*u);
        otherwise
            rKrr=metaData.build.KK \ rr;
            u=metaData.build.fc*rKrr-ff';
            variance=metaData.build.sig2*(ones(dimX,1)+u'/metaData.build.fcCfct*u - rr'*rKrr);
    end
    if ~dispWarning;warning on all;end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%extraction details
if nargout==4
    details.trZ=trZ;
    details.stoZ=stoZ;
    details.trGZ=trGZ;
    details.stoGZ=stoGZ;
end
end