%% Building of the nu-SVR/GSVR matrix
% L. LAURENT -- 24/05/2016 -- luc.laurent@lecnam.net

%this function can be used as an objective function for finding
%hyperparameters via optimization


function [ret]=SVRBloc(dataIn,metaData,paraValIn,type)

%coefficient for reconditionning (G)SVR matrix
coefRecond=eps;
% chosen factorization for (G)KRG matrix
if strcmp(metaData.type,'GSVR')
    factKK='LU';
else
    factKK='LU' ; %LU %QR %LL %None
end
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
    PsiDo=[KKa -KKa; -KKa KKa];
    PsiDDo=[KKi -KKi;-KKi KKi];
    PsiT=[Psi PsiDo;PsiDo' PsiDDo];
else
    [KK]=KernMatrix(fctKern,dataIn,paraVal);
    PsiT=[KK -KK;-KK KK];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% rewrite this part
% %in the case of missing data
% %responses
% if metaData.miss.resp.on
%     KK(metaData.miss.resp.ix_miss,:)=[];
%     KK(:,metaData.miss.resp.ix_miss)=[];
% end
% %gradients
% if dataIn.used.availGrad
%     if metaData.miss.grad.on
%         rep_ev=ns-metaData.miss.resp.nb;
%         KK(rep_ev+metaData.miss.grad.ixt_miss_line,:)=[];
%         KK(:,rep_ev+metaData.miss.grad.ixt_miss_line)=[];
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if datain.used.pres_grad
%     %si parallelisme actif ou non
%     if metaData.worker_parallel>=2
%         %%%%%% PARALLEL %%%%%%
%         %morceaux de la matrice GKRG
%         rc=zeros(ns,ns);
%         rca=cell(1,ns);
%         rci=cell(1,ns);
%         parfor ii=1:ns
%             %distance 1 tirages aux autres (construction par colonne)
%             one_tir=tiragesn(ii,:);
%             dist=one_tir(ones(1,ns),:)-tiragesn;
%             % evaluation de la fonction de correlation
%             [ev,dev,ddev]=feval(fctKern,dist,paraVal);
%             %morceau de la matrice issue du modele KRG classique
%             rc(:,ii)=ev;
%             %morceau des derivees premieres
%             rca{ii}=dev;
%             %matrice des derivees secondes
%             rci{ii}=-reshape(ddev,np,ns*np);
%         end
%         %%construction des matrices completes
%         rcaC=horzcat(rca{:});
%         rciC=vertcat(rci{:});
%         %Matrice de complete
%         rcc=[rc rcaC;rcaC' rciC];
%     else
%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %evaluation de la fonction de correlation pour les differents
%         %intersites
%         [ev,dev,ddev]=feval(fctKern,datain.used.dist,paraVal);
%
%         %morceau de la matrice issu du krigeage
%         rc=zeros(ns,ns);
%         rca=zeros(ns,np*ns);
%         rci=zeros(ns*np,ns*np);
%
%         rc(datain.usedd.matrix)=ev;
%         rc=rc+rc'-eye(datain.used.nb_val);
%
%         rca(datain.usedd.matrixA)=dev(datain.usedd.dev);
%         rca(datain.usedd.matrixAb)=-dev(datain.usedd.devb);
%         rci(datain.usedd.matrixI)=-ddev(:);
%         %extraction de la diagonale (procedure pour eviter les doublons)
%         diago=0;   % //!!\\ corrections envisageables ici
%         val_diag=spdiags(rci,diago);
%         rci=rci+rci'-spdiags(val_diag,diago,zeros(size(rci))); %correction termes diagonaux pour eviter les doublons
%
%         %Matrice de correlation du Cokrigeage
%         rcc=[rc rca;rca' rci];
%     end
%     %si donnees manquantes
%     if dataIn.manq.eval.on
%         rcc(dataIn.manq.eval.ix_manq,:)=[];
%         rcc(:,dataIn.manq.eval.ix_manq)=[];
%     end
%
%     %si donnees manquantes
%     if dataIn.manq.grad.on
%         rep_ev=ns-dataIn.manq.eval.nb;
%         rcc(rep_ev+dataIn.manq.grad.ixt_manq_line,:)=[];
%         rcc(:,rep_ev+dataIn.manq.grad.ixt_manq_line)=[];
%     end
% else
%
%     if metaData.worker_parallel>=2
%         %%%%%% PARALLEL %%%%%%
%         %matrice de KRG classique par bloc
%         rcc=zeros(ns,ns);
%         parfor ii=1:ns
%             %distance 1 tirages aux autres (construction par colonne)
%             one_tir=tiragesn(ii,:);
%             dist=one_tir(ones(1,ns),:)-tiragesn;
%             % evaluation de la fonction de correlation
%             [ev]=feval(fctKern,dist,paraVal);
%             %morceau de la matrice issue du modele RBF classique
%             rcc(:,ii)=ev;
%         end
%     else
%         %matrice de correlation du Krigeage par matrice triangulaire inferieure
%         %sans diagonale
%         rcc=zeros(ns,ns);
%         % evaluation de la fonction de correlation
%         [ev]=feval(fctKern,datain.used.dist,paraVal);
%         rcc(datain.usedd.matrix)=ev;
%         %Construction matrice complete
%         rcc=rcc+rcc'+eye(ns);
%     end
%     %toc
%     %si donnees manquantes
%     if dataIn.manq.eval.on
%         rcc(dataIn.manq.eval.ix_manq,:)=[];
%         rcc(:,dataIn.manq.eval.ix_manq)=[];
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Improve condition number of the SVR/GSVR Matrix
% if metaData.recond
%     %origCond=condest(rcc);
%     KK=KK+coefRecond*speye(size(KK));
%     %newCond=condest(rcc);
%     %fprintf('>>> Improving of the condition number: \n%g >> %g  <<<\n',...
%     %    origCond,newCond);
%
% end

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
    Aeq=[Aeq zeros(1,ns) zeros(1,ns)];
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
%starting point for optimizer
x0=zeros(2*ns,1);
if dataIn.used.availGrad
    x0=[x0 zeros(2*np*ns,1)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Solving the Convex Constrained Quadaratic Optimization problem
opts = optimoptions('quadprog','Diagnostics','off','Display','iter');
solQP=quadprog(PsiT,CC,AA,bb,Aeq,beq,lb,ub);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extract result of optimization
alphaRAW=solQP(1:2*ns);
alphaPM=alphaRAW(1:ns)-alphaRAW(ns+1:2*ns);
FullAlphaLambdaPM=alphaPM;
%find support vectors
svI=find(abs(alphaPM)>metaData.para.xi);
[svMidP,svMidPIX]=min(abs(abs(alphaRAW(1:ns))-ub(1:ns)/2));
[svMidM,svMidMIX]=min(abs(abs(alphaRAW(ns+1:2*ns))-ub(ns+1:2*ns)/2));

%compute epsilon
e=0.5*(dataIn.used.resp(svMidPIX)...
    -dataIn.used.resp(svMidMIX)...
    -alphaPM(svI)'*PsiT(svI,svMidPIX)...
    +alphaPM(svI)'*PsiT(svI,svMidMIX));

%compute the base term
SVRmu=dataIn.used.resp(svMidPIX)...
    -e*sign(alphaPM(svMidPIX))...
    -alphaPM(svI)'*PsiT(svI,svMidPIX);

%in the case of gradient-based approach
lambdaPM=[];
if dataIn.used.availGrad
    lambdaRAW=solQP(2*ns+1:end);
    lambdaPM=lambdaRAW(1:ns*np)-lambdaRAW(ns*np+1:end);
    FullAlphaLambdaPM=[alphaPM;lambdaPM];
    %find support vectors dedicated to gradients
    svDI=find(abs(lambdaPM)>metaData.para.taui);
    [svMiddP,svMiddPIX]=min(abs(abs(lambdaRAW(1:ns*np)-ub(2*ns+1:ns*(np+2))/2)));
    [svMiddM,svMiddMIX]=min(abs(abs(lambdaRAW(ns*np+1:2*ns*np)-ub(ns*(np+2)+1:2*ns*(1+np))/2)));
    
    %compute epsilon
    e=0.5*(dataIn.used.resp(svMidPIX)...
        -dataIn.used.resp(svMidMIX)...
        -alphaPM(svI)'*Psi(svI,svMidPIX)...
        -lambdaPM(svI)'*PsiDo(svMidPIX,svI)'...
        +alphaPM(svI)'*Psi(svI,svMidMIX)...
        +lambdaPM(svI)'*PsiDo(svMidMIX,svI)');
    %compute the base term
    SVRmu=dataIn.used.resp(svMidPIX)...
        -e*sign(alphaPM(svMidPIX))...
        -alphaPM(svI)'*Psi(svI,svMidPIX)...
        -lambdaPM(svI)'*PsiDo(svMidPIX,svI)';
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store variables
if exist('origCond','var');buildData.origCond=origCond;end
if exist('newCond','var');buildData.newCond=newCond;end

buildData.PsiT=PsiT;
buildData.SVRmu=SVRmu;
buildData.para=metaData.para;
buildData.alphaLambdaPM=FullAlphaLambdaPM;
ret.build=buildData;
