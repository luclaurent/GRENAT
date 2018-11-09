%% Method of SVR class
% L. LAURENT -- 18/08/2017 -- luc.laurent@lecnam.net

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

%% Core of kriging computation using no factorization
% INPUTS:
% - none
% OUTPUTS:
% - none

function coreClassical(obj)
%coefficients for detecting Support vector
epsM=eps;
%load data
ns=obj.nS;
np=obj.nP;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Solving the Convex Constrained Quadaratic Optimization problem
[solQP, obj.fVal, obj.exitFlag, lmQP]=ExecQP(obj.PsiT,...
    obj.CC,...
    obj.Aineq,...
    obj.bineq,...
    obj.Aeq,...
    obj.beq,...
    obj.lb,...
    obj.ub,...
    obj.optsQP);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Specific data for none-gradient-based SVR
obj.alphaRAW=solQP(1:2*ns);
obj.alphaPM=obj.alphaRAW(1:ns)-obj.alphaRAW(ns+1:2*ns);
obj.alphaPP=obj.alphaRAW(1:ns)+obj.alphaRAW(ns+1:2*ns);

%find support vectors with specific property
svPM=find(abs(obj.alphaPM)>obj.lb(1:ns)+epsM);
svPP=find(obj.alphaPP>obj.lb(1:ns)+epsM);

%Unbounded SV's or free SV's
svUSV=find(obj.alphaPP>obj.lb(1:ns)+epsM & obj.alphaPP<obj.ub(1:ns)-epsM);
%Bounded SV's
svBSV=find(obj.alphaPP<obj.lb(1:ns)+epsM | obj.alphaPP>obj.ub(1:ns)-epsM);

%finding SV's corresponding to value of alpha situated in the middle of
%[lb,ub]
[svMidP,svMidPIX]=min(abs(abs(obj.alphaRAW(1:ns))-obj.ub(1:ns)/2));
[svMidM,svMidMIX]=min(abs(abs(obj.alphaRAW(ns+1:2*ns))-obj.ub(ns+1:2*ns)/2));

%in the case of gradient-based approach
obj.lambdaPM=[];
obj.lambdaPP=[];
obj.lambdaRAW=[];
iXsvT=svPM;
iXsvPM=svPM;
iXsvPP=svPP;
obj.iXsvUSV=svUSV;
obj.iXsvBSV=svBSV;
%
if obj.flagG
    obj.lambdaRAW=solQP(2*ns+1:end);
    obj.lambdaPM=obj.lambdaRAW(1:ns*np)-obj.lambdaRAW(ns*np+1:end);
    obj.lambdaPP=obj.lambdaRAW(1:ns*np)+obj.lambdaRAW(ns*np+1:end);
    %compute indexes of the the gradients associated to the support vectors
    liNp=1:np;
    repI=ones(np,1);
    iXDsvI=liNp(ones(numel(iXsvT),1),:)+np*(iXsvT(:,repI)-1);
    iXDsvI=iXDsvI';
    iXsvT=[svPM;ns+iXDsvI(:)];
    
    %find support vectors dedicated to gradients
    svDI=find(abs(obj.lambdaPM)>epsM);
    [svMiddP,svMiddPIX]=min(abs(abs(obj.lambdaRAW(1:ns*np)-obj.ub(2*ns+1:ns*(np+2))/2)));
    [svMiddM,svMiddMIX]=min(abs(abs(obj.lambdaRAW(ns*np+1:2*ns*np)-obj.ub(ns*(np+2)+1:2*ns*(1+np))/2)));
    
end
%Full data
obj.FullAlphaLambdaPM=[obj.alphaPM;obj.lambdaPM];
obj.FullAlphaLambdaPP=[obj.alphaPP;obj.lambdaPP];
obj.FullAlphaLambdaRAW=solQP;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute epsilon
%eM=0.5*(dataIn.used.resp(svMidPIX)...
%    -dataIn.used.resp(svMidMIX)...
%    -FullAlphaLambdaPM(iXsvT)'*PsiR(svMidPIX,iXsvT)'...
%    +FullAlphaLambdaPM(iXsvT)'*PsiR(iXsvT,svMidMIX));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute the base term
% SVRmuM=dataIn.used.resp(svMidPIX)...
%     -eM*sign(alphaPM(svMidPIX))...
%     -FullAlphaLambdaPM(iXsvT)'*PsiR(iXsvT,svMidPIX);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lagrange multipliers give the values of mu and epsilon
obj.e=lmQP.ineqlin(1);
obj.xiTau=lmQP.lower;
%e
obj.SVRmu=lmQP.eqlin;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Number of Unbounded and Bounded SVs
obj.nbUSV=numel(obj.iXsvUSV);
obj.nbBSV=numel(obj.iXsvBSV);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build matrices
%remove bounded supports vectors
obj.PsiUSV=obj.K(obj.iXsvUSV(:),obj.iXsvUSV(:));
obj.KUSV=[obj.PsiUSV ones(obj.nbUSV,1);ones(1,obj.nbUSV) 0];
obj.iKUSV=inv(obj.KUSV);
end