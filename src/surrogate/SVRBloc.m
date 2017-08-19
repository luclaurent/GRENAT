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
%if the hyperparameter is defined
finalStatus=false;
if nargin>=3
    paraVal=paraValIn;
else
    paraVal=metaData.para.Val;
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



