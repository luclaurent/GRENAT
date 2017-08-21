%% Method of SVR class
% L. LAURENT -- 18/08/2017 -- luc.laurent@lecnam.net

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
% - none
% OUTPUTS:
% - cv: structure containing all CV criteria

function cv=cv(obj)
if ~obj.checkMiss
    obj.showInfo('cv');
    %
    countTime=mesuTime;
    %
    dataCV=obj.metaData;
    dataCV.estimOn=false;
    %store the values of the hyperparameters
    
    % Compute responses
    ZCV=zeros(size(obj.resp));
    varCV=zeros(size(obj.resp));
    GCV=zeros(size(obj.sampling));
    %
    for itS=1:obj.nS
        %remove data
        samplingCV=obj.sampling([1:(itS-1) (itS+1):end],:);
        respCV=obj.resp([1:(itS-1) (itS+1):end]);
        %
        gradCV=[];
        if ~isempty(obj.grad)
            gradCV=obj.grad([1:(itS-1) (itS+1):end],:);
        end
        %
        SVRCV=SVR(samplingCV,respCV,gradCV,obj.kernelFun,dataCV);
        %
        [ZCV(itS),GCV(itS,:),varCV(itS)]=SVRCV.eval(obj.sampling(itS,:));
    end
    % compute CV criteria
    cv=LOOCalcError(obj.resp,ZCV,varCV,obj.grad,GCV,obj.nS,obj.nP,obj.normLOO);
    %
    obj.showInfo('cvend');
    %
    %prepare cells for display
    txtC{1}='+++ Used norm for calculate CV-LOO';
    varC{1}=obj.normLOO;
    if obj.flagG
        txtC{end+1}='+++ Error on responses';
        varC{end+1}=cv.eloor;
        txtC{end+1}='+++ Error on gradients';
        varC{end+1}=cv.eloog;
    end
    txtC{end+1}='+++ Total error (MSE)';
    varC{end+1}=cv.eloot;
    txtC{end+1}='+++ PRESS';
    varC{end+1}=cv.press;
    txtC{end+1}='+++ mean SCVR (Total)';
    varC{end+1}=cv.scvr_mean;
    txtC{end+1}='+++ max SCVR (Total)';
    varC{end+1}=cv.scvr_max;
    txtC{end+1}='+++ min SCVR (Total)';
    varC{end+1}=cv.scvr_min;
    txtC{end+1}='+++ Adequation (Total)';
    varC{end+1}=cv.adequ;
    txtC{end+1}='+++ Mean of bias (Total)';
    varC{end+1}=cv.bm;
    dispTableTwoColumns(txtC,varC,'-');
    %
    countTime.stop;
else
    Gfprintf(' +++ Missing data: unable to compute the CV criteria\n');
end
end