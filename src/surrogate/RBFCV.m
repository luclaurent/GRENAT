%% Function for computing various Cross-Validation criteria for RBF/GRBF
%L. LAURENT -- 14/12/2011 -- luc.laurent@lecnam.net
%new version: 31/05/2012

function [cv]=RBFCV(dataBloc,data,metaData,type)

%%DEBUG: procedure for missing data has to be coded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% OPTIONS
%choice of the norma for LOO error
%MSE: L2-norm
normLOO='L2';
%debug
debugP=false;

% display warning or not
dispWarning=false;

%parallel
numWorkers=0;
if ~isempty(whos('parallel','global'))
    global parallel
    numWorkers=parallel.num;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%various situations
modDebug=debugP;modStudy=metaData.cv.full;modFinal=false;

if nargin==4
    switch type
        case 'debug' %debug mode (display criteria)
            fprintf('+++ CV RBF/GRBF in DEBUG mode\n');
            modDebug=true;
        case 'study'  %study mode (use both methods for calculating criteria)
            modStudy=true;
        case 'estim'  %estimation mode
            modStudy=false;
        case 'final'  %final mode (compute variances)
            modFinal=true;
    end
else
    modFinal=true;
end
if modFinal;[tMesu,tInit]=mesuTime;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load variables
np=data.used.np;
ns=data.used.ns;
availGrad=data.used.availGrad;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Rippa's method (Rippa 1999/Fasshauer 2007/Bompard 2011)
% remove responses and then gradients (one by one)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vecteurs of the removed sample responses
esI=dataBloc.build.w./diag(dataBloc.build.iKK);
esR=esI(1:ns);
if availGrad;esG=esI(ns+1:end);end

