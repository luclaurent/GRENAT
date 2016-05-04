%% Function for computing various Cross-Validation criteria for RBF/GRBF
%L. LAURENT -- 14/12/2011 -- luc.laurent@lecnam.net
%new version: 31/05/2012

function [cv]=RBFCV(dataBloc,data,metaData,type)
[tMesu,tInit]=mesuTime;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement des grandeurs
np=data.in.np;
ns=data.in.ns;
availGrad=data.in.availGrad;

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
    fprintf('=== CV-LOO using Rippa''s methods (1999, extension by Bompard 2011)\n');
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
    [tMesuDebug,tInitDebug]=mesuTime;
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
    sampling=data.in.sampling;
    grad=data.in.grad;
    resp=data.in.resp;
    %along the sample points
    parfor (itS=1:ns,numWorkers)
        %remove responeses
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
        if ~dispWarning; warning off all;end
        cvW=cvKK\cvY;
        if ~dispWarning; warning on all;end
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
        dataCV.in.ns=ns;
        dataCV.in.sampling=cvSampling;
        dataCV.infill.on=false;
        %evaluate response, gradients and variances on removed sample points
        [Z,~,variance]=RBFEval(sampling(itS,:),dataCV);
        cvZ(itS)=Z;
        cvVar(itS)=variance;
        
        %remove gradients
        if availGrad
            for pos_gr=1:np
                %load data
                dataCV=data;
                
                %remove data
                cvY=yy;
                cvKK=KK;
                pos=ns+(itS-1)*np+pos_gr;
                cvY(pos,:)=[];
                cvKK(:,pos)=[];
                cvKK(pos,:)=[];
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %ccompute coefficients
                if ~dispWarning; warning off all;end
                cvW=cvKK\cvY;
                if ~dispWarning; warning on all;end
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
                %evaluate response, gradients and variances on removed sample points
                [~,GZ,~]=RBFEval(sampling(itS,:),dataCV);
                cvGZ(itS,pos_gr)=GZ(pos_gr);
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% compute errors
    [cv.then]=LOOCalcError(resp,cvZ,cvVar,grad,cvGZ,ns,np,normLOO);
    %display information
    if modDebug||modFinal
        fprintf('=== CV-LOO with remove responses THEN the gradients (debug)\n');
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
    mesuTime(tMesuDebug,tInitDebug);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Classical CV method (remove simultaneously response and gradient
%%% at each sample point)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if modStudy||modDebug||metaData.cv_aff
    [tMesuDebug,tInitDebug]=mesuTime;
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
    sampling=data.in.sampling;
    grad=data.in.grad;
    resp=data.in.resp;
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
        if ~dispWarning; warning off all;end
        cvW=cvKK\cvY;
        if ~dispWarning; warning on all;end
        cvSampling=sampling;
        cvSampling(itS,:)=[];
        cvResp=resp;
        if data.miss.resp.on||data.miss.grad.on
            cvResp(itS)=[];
            if availGrad
                cvGrad=grad;
                cvGrad(itS,:)=[];
            else
                cvGrad=[];
            end
            retMiss=CheckInputData(cvSampling,cvResp,cvGrad);
            dataCV.manq=retMiss;
        end
        
        dataCV.build.kern=fctKern;
        dataCV.build.para=para;
        dataCV.build.w=cvW;
        dataCV.build.KK=cvKK;
        dataCV.in.ns=ns-1; %remove one sample point
        dataCV.in.sampling=cvSampling;
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
        fprintf('=== CV-LOO with remove responses AND the gradients\n');
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
    mesuTime(tMesuDebug,tInitDebug);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Compute variance of prediction at sample points + check calculation on responses and gradients (for CV)
%%%CAUTION: not functioning for missing data
if metaData.cv.disp||modDebug
    %
    [tMesuDebug,tInitDebug]=mesuTime;
    %
    cvVarR=zeros(ns,1);
    cvZR=zeros(ns,1);
    cvGZ=zeros(ns,np);
    KK=dataBloc.build.KK;
    yy=data.build.y;
    grad=data.in.grad;
    resp=data.in.resp;
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
        if ~dispWarning; warning off all;end
        cvVarR(itS)=1-PP*(retKK\PP');
        %compute response
        cvZR(itS)=PP*(retKK\retY);
        if ~dispWarning; warning on all;end
        %remove gradients
        if availGrad
            for pos_gr=1:np
                %load data
                pos=ns+(itS-1)*np+pos_gr;
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
                cvGZ(itS,pos_gr)=GZ;
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Compute errors
    [cv.then]=LOOCalcError(resp,cvZR,cvVarR,grad,cvGZ,ns,np,normLOO);
    %display information
    if modDebug||modFinal
        fprintf('=== CV-LOO with remove responses THEN the gradients\n');
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
    mesuTime(tMesuDebug,tInitDebug);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Compute variance of prediction at the sample points (for CV)
%%%CAUTION: not functioning for missing data
if modFinal
    %
    [tMesuDebug,tInitDebug]=mesuTime;
    %
    cvVarR=zeros(ns,1);
    KK=dataBloc.build.KK;
    parfor (itS=1:ns,numWorkers)
        %retrait des reponses seules
        pos=itS;
        %extraction vecteur et calcul de la variance
        PP=KK(itS,:);
        retKK=KK;
        retKK(pos,:)=[];
        retKK(:,pos)=[];
        PP(pos)=[];
        if ~dispWarning; warning off all;end
        cvVarR(itS)=1-PP*(retKK\PP');
        if ~dispWarning; warning on all;end
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
        fprintf('=== CV-LOO SCVR\n');
        fprintf('+++ SCVR (Min) %4.2e\n',cv.final.scvr_min);
        fprintf('+++ SCVR (Max) %4.2e\n',cv.final.scvr_max);
        fprintf('+++ SCVR (Mean) %4.2e\n',cv.final.scvr_mean);
    end
    mesuTime(tMesuDebug,tInitDebug);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Show QQ-plot
if metaData.cv.disp&&modFinal
    opt.newfig=false;
    figure
    subplot(3,1,1);
    opt.title='Original data (CV R)';
    QQplot(data.in.resp,cvZR,opt)
    subplot(3,1,2);
    opt.title='Original data (CV F)';
    QQplot(data.in.resp,cvZ,opt)
    subplot(3,1,3);
    opt.title='SCVR';
    opt.xlabel='Predicted' ;
    opt.ylabel='SCVR';
    SCVRplot(cvZR,cv.final.scvr,opt)
end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if modFinal;mesuTime(tMesu,tInit);end
end