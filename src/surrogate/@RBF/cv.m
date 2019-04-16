%% Method of RBF class
% L. LAURENT -- 15/08/2017 -- luc.laurent@lecnam.net

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


%% Compute Leave-One-Out Cross-Validation
% INPUTS:
% - paraValIn: values of the hyperparameters
% - type: type of calculation (optional, final for final computation)
% OUTPUTS:
% - crit: value of the criteria used for estimation of the hyperparameters
% - cv: structure containing all CV criteria

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
%coefficient of (G)RBF
coefRBF=obj.W;

%vectors of the distances on removed sample points (reponses and gradients)
% formula from Rippa 1999/Dubrule 1983/Zhang 2010/Bachoc 2011
diagMK=diag(obj.matrices.iK);
esI=coefRBF./diagMK;
esR=esI(1:ns);
if availGrad;esG=esI(ns+1:end);end
%responses at the removed sample points
cv.cvZR=esR-obj.resp;
cv.cvZ=esR-obj.resp;
%vectors of the variance on removed sample points
evI=1./diagMK;
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
