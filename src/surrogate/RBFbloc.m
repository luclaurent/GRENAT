%% Building of the RBF/GRBF matrix and computation of the CV criteria
% L. LAURENT -- 24/01/2012 -- luc.laurent@lecnam.net

function [crit_min,ret]=RBFBloc(dataIn,metaData,paraVal,type)

% display warning(s) or not
dispWarning=false;
statusWarning=modWarning([],[]);
% function to be minimised for finding hyperparameters
fctMin='eloot'; %eloot/eloor/eloog
%coefficient of reconditionning
coef=eps;
% chosen factorization for RBF matrix
factKK='LU' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load useful variables
ns=dataIn.in.ns;
np=dataIn.in.np;
fctKern=metaData.kern;
ret=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if the hyperparameter is defined 
if nargin>=3
    valPara=paraVal;
    %in this case, the single required criterion is computed (estimation)
    typeCV='estim';
else
    valPara=metaData.para.val;
    typeCV='final';
end
metaData.para.l.val=valPara;

if nargin==4
    if strcmp(type,'etud');typeCV=type;end
    if strcmp(type,'estim');typeCV=type;end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build of the RBF/GRBF matrix
if dataIn.in.pres_grad
    [KK,KKa,KKi]=KernMatrix(fctKern,dataIn,valPara);
    KK=[KK KKa;-KKa' KKi];
else
    [KK]=KernMatrix(fctKern,dataIn,valPara);
end
%in the case of missing data
%responses
if dataIn.miss.resp.on
    KK(dataIn.miss.eval.ix_miss,:)=[];
    KK(:,dataIn.miss.eval.ix_miss)=[];
end
%gradients
if dataIn.in.pres_grad
    if dataIn.miss.grad.on
        rep_ev=ns-dataIn.miss.eval.nb;
        KK(rep_ev+dataIn.miss.grad.ixt_miss_line,:)=[];
        KK(:,rep_ev+dataIn.miss.grad.ixt_miss_line)=[];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Improve condition number of the RBF/GRBF Matrix
if metaData.recond
    %origCond=condest(KK);
    KK=KK+coef*speye(size(KK));
    %newCond=condest(KK);
%          fprintf('>>> Improving of the condition number: \n%g >> %g (%g) <<<\n',...
%              origCond,newCond,abs(origCond-newCond)/origCond);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%condition number of the RBF/GRBF Matrix
if nargin==2 % in the phase of building
    newCond=condest(KK);
    fprintf('Condition number RBF/GRBF matrix: %4.2e\n',newCond)
    if newCond>1e12
        fprintf('+++ //!\\ Bad condition number\n');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Factorization of the matrix
switch factKK
    case 'QR'
        %expensive
        [QKK,RKK,PKK]=qr(KK);
        iKK=PKK*(RKK\QKK');
        yQ=QKK'*dataIn.build.y;
        w=PKK*(RKK\yQ);
    case 'LU'
        %
        [LKK,UKK,PKK]=lu(KK);
        iKK=UKK\(LKK\PKK);
        yL=LKK\PKK*dataIn.build.y;
        w=UKK\yL;
    case 'LL'
        %symetric definite-positive matrix
        LKK=chol(KK,'lower');
        iKK=LKK'\inv(LKK);
        yL=LKK\dataIn.build.y;
        w=LKK'\yL;
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        if ~dispWarning; warning off all;end
        w=KK\dataIn.build.y;
        if ~dispWarning; warning on all;end
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
if exist('origCond','var');buildData.origCond=origCond;end
if exist('newCond','var');buildData.newCond=newCond;end
if exist('QKK','var');buildData.QKK=QKK;end
if exist('RKK','var');buildData.RKK=RKK;end
if exist('LKK','var');buildData.LKK=LKK;end
if exist('UKK','var');buildData.UKK=UKK;end
if exist('iKK','var');buildData.iKK=iKK;end
if exist('yQ','var');buildData.yQ=yQ;end
buildData.w=w;
buildData.KK=KK;
buildData.kern=metaData.kern;
buildData.para=metaData.para;
ret.build=buildData;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Cross-Validation (mandatory for estimating the hyperparameters
%%%%%Computation of various errors
if metaData.cv.on||metaData.para.estim
    [cv]=RBFCV(ret,dataIn,metaData,typeCV);
    if isfield(cv,fctMin)
        crit_min=cv.(fctMin);
    else
        crit_min=cv.eloot;
    end
else
    cv=[];
    crit_min=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ret.cv=cv;
modWarning([],statusWarning)
end
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function for stopping the display of the warning and restoring initial
% state
function retStatus=modWarning(requireStatus,oldStatus)
if nargin==1
if ~requireStatus
    warning off all
end    
else
    if isempty(oldStatus)
        retStatus=warning;
    else
        warning(oldStatus)
    end
end
end

