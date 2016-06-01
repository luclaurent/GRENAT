%% Function for computing various Cross-Validation criteria for KRG/GKRG
%L. LAURENT -- 14/12/2011 -- luc.laurent@lecnam.net
%new version: 19/10/2012

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

function cv=KRGCV(dataBloc,metaData,type)
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
statusWarning=modWarning([],[]);

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
if nargin==3
    switch type
        case 'debug'  %debug mode (display criteria)
            fprintf('+++ CV KRG in DEBUG mode\n');
            modDebug=true;
        case 'study'  %study mode (use both methods for calculating criteria)
            modStudy=true;
        case 'estim'  %estimation mode
            modStudy=false;
        case 'final'    %final mode (compute variances)
            modFinal=true;
    end
else
    modFinal=true;
end
if modFinal;[tMesu,tInit]=mesuTime;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load variables
np=dataBloc.used.np;
ns=dataBloc.used.ns;
availGrad=dataBloc.used.availGrad;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adaptation of the Rippa's method (Rippa 1999/Fasshauer 2007) form M. Bompard (Bompard 2011)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%coefficient of (co)Kriging
coefKRG=dataBloc.build.gamma;
%partial extraction of the diagonal of the inverse of the kernel matrix
switch dataBloc.build.factKK
    case 'QR'
        fcC=dataBloc.build.fcK*dataBloc.build.QtK;
        diagMK=diag(dataBloc.build.RK\dataBloc.build.QtK)-...
            diag(fcC'*(dataBloc.build.fcCfct\fcC));
    case 'LU'
        fcC=dataBloc.build.fcU/dataBloc.build.LK;
        diagMK=diag(dataBloc.build.UK\inv(dataBloc.build.LK))-...
            diag(fcC'*(dataBloc.build.fcCfct\fcC));
    case 'LL'
        fcC=dataBloc.build.fcL/dataBloc.build.LK;
        diagMK=diag(dataBloc.build.LK\inv(dataBloc.build.LK))-...
            diag(fcC'*(dataBloc.build.fcCfct\fcC));
    otherwise
        diagMK=diag(inv(dataBloc.build.KK))-...
            diag(dataBloc.build.fcC'*(dataBloc.build.fcCfct\dataBloc.build.fcC));
        
end
%vectors of the distances on removed sample points (reponses et gradients)
esI=coefKRG./diagMK;
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
    yy=dataBloc.build.y;
    fct=dataBloc.build.fct;
    KK=dataBloc.build.KK;
    sampling=dataBloc.used.sampling;
    tiragesn=dataBloc.in.tiragesn;
    grad=dataBloc.in.grad;
    resp=dataBloc.in.eval;
    dimC=dataBloc.build.sizeFc;
    %along the sample points
    parfor (itS=1:ns,numWorkers)
        %Load data
        dataCV=dataBloc;
        %remove data
        cvY=yy([1:(itS-1) (itS+1):end]');
        cvKK=KK([1:(itS-1) (itS+1):end],[1:(itS-1) (itS+1):end]);
        cvFct=fct([1:(itS-1) (itS+1):end],:);
        
        cvFcc=cvFct'/cvKK;
        cvFcCfct=cvFcc*cvFct;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compute coefficients
        modWarning(dispWarning);
        dataCV.build.factKK='None';
        cvMKrg=[cvKK cvFct;cvFct' zeros(dimC)];
        coefKRG=cvMKrg\[cvY;zeros(dimC,1)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extract beta and gamma coefficients
        dataCV.build.beta=coefKRG((end-dimC+1):end);
        dataCV.build.gamma=coefKRG(1:(end-dimC));
        dataCV.build.rcc=cvKK;
        
        %compute variance of the gaussian process
        sig2=1/size(cvKK,1)*((cvY-cvFct*dataCV.build.beta)'*dataCV.build.gamma);
        modWarning(~dispWarning);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if metaData.normOn
            dataCV.build.sig2=sig2*metaData.norm.resp.std^2;
        else
            dataCV.build.sig2=sig2;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %store variables
        dataCV.used.sampling=sampling;
        dataCV.used.ns=ns;  %remove one sample point
        dataCV.build.fct=cvFct;
        dataCV.build.fc=cvFct';
        dataCV.build.fcCfct=cvFcCfct;
        dataCV.infill.on=false;
        %remove associate response
        dataCV.miss.grad.on=false;
        dataCV.miss.resp.on=true;
        dataCV.miss.resp.ixMiss=itS;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %evaluate response and variances on removed sample points
        [Z,~,variance]=KRGEval(sampling(itS,:),dataCV);
        cvZ(itS)=Z;
        cvVar(itS)=variance;
        %remove gradients
        if availGrad
            for posGr=1:np
                %load data
                dataCV=dataBloc;
                pos=ns+(itS-1)*np+posGr;
                %remove data
                cvY=yy([1:(pos-1) (pos+1):end]');
                cvKK=KK([1:(pos-1) (pos+1):end],[1:(pos-1) (pos+1):end]);
                cvFct=fct([1:(pos-1) (pos+1):end],:);
                cvFcc=cvFct'/cvKK;
                cvFcCfct=cvFcc*cvFct;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %ccompute coefficients
                modWarning(dispWarning);
                dataCV.build.factKK='None';
                cvMKrg=[cvKK cvFct;cvFct' zeros(dimC)];
                coefKRG=cvMKrg\[cvY;zeros(dimC,1)];
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %extraction beta and gamma coefficients
                dataCV.build.beta=coefKRG((end-dimC+1):end);
                dataCV.build.gamma=coefKRG(1:(end-dimC));
                dataCV.build.rcc=cvKK;
                
                %compute variance of the gaussian process
                sig2=1/size(cvKK,1)*((cvY-cvFct*dataCV.build.beta)'*dataCV.build.gamma);
                modWarning(~dispWarning);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if metaData.normOn
                    sig2=sig2*metaData.norm.resp.std^2;
                end
                dataCV.build.sig2=sig2;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %store data
                dataCV.used.sampling=sampling;
                dataCV.used.ns=ns;  %remove one sample point
                dataCV.build.fct=cvFct;
                dataCV.build.fc=cvFct';
                dataCV.build.fcCfct=cvFcCfct;
                dataCV.infill.on=false;
                %remove the associated gradient
                dataCV.miss.grad.on=true;
                dataCV.miss.resp.on=false;
                dataCV.miss.grad.ixtMissLine=pos-ns;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %evaluate gradients on removed sample points
                [~,GZ,~]=KRGEval(sampling(itS,:),dataCV);
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
if (modStudy||modDebug)||(modFinal&&metaData.cv.disp)
    [tMesuDebugB,tInitDebugB]=mesuTime;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %store response of the surrogate model at remove sample point
    cvZ=zeros(ns,1);
    cvVar=zeros(ns,1);
    cvGZ=zeros(ns,np);
    yy=dataBloc.build.y;
    fct=dataBloc.build.fct;
    KK=dataBloc.build.KK;
    sampling=dataBloc.used.sampling;
    grad=dataBloc.used.grad;
    resp=dataBloc.used.resp;
    dimC=dataBloc.build.sizeFc;
    
    %along the sample points
    parfor (itS=1:ns,numWorkers)
        %load data
        dataCV=dataBloc;
        %remove data
        if availGrad
            pos=[itS ns+(itS-1)*np+(1:np)];
            IXi=1:((np+1)*ns);
        else
            pos=itS;
            IXi=1:(ns);
        end
        %complement to the intial indexes
        IXc=IXi(end)+(1:dimC);
        %indexes of the removed data
        IXe=setxor(IXi,pos);
        
        modWarning(dispWarning);
        cvY=yy(IXe');
        cvKK=KK(IXe,IXe);
        cvFct=fct(IXe,:);
        cvFcc=cvFct'/cvKK;
        cvFcCfct=cvFcc*cvFct;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compute coefficients
        dataCV.build.factKK='None';
        cvMKrg=[cvKK cvFct;cvFct' zeros(dimC)];
        coefKRG=cvMKrg\[cvY;zeros(dimC,1)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extraction of the beta and gamma coefficients
        dataCV.build.beta=coefKRG((end-dimC+1):end);
        dataCV.build.gamma=coefKRG(1:(end-dimC));
        dataCV.build.KK=cvKK;
        
        
        %compute variance of the gaussian process
        sig2=1/size(cvKK,1)*((cvY-cvFct*dataCV.build.beta)'*dataCV.build.gamma);
        modWarning(~dispWarning);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if metaData.normOn
            sig2=sig2*metaData.norm.resp.std^2;
        end
        dataCV.build.sig2=sig2;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %store variables
        dataCV.used.sampling=sampling([1:(itS-1) (itS+1):end],:);
        dataCV.used.ns=ns-1;  %remove one sample point
        dataCV.build.fct=cvFct;
        dataCV.build.fc=cvFct';
        dataCV.build.fcCfct=cvFcCfct;
        dataCV.infill.on=false;
        %remove of the associated response
        dataCV.miss.grad.on=false;
        dataCV.miss.resp.on=false;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %evaluate response, gradient and variance at the remove sample point
        [Z,GZ,variance]=KRGEval(sampling(itS,:),dataCV);
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
if modStudy||metaData.cv.disp
    %
    [tMesuDebugC,tInitDebugC]=mesuTime;
    %%
    cvVarR=zeros(ns,1);
    cvZR=zeros(ns,1);
    cvGZ=zeros(ns,np);
    yy=dataBloc.build.y;
    fct=dataBloc.build.fct;
    KK=dataBloc.build.KK;
    grad=dataBloc.used.grad;
    resp=dataBloc.used.resp;
    dimC=dataBloc.build.sizeFc;
    for itS=1:ns
        %load data and remove responses
        PP=[KK(itS,:) fct(itS,:)];
        PP(itS)=[];
        cvY=yy([1:(itS-1) (itS+1):end]');
        cvKK=KK([1:(itS-1) (itS+1):end],[1:(itS-1) (itS+1):end]);
        cvFct=fct([1:(itS-1) (itS+1):end],:);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compute coefficients
        modWarning(dispWarning);
        cvMKrg=[cvKK cvFct;cvFct' zeros(dimC)];
        coefKRG=cvMKrg\[cvY;zeros(dimC,1)];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extraction of the beta and gamma coefficients
        beta=coefKRG((end-dimC+1):end);
        gamma=coefKRG(1:(end-dimC));
        %compute
        sig2=1/size(cvKK,1)*((cvY-cvFct*beta)'*gamma);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if metaData.normOn
            sig2=sig2*metaData.norm.resp.std^2;
        end
        dataCV.build.sig2=sig2;
        %compute variance at the removed point
        cvVarR(itS)=sig2*(1-PP*(cvMKrg\PP'));
        
        %compute response
        cvZR(itS)=PP*coefKRG;
        modWarning(~dispWarning);
        %remove gradients
        if availGrad
            for posGr=1:np
                pos=ns+(itS-1)*np+posGr;
                %remove data
                cvKK=KK([1:(pos-1) (pos+1):end],[1:(pos-1) (pos+1):end]);
                cvFct=fct([1:(pos-1) (pos+1):end],:);
                cvY=yy([1:(pos-1) (pos+1):end]');
                cvMKrg=[cvKK cvFct;cvFct' zeros(dimC)];
                %extraction of the vector
                dPP=[KK(pos,:) fct(pos,:)];
                dPP(pos)=[];
                %compute gradients
                GZ=dPP*(cvMKrg\[cvY;zeros(dimC,1)]);
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
    yy=dataBloc.build.y;
    fct=dataBloc.build.fct;
    KK=dataBloc.build.KK;
    dimC=dataBloc.build.sizeFc;
    %
    parfor (itS=1:ns,numWorkers)
        
        %extraction data
        PP=[KK(itS,:) fct(itS,:)];
        PP(itS)=[];
        cvKK=KK([1:(itS-1) (itS+1):end],[1:(itS-1) (itS+1):end]);
        cvFct=fct([1:(itS-1) (itS+1):end],:);
        cvY=yy([1:(itS-1) (itS+1):end]');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compute coefficients
        modWarning(dispWarning);
        cvMKrg=[cvKK cvFct;cvFct' zeros(dimC)];
        coefKRG=cvMKrg\[cvY;zeros(dimC,1)];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %extraction of the beta coefficient
        beta=coefKRG((end-dimC+1):end);
        
        %compute variance of the gaussian process
        sig2=1/size(cvKK,1)*((cvY-cvFct*beta)'/cvKK)*(cvY-cvFct*beta);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if metaData.normOn
            sig2=sig2*metaData.norm.resp.std^2;
        end
        %comute variance at the removed sample point
        cvVarR(itS)=sig2*(1-PP*(cvMKrg\PP'));
        modWarning(~dispWarning);
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
    mesuTime(tMesuDebugD,tInitDebugD);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Show QQ-plot
if metaData.cv.disp&&modFinal
    opt.newfig=false;
    figure
    subplot(1,3,1);
    opt.title='Normalized data (CV R)';
    QQplot(dataBloc.used.resp,cvZR,opt)
    subplot(1,3,2);
    opt.title='Normalized data (CV F)';
    QQplot(dataBloc.used.resp,cvZ,opt)
    subplot(1,3,3);
    opt.title='SCVR (Normalized)';
    opt.xlabel='Predicted' ;
    opt.ylabel='SCVR';
    SCVRplot(cvZR,cv.final.scvr,opt)
    
    %     % original data
    %     subplot(2,3,4);
    %     opt.title='Original data (CV R)';
    %     QQplot(dataBloc.used.resp,cvZR,opt)
    %     subplot(2,3,5);
    %     opt.title='Original data (CV F)';
    %     QQplot(dataBloc.used.resp,cvZ,opt)
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

