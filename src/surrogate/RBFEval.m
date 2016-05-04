%% function for evaluating the RBF surrogate model at many points
% RBF: w/o gradient
% GBRF: w/- gradients
% L. LAURENT -- 15/03/2010 -- luc.laurent@lecnam.net
% changes 20/01/2012

function [Z,GZ,variance]=RBFEval(U,data,specifSampling)
% display warning or not
dispWarning=false;
%load varibales
ns=data.in.ns;
np=data.in.np;

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
    sampling=data.in.sampling;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=U(:)';    %correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%distance from evaluation point to sample points
dist=repmat(X,ns,1)-sampling;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RBF/GRBF
if data.in.availGrad
    if calcGrad  %if compute gradients
        %evaluate kernel function
        [ev,dev,ddev]=multiKernel(data.build.kern,dist,data.build.para.l.val);
        %reordering responses and gradients
        %P=[F1 F2 ... Fn dF1/dx1 dF1/dx2 ... dF1/dxp dF2/dx1 dF2/dx2 ...dFn/dxp]
        P=[ev' reshape(dev',1,ns*np)];
        
        %P=[ev;dda(:)];
        %reordering first and second derivatives
        %dP=[(dF1/dx1 dF1/dx2 ... dF1/dxp)' (dF2/dx1 dF2/dx2 ...dFn/dxp)' ]
        %dP=horzcat(-dda,reshape(ddev,nb_var,[]));
        %derivatives of the vector of the evaluation of kernel function
        dP=[dev' reshape(ddev,np,[])];
        
        %if missing responses
        if data.miss.resp.on
            P(data.miss.resp.ixMiss)=[];
            dP(:,data.miss.resp.ixMiss)=[];
        end
        
        %if missing gradients
        if data.miss.grad.on
            respEv=ns-data.miss.resp.nb;
            P(respEv+data.miss.grad.ixtMissLine)=[];
            dP(:,respEv+data.miss.grad.ixtMissLine)=[];
        end
        
    else %otherwise
        %evaluate kernel function
        [ev,dev]=multiKernel(data.build.kern,dist,data.build.para.l.val);
        %reordering responses and gradients
        %P=[F1 F2 ... Fn dF1/dx1 dF1/dx2 ... dF1/dxp dF2/dx1 dF2/dx2 ...dFn/dxp]
        P=[ev' reshape(dev',1,ns*np)];
        %if missing responses
        if data.miss.resp.on
            P(data.miss.resp.ixMiss)=[];
        end
    end
else
    if calcGrad  %if compute gradients        
        [P,dP]=multiKernel(data.build.kern,dist,data.build.para.l.val);P=P';dP=dP';
        %if missing responses
        if data.miss.resp.on
            P(data.miss.resp.ixMiss)=[];
            dP(:,data.miss.resp.ixMiss)=[];
        end
    else %otherwise
        P=feval(data.build.fct,dist,data.build.para.val);P=P';
        %%if missing responses
        if data.miss.resp.on
            P(data.miss.resp.ixMiss)=[];
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation surrogate model at point X
Z=P*data.build.w;
if calcGrad
    GZ=dP*data.build.w;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute variance of the surrogate model (Bompard 2011,Sobester 2005, Gibbs 1997)
if nargout >=3
    if ~dispWarning;warning off all;end
    Pb=P;
    %correction for taking into account gradients (debug ....)
    if data.in.availGrad
        Pb(ns+1:end)=-Pb(ns+1:end);
    end
    variance=1-P*(data.build.KK\Pb');
    %if variance<0
    
    %data.build.KK
    % P*(data.build.KK\P')
    %variance
    %pause
    %end
    if ~dispWarning;warning on all;end
end
end