%computation of the LOO criteria (various norms)
switch normLOO
    case 'L1'
        cv.then.press=esI'*esI;
        cv.then.eloot=1/numel(esI)*sum(abs(esI));
        cv.press=cv.then.press;
        cv.eloot=cv.then.eloot;
        if availGrad
            cv.then.eloor=1/ns*sum(abs(esR));
            cv.then.eloog=1/(ns*np)*sum(abs(esG));
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
        end
    case 'L2' %MSE
        cv.then.press=esI'*esI;
        cv.then.eloot=1/numel(esI)*(cv.then.press);
        cv.press=cv.then.press;
        cv.eloot=cv.then.eloot;
        if availGrad
            cv.then.press=esR'*esR;
            cv.then.eloor=1/ns*(cv.then.press);
            cv.then.eloog=1/(ns*np)*(esG'*esG);
            cv.press=cv.then.press;
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
        end
    case 'Linf'
        cv.then.press=esI'*esI;
        cv.then.eloot=1/numel(esI)*max(esI(:));
        cv.press=cv.then.press;
        cv.eloot=cv.then.eloot;
        if availGrad
            cv.then.press=esR'*esR;
            cv.then.eloor=1/ns*max(esR(:));
            cv.then.eloog=1/(ns*np)*max(esG(:));
            cv.press=cv.then.press;
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
        end
end
%mean of bias
cv.bm=1/ns*sum(esR);
%display information
if modDebug||modFinal
    fprintf('\n=== CV-LOO using Rippa''s methods (1999, extension by Bompard 2011)\n');
    fprintf('+++ Used norm for calculate CV-LOO: %s\n',normLOO);
    if availGrad
        fprintf('+++ Error on responses %4.2e\n',cv.then.eloor);
        fprintf('+++ Error on gradients %4.2e\n',cv.then.eloog);
    end
    fprintf('+++ Total error %4.2e\n',cv.then.eloot);
    fprintf('+++ PRESS %4.2e\n',cv.then.press);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Classical CV method (successively removing of responses and gradients))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if modDebug    
    [tMesuDebugA,tInitDebugA]=mesuTime;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %store response at removed point
    cvZ=zeros(ns,1);
    cvVar=zeros(ns,1);
    cvGZ=zeros(ns,np);
    yy=data.build.y;
    KK=dataBloc.build.KK;
    fctKern=dataBloc.build.fct;
    para=dataBloc.build.para;
    sampling=data.used.sampling;
    grad=data.used.grad;
    resp=data.used.resp;
    %along the sample points
    parfor (itS=1:ns,numWorkers)
        %remove responses
        %Load data
        dataCV=data;
        
        %remove data
        cvY=yy;
        cvKK=KK;
        cvY(itS,:)=[];
        cvKK(:,itS)=[];
        cvKK(itS,:)=[];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compute coefficients
        modWarning(dispWarning)
        cvW=cvKK\cvY;
        modWarning(~dispWarning)
        cvSampling=sampling;
        %remove of the associated response
        dataCV.miss.grad.on=false;
        dataCV.miss.resp.on=true;
        dataCV.miss.resp.ix_miss=itS;
        
        %remove data
        dataCV.build.fct=fctKern;
        dataCV.build.para=para;
        dataCV.build.w=cvW;
        dataCV.build.KK=cvKK;
        dataCV.used.ns=ns;
        dataCV.used.sampling=cvSampling;
        dataCV.infill.on=false;
        %evaluate response and variances on removed sample points
        [Z,~,variance]=RBFEval(sampling(itS,:),dataCV);
        cvZ(itS)=Z;
        cvVar(itS)=variance;
        
        %remove gradients
        if availGrad
            for posGr=1:np
                %load data
                dataCV=data;                
                %remove data
                cvY=yy;
                cvKK=KK;
                pos=ns+(itS-1)*np+posGr;
                cvY(pos,:)=[];
                cvKK(:,pos)=[];
                cvKK(pos,:)=[];
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %ccompute coefficients
                modWarning(dispWarning)
                cvW=cvKK\cvY;
                modWarning(~dispWarning)
                cvSampling=sampling;
                %remove associated gradient
                dataCV.miss.grad.on=true;
                dataCV.miss.resp.on=false;
                dataCV.miss.grad.ixt_miss_line=pos-ns;
                
                %remove
                dataCV.build.fct=fctKern;
                dataCV.build.para=para;
                dataCV.build.w=cvW;
                dataCV.build.KK=cvKK;
                dataCV.in.ns=ns;
                dataCV.in.sampling=cvSampling;
                dataCV.infill.on=false;
                %evaluate gradients on removed sample points
                [~,GZ,~]=RBFEval(sampling(itS,:),dataCV);
                cvGZ(itS,posGr)=GZ(posGr);
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% compute errors
    [cv.then]=LOOCalcError(resp,cvZ,cvVar,grad,cvGZ,ns,np,normLOO);
    %display information
    if modDebug||modFinal
        fprintf('\n=== CV-LOO with remove responses THEN the gradients (debug)\n');
        fprintf('+++ Used norm for calculate CV-LOO: %s\n',normLOO);
        if availGrad
            fprintf('+++ Error on responses %4.2e\n',cv.then.eloor);
            fprintf('+++ Error on gradients %4.2e\n',cv.then.eloog);
        end
        fprintf('+++ Total error %4.2e\n',cv.then.eloot);
        fprintf('+++ Mean bias %4.2e\n',cv.then.bm);
        fprintf('+++ PRESS %4.2e\n',cv.then.press);
        fprintf('+++ Custom error %4.2e\n',cv.then.errp);
        fprintf('+++ SCVR (Min) %4.2e\n',cv.then.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.then.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.then.scvr_mean);
        fprintf('+++ Adequation %4.2e\n',cv.then.adequ);
    end
    mesuTime(tMesuDebugA,tInitDebugA);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Classical CV method (remove simultaneously response and gradient
%%% at each sample point)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (modStudy||modFinal)&&(modDebug||metaData.cv.disp)
    
    [tMesuDebugB,tInitDebugB]=mesuTime;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %store response of the surrogate model at remove sample point
    cvZ=zeros(ns,1);
    cvVar=zeros(ns,1);
    cvGZ=zeros(ns,np);
    yy=data.build.y;
    KK=dataBloc.build.KK;    
    fctKern=dataBloc.build.kern;
    para=dataBloc.build.para;
    sampling=data.used.sampling;
    grad=data.used.grad;
    resp=data.used.resp;
    %along the sample points
    parfor (itS=1:ns,numWorkers)
        %load data
        dataCV=data;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if availGrad
            pos=[itS ns+(itS-1)*np+(1:np)];
        else
            pos=itS;
        end
        
        %remove data
        cvY=yy;
        cvKK=KK;
        cvY(pos,:)=[];
        cvKK(:,pos)=[];
        cvKK(pos,:)=[];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compute coefficients
        modWarning(dispWarning)
        cvW=cvKK\cvY;
        modWarning(~dispWarning)
        cvSampling=sampling;
        cvSampling(itS,:)=[];
        cvResp=resp;
        if metaData.miss.resp.on||metaData.miss.grad.on
            cvResp(itS)=[];
            if availGrad
                cvGrad=grad;
                cvGrad(itS,:)=[];
            else
                cvGrad=[];
            end
            retMiss=CheckInputData(cvSampling,cvResp,cvGrad);
            dataCV.miss=retMiss;
        else
            dataCV.miss.resp.on=false;
            dataCV.miss.grad.on=false;
        end
        
        dataCV.build.kern=fctKern;
        dataCV.build.para=para;
        dataCV.build.w=cvW;
        dataCV.build.KK=cvKK;
        dataCV.used.ns=ns-1; %remove one sample point
        dataCV.used.sampling=cvSampling;
        dataCV.infill.on=false;
        %evaluate response, gradient and variance at the remove sample point
        [Z,GZ,variance]=RBFEval(sampling(itS,:),dataCV);
        cvZ(itS)=Z;
        cvGZ(itS,:)=GZ;
        cvVar(itS)=variance;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Compute errors
    [cv.and]=LOOCalcError(resp,cvZ,cvVar,grad,cvGZ,ns,np,normLOO);
    %display informations
    if modDebug||modFinal
        fprintf('\n=== CV-LOO with remove responses AND the gradients\n');
        fprintf('+++ Used norm for calculate CV-LOO: %s\n',normLOO);
        if availGrad
            fprintf('+++ Error on responses %4.2e\n',cv.and.eloor);
            fprintf('+++ Error on gradients %4.2e\n',cv.and.eloog);
        end
        fprintf('+++ Total error %4.2e\n',cv.and.eloot);
        fprintf('+++ Mean bias %4.2e\n',cv.and.bm);
        fprintf('+++ PRESS %4.2e\n',cv.and.press);
        fprintf('+++ Custom error %4.2e\n',cv.and.errp);
        fprintf('+++ SCVR (Min) %4.2e\n',cv.and.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.and.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.and.scvr_mean);
        fprintf('+++ Adequation %4.2e\n',cv.and.adequ);
    end
    mesuTime(tMesuDebugB,tInitDebugB);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Compute variance of prediction at sample points + check calculation on responses and gradients (for CV)
