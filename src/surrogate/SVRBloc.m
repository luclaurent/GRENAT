%% Building of the nu-SVR/GSVR matrix
% L. LAURENT -- 24/05/2016 -- luc.laurent@lecnam.net

%this function can be used as an objective function for finding
%hyperparameters via optimization


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
opts = optimoptions('quadprog','Diagnostics','off','Display','none');
[solQP,fval,exitflag,infoIPM,lmQP]=quadprog(PsiT,CC,AA,bb,Aeq,beq,lb,ub,[],opts);
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

%compute epsilon
eM=0.5*(dataIn.used.resp(svMidPIX)...
    -dataIn.used.resp(svMidMIX)...
    -alphaPM(svPM)'*PsiT(svPM,svMidPIX)...
    +alphaPM(svPM)'*PsiT(svPM,svMidMIX));

%compute the base term
SVRmuM=dataIn.used.resp(svMidPIX)...
    -eM*sign(alphaPM(svMidPIX))...
    -alphaPM(svPM)'*PsiT(svPM,svMidPIX);

%lagrange multipliers give the values of mu and epsilon
e=lmQP.ineqlin(1);
SVRmu=lmQP.eqlin;

%in the case of gradient-based approach
lambdaPM=[];
lambdaPP=[];
lambdaRAW=[];
iXsv=svPM;
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
    iXDsvI=ns+liNp(ones(numel(svPM),1),:)+np*(svPM(:,repI)-1);
    iXsv=[svPM iXDsvI];

    %find support vectors dedicated to gradients
    svDI=find(abs(lambdaPM)>epsM);
    [svMiddP,svMiddPIX]=min(abs(abs(lambdaRAW(1:ns*np)-ub(2*ns+1:ns*(np+2))/2)));
    [svMiddM,svMiddMIX]=min(abs(abs(lambdaRAW(ns*np+1:2*ns*np)-ub(ns*(np+2)+1:2*ns*(1+np))/2)));
    
    %compute epsilon
    eM=0.5*(dataIn.used.resp(svMidPIX)...
        -dataIn.used.resp(svMidMIX)...
        -alphaPM(svPM)'*Psi(svPM,svMidPIX)...
        -lambdaPM(svPM)'*PsiDo(svMidPIX,svPM)'...
        +alphaPM(svPM)'*Psi(svPM,svMidMIX)...
        +lambdaPM(svPM)'*PsiDo(svMidMIX,svPM)');
    %compute the base term
    SVRmuM=dataIn.used.resp(svMidPIX)...
        -eM*sign(alphaPM(svMidPIX))...
        -alphaPM(svPM)'*Psi(svPM,svMidPIX)...
        -lambdaPM(svPM)'*PsiDo(svMidPIX,svPM)';
    e=eM;
    SVRmu=SVRmuM;
end
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


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Factorization of the matrix
% switch factKK
%     case 'QR'
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %QR factorization
%         [QK,RK,PK]=qr(KK);
%         QtK=QK';
%         yQ=QtK*dataIn.build.y;
%         fctQ=QtK*dataIn.build.fct;
%         fcK=dataIn.build.fc*PK/RK;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %compute beta coefficient
%         fcCfct=fcK*fctQ;
%         block2=fcK*yQ;
%         beta=fcCfct\block2;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %compute gamma coefficient
%         gamma=PK*(RK\(yQ-fctQ*beta));
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %save variables
%         buildData.yQ=yQ;
%         buildData.fctQ=fctQ;
%         buildData.fcK=fcK;
%         buildData.fcCfct=fcCfct;
%         buildData.RK=RK;
%         buildData.QK=QK;
%         buildData.QtK=QtK;
%         buildData.PK=PK;
%
%     case 'LU'
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %LU factorization
%         [LK,UK,PK]=lu(KK,'vector');
%         yP=dataIn.build.y(PK,:);
%         fctP=dataIn.build.fct(PK,:);
%         yL=LK\yP;
%         fctL=LK\fctP;
%         fcU=dataIn.build.fc/UK;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %compute beta coefficient
%         fcCfct=fcU*fctL;
%         block2=fcU*yL;
%         beta=fcCfct\block2;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %compute gamma coefficient
%         gamma=UK\(yL-fctL*beta);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %save variables
%         buildData.yL=yL;
%         buildData.fcU=fcU;
%         buildData.fctL=fctL;
%         buildData.fcCfct=fcCfct;
%         buildData.LK=LK;
%         buildData.UK=UK;
%         buildData.PK=PK;
%     case 'LL'
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %Cholesky's fatorization
%         %%% to be degugged
%         LK=chol(KK,'lower');
%         LtK=LK';
%         yL=LK\dataIn.build.y;
%         fctL=LK\dataIn.build.fct;
%         fcL=dataIn.build.fc/LtK;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %compute beta coefficient
%         fcCfct=fcL*fctL;
%         block2=fcL*yL;
%         beta=fcCfct\block2;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %compute gamma coefficient
%         gamma=LtK\(yL-fctL*beta);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %save variables
%         buildData.yL=yL;
%         buildData.fcL=fcL;
%         buildData.fctL=fctL;
%         buildData.fcCfct=fcCfct;
%         buildData.LtK=LtK;
%         buildData.LK=LK;
%     otherwise
%         %classical approach
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %compute gamma and beta coefficients
%         fcC=dataIn.build.fc/KK;
%         fcCfct=fcC*dataIn.build.fct;
%         block2=((dataIn.build.fc/KK)*dataIn.build.y);
%         beta=fcCfct\block2;
%         gamma=KK\(dataIn.build.y-dataIn.build.fct*beta);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %save variables
%         buildData.fcC=fcC;
%         buildData.fcCfct=fcCfct;
% end