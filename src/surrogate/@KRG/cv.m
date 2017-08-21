%% Compute Cross-Validation
function [crit,cv]=cv(obj,paraValIn,type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%various situations
modFinal=true;modDebug=obj.debugCV;
if nargin==3
    switch type
        case 'final'    %final mode (compute variances)
            modFinal=true;
        otherwise
            modFinal=false;
    end
end
if modFinal;countTime=mesuTime;end
%%
if nargin==1;paraValIn=obj.paraVal;end
%compute matrices
obj.compute(paraValIn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load variables
np=obj.nP;
ns=obj.nS;
availGrad=obj.flagG;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adaptation of the Rippa's method (Rippa 1999/Fasshauer 2007) form M. Bompard (Bompard 2011)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%coefficient of (co)Kriging
coefKRG=obj.gamma;
%partial extraction of the diagonal of the inverse of the kernel matrix
switch obj.factK
    case 'QR'
        fcC=obj.matrices.fcK*obj.matrices.QtK;
        diagMK=diag(obj.matrices.RK\obj.matrices.QtK)-...
            diag(fcC'*(obj.matrices.fcCfct\fcC));
    case 'LU'
        fcC=obj.matrices.fcU/obj.matrices.LK;
        diagMK=diag(obj.matrices.UK\inv(obj.matrices.LK))-...
            diag(fcC'*(obj.matrices.fcCfct\fcC));
    case 'LL'
        fcC=obj.matrices.fcL/obj.matrices.LK;
        diagMK=diag(obj.matrices.LK\inv(obj.matrices.LK))-...
            diag(fcC'*(obj.matrices.fcCfct\fcC));
    otherwise
        diagMK=diag(inv(obj.K))-...
            diag(obj.matrices.fcC'*(obj.matrices.fcCfct\obj.matrices.fcC));
end
%vectors of the distances on removed sample points (reponses and gradients)
% formula from Rippa 1999/Dubrule 1983/Zhang 2010/Bachoc 2011
esI=coefKRG./diagMK;
esR=esI(1:ns);
if availGrad;esG=esI(ns+1:end);end
%responses at the removed sample points
cv.cvZR=esR-obj.resp; %%check
cv.cvZ=esR-obj.resp; %%check
%vectors of the variance on removed sample points
evI=obj.sig2./diagMK;
evR=evI(1:ns);
if obj.flagG;evG=evI(ns+1:end);end

%computation of the LOO criteria (various norms)
switch obj.normLOO
    case 'L1'
        cv.then.press=esI'*esI;
        cv.then.eloot=1/numel(esI)*sum(abs(esI));
        cv.press=cv.then.press;
        cv.eloot=cv.then.eloot;
        if obj.flagG
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
        if obj.flagG
            cv.then.press=esR'*esR;
            cv.then.eloor=1/numel(esR)*(cv.then.press);
            cv.then.eloog=1/(numel(esR)*np)*(esG'*esG);
            cv.press=cv.then.press;
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
        end
    case 'Linf'
        cv.then.press=esI'*esI;
        cv.then.eloot=1/numel(esI)*max(esI(:));
        cv.press=cv.then.press;
        cv.eloot=cv.then.eloot;
        if obj.flagG
            cv.then.press=esR'*esR;
            cv.then.eloor=1/numel(esR)*max(esR(:));
            cv.then.eloog=1/(numel(esR)*np)*max(esG(:));
            cv.press=cv.then.press;
            cv.eloor=cv.then.eloor;
            cv.eloog=cv.then.eloog;
        end
end
%SCVR Keane 2005/Jones 1998
cv.scvr=(esI.^2)./evI;
cv.scvr_min=min(cv.scvr(:));
cv.scvr_max=max(cv.scvr(:));
cv.scvr_mean=mean(cv.scvr(:));
cv.scvrR=(esR.^2)./evR;
cv.scvrR_min=min(cv.scvrR(:));
cv.scvrR_max=max(cv.scvrR(:));
cv.scvrR_mean=mean(cv.scvrR(:));
if obj.flagG
    cv.scvrG=(esG.^2)./evG;
    cv.scvrG_min=min(cv.scvrG(:));
    cv.scvrG_max=max(cv.scvrG(:));
    cv.scvrG_mean=mean(cv.scvrG(:));
end
%scores from Bachoc 2011-2013/Zhang 2010
cv.mse=cv.eloot;                    %minimize
cv.wmse=1/numel(esI)*sum(cv.scvr);  %find close to 1
cv.lpp=-sum(log(evI)+cv.scvr);      %maximize
%%criterion of adequation (CAUTION of the norm!!!>> squared difference)
diffA=(esI.^2)./evI;
cv.adequ=1/numel(esI)*sum(diffA);
diffA=(esR.^2)./evR;
cv.adequR=1/numel(esR)*sum(diffA);
if obj.flagG
    diffA=(esG.^2)./evG;
    cv.adequG=1/numel(esG)*sum(diffA);
end
%mean of bias
cv.bm=1/numel(esI)*sum(esI);
cv.bmR=1/numel(esR)*sum(esR);
if obj.flagG
    cv.bmG=1/numel(esG)*sum(esG);
end
%display information
if modDebug||modFinal
    Gfprintf('\n=== CV-LOO using Rippa''s methods (1999, extension by Bompard 2011)\n');
    %prepare cells for display
    txtC{1}='+++ Used norm for calculate CV-LOO';
    varC{1}=obj.normLOO;
    if obj.flagG
        txtC{end+1}='+++ Error on responses';
        varC{end+1}=cv.then.eloor;
        txtC{end+1}='+++ Error on gradients';
        varC{end+1}=cv.then.eloog;
    end
    txtC{end+1}='+++ Total error (MSE)';
    varC{end+1}=cv.then.eloot;
    txtC{end+1}='+++ PRESS';
    varC{end+1}=cv.then.press;
    if obj.flagG
        txtC{end+1}='+++ mean SCVR (Resp)';
        varC{end+1}=cv.scvrR_mean;
        txtC{end+1}='+++ max SCVR (Resp)';
        varC{end+1}=cv.scvrR_max;
        txtC{end+1}='+++ min SCVR (Resp)';
        varC{end+1}=cv.scvrR_min;
        txtC{end+1}='+++ mean SCVR (Grad)';
        varC{end+1}=cv.scvrG_mean;
        txtC{end+1}='+++ max SCVR (Grad)';
        varC{end+1}=cv.scvrG_max;
        txtC{end+1}='+++ min SCVR (Grad)';
        varC{end+1}=cv.scvrG_min;
    end
    txtC{end+1}='+++ mean SCVR (Total)';
    varC{end+1}=cv.scvr_mean;
    txtC{end+1}='+++ max SCVR (Total)';
    varC{end+1}=cv.scvr_max;
    txtC{end+1}='+++ min SCVR (Total)';
    varC{end+1}=cv.scvr_min;
    if obj.flagG
        txtC{end+1}='+++ Adequation (Resp)';
        varC{end+1}=cv.adequR;
        txtC{end+1}='+++ Adequation (Grad)';
        varC{end+1}=cv.adequG;
    end
    txtC{end+1}='+++ Adequation (Total)';
    varC{end+1}=cv.adequ;
    if obj.flagG
        txtC{end+1}='+++ Mean of bias (Resp)';
        varC{end+1}=cv.bmR;
        txtC{end+1}='+++ Mean of bias (Grad)';
        varC{end+1}=cv.bmG;
    end
    txtC{end+1}='+++ Mean of bias (Total)';
    varC{end+1}=cv.bm;
    txtC{end+1}='+++ WMSE';
    varC{end+1}=cv.wmse;
    txtC{end+1}='+++ LPP';
    varC{end+1}=cv.lpp;
    dispTableTwoColumns(txtC,varC,'-');
end
%%
obj.cvResults=cv;
%
switch obj.typeLOO
    case 'mse'
        crit=cv.mse;
    case 'wmse'
        crit=abs(cv.wmse-1);
    case 'lpp'
        crit=-cv.lpp;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if modFinal;countTime.stop;end
end
