%% function for evaluating the RBF surrogate model at many points
% RBF: w/o gradient
% GBRF: w/- gradients
% L. LAURENT -- 15/03/2010 -- luc.laurent@lecnam.net
% changes 20/01/2012

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

function [Z,GZ,variance]=RBFEval(U,metaData,specifSampling)
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
X=U(:)';    %correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%distance from evaluation point to sample points
distS=repmat(X,ns,1)-sampling;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RBF/GRBF
if metaData.used.availGrad
    if calcGrad  %if compute gradients
        %evaluate kernel function
        [ev,dev,ddev]=multiKernel(metaData.build.kern,distS,metaData.build.para.Val);
        %reordering responses and gradients
        %P=[F1 F2 ... Fn dF1/dx1 dF1/dx2 ... dF1/dxp dF2/dx1 dF2/dx2 ...dFn/dxp]
        P=[ev' -reshape(dev',1,ns*np)];
        
        %P=[ev;dda(:)];
        %reordering first and second derivatives
        %dP=[(dF1/dx1 dF1/dx2 ... dF1/dxp)' (dF2/dx1 dF2/dx2 ...dFn/dxp)' ]
        %dP=horzcat(-dda,reshape(ddev,nb_var,[]));
        %derivatives of the vector of the evaluation of kernel function
        dP=[dev' -reshape(ddev,np,[])];
        
        %if missing responses
        if metaData.miss.resp.on
            P(metaData.miss.resp.ixMiss)=[];
            dP(:,metaData.miss.resp.ixMiss)=[];
        end
        
        %if missing gradients
        if metaData.miss.grad.on
            respEv=ns-metaData.miss.resp.nb;
            P(respEv+metaData.miss.grad.ixtMissLine)=[];
            dP(:,respEv+metaData.miss.grad.ixtMissLine)=[];
        end
        
    else %otherwise
        %evaluate kernel function
        [ev,dev]=multiKernel(metaData.build.kern,distS,metaData.build.para.Val);
        %reordering responses and gradients
        %P=[F1 F2 ... Fn dF1/dx1 dF1/dx2 ... dF1/dxp dF2/dx1 dF2/dx2 ...dFn/dxp]
        P=[ev' -reshape(dev',1,ns*np)];
        %if missing responses
        if metaData.miss.resp.on
            P(metaData.miss.resp.ixMiss)=[];
        end
    end
else
    if calcGrad  %if compute gradients        
        [P,dP]=multiKernel(metaData.build.kern,distS,metaData.build.para.Val);P=P';dP=dP';
        %if missing responses
        if metaData.miss.resp.on
            P(metaData.miss.resp.ixMiss)=[];
            dP(:,metaData.miss.resp.ixMiss)=[];
        end
    else %otherwise
        P=feval(metaData.build.fct,distS,metaData.build.para.Val);P=P';
        %%if missing responses
        if metaData.miss.resp.on
            P(metaData.miss.resp.ixMiss)=[];
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation surrogate model at point X
Z=P*metaData.build.w;
if calcGrad
    GZ=dP*metaData.build.w;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute variance of the surrogate model (Bompard 2011,Sobester 2005, Gibbs 1997)
if nargout >=3
    if ~dispWarning;warning off all;end
    Pb=P;
    %correction for taking into account gradients (debug ....)
    if metaData.used.availGrad
        Pb(ns+1:end)=-Pb(ns+1:end);
    end
    variance=1-P*(metaData.build.KK\Pb');
    if ~dispWarning;warning on all;end
end
end