%%%CAUTION: not functioning for missing data
if (modStudy||modFinal)&&(metaData.cv.disp||modDebug)
    %
    [tMesuDebugC,tInitDebugC]=mesuTime;
    %
    cvVarR=zeros(ns,1);
    cvZR=zeros(ns,1);
    cvGZ=zeros(ns,np);
    KK=dataBloc.build.KK;
    yy=data.build.y;
    grad=data.used.grad;
    resp=data.used.resp;
    for itS=1:ns
        %remove only responses
        pos=itS;
        %extract vector and computation of the variance
        PP=KK(itS,:);
        retKK=KK;
        retY=yy;
        retKK(pos,:)=[];
        retKK(:,pos)=[];
        retY(pos)=[];
        PP(pos)=[];
        modWarning(dispWarning)
        cvVarR(itS)=1-PP*(retKK\PP');
        %compute response
        cvZR(itS)=PP*(retKK\retY);
        modWarning(~dispWarning)
        %remove gradients
        if availGrad
            for posGr=1:np
                %load data
                pos=ns+(itS-1)*np+posGr;
                %extract vecteur
                dPP=KK(pos,:);
                %remove data
                retY=yy;
                retKK=KK;
                retY(pos,:)=[];
                retKK(:,pos)=[];
                retKK(pos,:)=[];
                dPP(pos)=[];
                %compute gradients
                GZ=dPP*(retKK\retY);
                cvGZ(itS,posGr)=GZ;
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Compute errors
    [cv.then]=LOOCalcError(resp,cvZR,cvVarR,grad,cvGZ,ns,np,normLOO);
    %display information
    if modDebug||modFinal
        fprintf('\n=== CV-LOO with remove responses THEN the gradients\n');
        fprintf('+++ Used norm for calculate CV-LOO: %s\n',normLOO);
        if availGrad
            fprintf('+++ Error on responses %4.2e\n',cv.then.eloor);
            fprintf('+++ Error on gradients %4.2e\n',cv.then.eloog);
        end
        fprintf('+++ Total error %4.2e\n',cv.then.eloot);
        fprintf('+++ Mean bias %4.2e\n',cv.then.bm);
        fprintf('+++ PRESS %4.2e\n',cv.then.press);
        fprintf('+++ Custom error %4.2e\n',cv.then.errp);
        fprintf('+++ SCVR (Min) %4.2e\n',cv.then.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.then.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.then.scvr_mean);
        fprintf('+++ Adequation %4.2e\n',cv.then.adequ);
    end
    mesuTime(tMesuDebugC,tInitDebugC);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Compute variance of prediction at the sample points (for CV)
%%%CAUTION: not functioning for missing data
if modFinal
    %
    [tMesuDebugD,tInitDebugD]=mesuTime;
    %
    cvVarR=zeros(ns,1);
    KK=dataBloc.build.KK;
    parfor (itS=1:ns,numWorkers)
        %remove only responses
        pos=itS;
        %extract vector and compute variance
        PP=KK(itS,:);
        retKK=KK;
        retKK(pos,:)=[];
        retKK(:,pos)=[];
        PP(pos)=[];
        modWarning(dispWarning)
        cvVarR(itS)=1-PP*(retKK\PP');
        modWarning(~dispWarning)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Compute errors
    [cv.final]=LOOCalcError(zeros(size(esR)),-esR,cvVarR,[],[],ns,np,normLOO);
    cv.then.scvr_min=cv.final.scvr_min;
    cv.then.scvr_max=cv.final.scvr_max;
    cv.then.scvr_mean=cv.final.scvr_mean;
    %display information
    if modDebug||modFinal
        fprintf('\n=== CV-LOO SCVR\n');
        fprintf('+++ SCVR (Min) %4.2e\n',cv.final.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.final.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.final.scvr_mean);
    end
    mesuTime(tMesuDebugC,tInitDebugC);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Show QQ-plot
if metaData.cv.disp&&modFinal
    opt.newfig=false;
    figure
    subplot(1,3,1);
    opt.title='Normalized data (CV R)';
    QQplot(data.used.resp,cvZR,opt)
    subplot(1,3,2);
    opt.title='Normalized data (CV F)';
    QQplot(data.used.resp,cvZ,opt)
    subplot(1,3,3);
    opt.title='SCVR (Normalized)';
    opt.xlabel='Predicted' ;
    opt.ylabel='SCVR';
    SCVRplot(cvZR,cv.final.scvr,opt)
    
%     % original data
%     subplot(2,3,4);
%     opt.title='Original data (CV R)';
%     QQplot(data.used.resp,cvZR,opt)
%     subplot(2,3,5);
%     opt.title='Original data (CV F)';
%     QQplot(data.used.resp,cvZ,opt)
%     subplot(2,3,6);
%     opt.title='SCVR (Normalized)';
%     opt.xlabel='Predicted' ;
%     opt.ylabel='SCVR';
%     SCVRplot(cvZR,cv.final.scvr,opt)
end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if modFinal;mesuTime(tMesu,tInit);end
end

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