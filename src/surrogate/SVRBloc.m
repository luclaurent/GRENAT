%% Building of the nu-SVR/GSVR matrix
% L. LAURENT -- 24/05/2016 -- luc.laurent@lecnam.net
%
%this function can be used as an objective function for finding
%hyperparameters via optimization

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


function [critMin,ret]=SVRBloc(dataIn,metaData,paraValIn,type)

%coefficient for reconditionning (G)SVR matrix
coefRecond=eps;
%coefficients for detecting Support vector
epsM=eps;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load useful variables
ns=dataIn.used.ns;
np=dataIn.used.np;
fctKern=metaData.kern;
YYY=dataIn.build.y;
c0=metaData.para.c0;
ck=metaData.para.ck;
ret=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Conditioning data for  gradient-based approach
if numel(ck)==1
    ck=ck(:,ones(1,np));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if the hyperparameter is defined
finalStatus=false;
if nargin>=3
    paraVal=paraValIn;
else
    paraVal=metaData.para.val;
    finalStatus=true;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build of the SVR/GSVR matrix
if dataIn.used.availGrad
    [KK,KKa,KKi]=KernMatrix(fctKern,dataIn,paraVal);
    Psi=[KK -KK;-KK KK];
    PsiDo=-[KKa -KKa; -KKa KKa];
    PsiDDo=-[KKi -KKi;-KKi KKi];
    PsiT=[Psi PsiDo;PsiDo' PsiDDo];
    PsiR=[KK -KKa;-KKa' -KKi];
else
    [KK]=KernMatrix(fctKern,dataIn,paraVal);
    PsiT=[KK -KK;-KK KK];
    PsiR=KK;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build terms of the convex constrained quadratic optimization
CC=YYY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bounds of the dual variables
lb=zeros(2*ns,1);
c0=metaData.para.c0/ns*ones(2*ns,1);
ub=c0;
if dataIn.used.availGrad
    lb=[lb;zeros(2*np*ns,1)];
    ckV=ck(:,ones(1,2*np*ns))/ns;
    ckV=ckV(:);
    ub=[ub;ckV];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build equality constraints
Aeq=[ones(1,ns) -ones(1,ns)];
beq=0;
if dataIn.used.availGrad
    Aeq=[Aeq zeros(1,2*ns*np)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build inequality constraints
AA=ones(1,2*ns);
bb=metaData.para.c0*metaData.para.nuSVR;
if dataIn.used.availGrad
    bb=[bb;ck(:)*metaData.para.nuGSVR];
    AA=[AA zeros(1,2*ns*np);
        zeros(np,2*ns) repmat(eye(np),1,2*ns)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Solving the Convex Constrained Quadaratic Optimization problem
[solQP, obj, info, lmQP]=ExecQP(PsiT,CC,AA,bb,Aeq,beq,lb,ub);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Specific data for none-gradient-based SVR
alphaRAW=solQP(1:2*ns);
alphaPM=alphaRAW(1:ns)-alphaRAW(ns+1:2*ns);
alphaPP=alphaRAW(1:ns)+alphaRAW(ns+1:2*ns);

%Full data
FullAlphaLambdaPM=alphaPM;
FullAlphaLambdaPP=alphaPP;
FullAlphaLambdaRAW=solQP;

%find support vectors with specific property
svPM=find(abs(alphaPM)>lb(1:ns)+epsM);
svPP=find(alphaPP>lb(1:ns)+epsM);

%Unbounded SV's or free SV's
svUSV=find(alphaPP>lb(1:ns)+epsM & alphaPP<ub(1:ns)-epsM);
%Bounded SV's
svBSV=find(alphaPP<lb(1:ns)+epsM | alphaPP>ub(1:ns)-epsM);

%finding SV's corresponding to value of alpha situated in the middle of
%[lb,ub]
[svMidP,svMidPIX]=min(abs(abs(alphaRAW(1:ns))-ub(1:ns)/2));
[svMidM,svMidMIX]=min(abs(abs(alphaRAW(ns+1:2*ns))-ub(ns+1:2*ns)/2));

%in the case of gradient-based approach
lambdaPM=[];
lambdaPP=[];
lambdaRAW=[];
iXsvT=svPM;
iXsvPM=svPM;
iXsvPP=svPP;
iXsvUSV=svUSV;
iXsvBSV=svBSV;
%
if dataIn.used.availGrad
    lambdaRAW=solQP(2*ns+1:end);
    lambdaPM=lambdaRAW(1:ns*np)-lambdaRAW(ns*np+1:end);
    lambdaPP=lambdaRAW(1:ns*np)+lambdaRAW(ns*np+1:end);
    FullAlphaLambdaPM=[alphaPM;lambdaPM];
    FullAlphaLambdaPP=[alphaPP;lambdaPP];
    %compute indexes of the the gradients associated to the support vectors
    liNp=1:np;
    repI=ones(np,1);
    iXDsvI=liNp(ones(numel(iXsvT),1),:)+np*(iXsvT(:,repI)-1);
    iXDsvI=iXDsvI';
    iXsvT=[svPM;ns+iXDsvI(:)];
    
    %find support vectors dedicated to gradients
    svDI=find(abs(lambdaPM)>epsM);
    [svMiddP,svMiddPIX]=min(abs(abs(lambdaRAW(1:ns*np)-ub(2*ns+1:ns*(np+2))/2)));
    [svMiddM,svMiddMIX]=min(abs(abs(lambdaRAW(ns*np+1:2*ns*np)-ub(ns*(np+2)+1:2*ns*(1+np))/2)));
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute epsilon
% eM=0.5*(dataIn.used.resp(svMidPIX)...
%     -dataIn.used.resp(svMidMIX)...
%     -FullAlphaLambdaPM(iXsvT)'*PsiR(svMidPIX,iXsvT)'...
%     +FullAlphaLambdaPM(iXsvT)'*PsiR(iXsvT,svMidMIX));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute the base term
% SVRmuM=dataIn.used.resp(svMidPIX)...
%     -eM*sign(alphaPM(svMidPIX))...
%     -FullAlphaLambdaPM(iXsvT)'*PsiR(iXsvT,svMidPIX);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lagrange multipliers give the values of mu and epsilon
e=lmQP.ineqlin(1);
SVRmu=lmQP.eqlin;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Number of Unbounded and Bounded SVs
nbUSV=numel(iXsvUSV);
nbBSV=numel(iXsvBSV);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build matrices
%remove bounded supports vectors
PsiUSV=PsiR(iXsvUSV(:),iXsvUSV(:));
KUSV=[PsiUSV ones(nbUSV,1);ones(1,nbUSV) 0];
iKUSV=inv(KUSV);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store variables
if exist('origCond','var');buildData.origCond=origCond;end
if exist('newCond','var');buildData.newCond=newCond;end
buildData.PsiT=PsiT;
buildData.PsiR=PsiR;
buildData.PsiUSV=PsiUSV;
buildData.KUSV=KUSV;
buildData.iKUSV=iKUSV;
buildData.iXsvPM=iXsvPM;
buildData.iXsvPP=iXsvPP;
buildData.iXsvUSV=iXsvUSV;
buildData.iXsvBSV=iXsvBSV;
buildData.nbUSV=nbUSV;
buildData.nbBSV=nbBSV;
buildData.xiTau=lmQP.lower;%lmQP.upper(1:ns)-lmQP.upper(ns+1:2*ns);
buildData.e0=e;
buildData.c0=metaData.para.c0;
buildData.ck=metaData.para.ck;
buildData.SVRmu=SVRmu;
buildData.para=metaData.para;
buildData.alphaPM=alphaPM;
buildData.lambdaPM=lambdaPM;
buildData.lambdaPP=lambdaPP;
buildData.alphaPP=alphaPP;
buildData.alphaRAW=alphaRAW;
buildData.lambdaRAW=lambdaRAW;
buildData.alphaLambdaPM=FullAlphaLambdaPM;
buildData.FullAlphaLambdaRAW=FullAlphaLambdaRAW;
buildData.alphaLambdaPP=FullAlphaLambdaPP;
ret.build=buildData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute of the Likelihood (and log-likelihood)
%[spanBound,Bound,loo,spanBoundb]=SVRSB(ret,dataIn,metaData);
[spanBound]=SVRSB(ret,dataIn,metaData);


%ret.build.spanBoundb=spanBoundb;
ret.build.spanBound=spanBound;
critMin=spanBound;
%ret.build.Bound=Bound;
%ret.build.loo=loo;

end

%specific execution of Quadratic Programming depending on Matlab/Octave
function [solQP, fval, exitflag, lmQP]=ExecQP(PsiT,CC,AA,bb,Aeq,beq,lb,ub)
if isOctave
[solQP, fval, info, lambda] = qp (zeros(size(CC)),PsiT,CC,Aeq,beq,lb,ub,[], AA, bb);
exitflag=info.info;
lmQP.ineqlin=lambda((end-numel(bb)+1):end);
lmQP.eqlin=-lambda(1:numel(beq));
lmQP.lower=lambda(numel(beq)+(1:numel(lb)));
lmQP.upper=lambda(numel(beq)+numel(lb)+(1:numel(ub)));
else
opts = optimoptions('quadprog','Diagnostics','off','Display','none');
[solQP,fval,exitflag,~,lmQP]=quadprog(PsiT,CC,AA,bb,Aeq,beq,lb,ub,[],opts);
end
end

