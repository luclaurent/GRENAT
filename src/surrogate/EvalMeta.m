%% Evaluation of the surrogate model
% L. LAURENT -- 04/12/2011 -- luc.laurent@lecnam.net
% modification: 12/12/2011

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

function [Z]=EvalMeta(evalSample,dataTrain,metaConf,Verb)

countTime=mesuTime;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%output variable
Z=struct;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%choose verbosity of the function
if nargin==3
    Verb=true;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%number of design parameters
np=dataTrain.used.np;
%number of initial sample poins
ns=dataTrain.used.ns;
%size of the required non-sample points
nv=size(evalSample);
nv(3)=size(evalSample,3);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%sorting non-sample points
if np>1
    % if the non-sample points corresponds to a grid
    if nv(3)~=1
        %number a required evaluations
        nbReqEval=prod(nv(1:2));
        reqResp=zeros(nbReqEval,nv(3));
        for ll=1:nv(3)
            tmp=evalSample(:,:,ll);
            reqResp(:,ll)=tmp(:);
        end
    else
        %if not the number a required evaluations is determined
        nbReqEval=nv(1);
        reqResp=evalSample;
    end
else
    nbReqEval=prod(nv(1:2)); %number a required evaluations
    reqResp=evalSample(:);
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%variables for storage
valResp=zeros(nbReqEval,1);
varResp=zeros(nbReqEval,1);
valGrad=zeros(nbReqEval,np);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
if nbReqEval>1&&Verb
    fprintf('#############################################\n');
    fprintf('  >>> EVALUATION of the surrogate model <<<\n');
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%parallel
numWorkers=0;
if ~isempty(whos('parallel','global'))
    global parallelData
    numWorkers=parallelData.num;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%% Evaluation of the surrogate model

%load used initial data (sampling, responses and gradients)
%U: used data (normalized if normlization is active)
%I: initial data (w/o normlization)
samplingU=dataTrain.used.sampling;
respU=dataTrain.used.resp;
gradU=dataTrain.used.grad;
samplingI=dataTrain.in.sampling;
respI=dataTrain.in.resp;
gradI=dataTrain.in.grad;

%check or not the interpolation quality of the surrogate model
if metaConf.checkInterp
    checkZN=zeros(ns,1);
    checkGZN=zeros(ns,np);
end
%depending of the type of surrogate model
switch metaConf.type
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    case 'SWF'
        %% Evaluation of the 'Shepard Weighting Functions' surrogate model
        for jj=1:nbReqEval
            [valResp(jj),G]=SWFEval(reqResp(jj,:),dataTrain);
            valGrad(jj,:)=G;
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case {'GRBF','RBF','InRBF'}
        %% Evaluation of the (Gradient-Enhanced) Radial Basis Functions (RBF/GRBF)
        parfor (jj=1:nbReqEval,numWorkers)
            [valResp(jj),G,varResp(jj)]=RBFEval(reqResp(jj,:),dataTrain);
            valGrad(jj,:)=G;
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case {'KRG','GKRG','InKRG'}
        %specific storage
        stoZ=valResp;trZ=valResp;
        trGZ=valGrad;stoGZ=valGrad;
        %% Evaluation of the (Gradient-Enhanced) Kriging/Cokriging (KRG/GKRG)
        %parfor (jj=1:nbReqEval,numWorkers)
        parfor (jj=1:nbReqEval,numWorkers)
            [valResp(jj),G,varResp(jj),detKRG]=KRGEval(reqResp(jj,:),dataTrain);
            valGrad(jj,:)=G;
            stoZ(jj)=detKRG.stoZ;
            trZ(jj)=detKRG.trZ;
            trGZ(jj,:)=detKRG.trGZ;
            stoGZ(jj,:)=detKRG.stoGZ;
        end
    case {'SVR','InSVR','GSVR'}
        %% Evaluation of the (Gradient-Enhanced) SVR (SVR/GSVR)
        %parfor (jj=1:nbReqEval,numWorkers)
        parfor (jj=1:nbReqEval,numWorkers)
            [valResp(jj),G,varResp(jj)]=SVREval(reqResp(jj,:),dataTrain);
            valGrad(jj,:)=G;
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        
    case 'DACE'
        %% Evaluation du metamodele de Krigeage (DACE)
        for jj=1:nbReqEval
            [valResp(jj),G,varResp(jj)]=predictor(reqResp(jj,:),dataTrain.model);
            valGrad(jj,:)=G;
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case 'PRG'
        for degre=dataTrain.deg
            %% Evaluation of the polynomial regression surrogate model
            parfor (jj=1:nbReqEval,numWorkers)
                valResp(jj)=LSEval(dataTrain.prg.coef,reqResp(jj,1),evalSample(jj,2),dataTrain);
                %calculation of the gradients
                [GRG1,GRG2]=LSEvalD(dataTrain.prg.coef,reqResp(jj,1),evalSample(jj,2),dataTrain);
                valGrad(jj,:)=[GRG1,GRG2];
            end
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case 'ILIN'
        %% interpolation using linear shape functions
        parfor (jj=1:nbReqEval,numWorkers)
            [valResp(jj),G]=LInterpEval(reqResp(jj,:),dataTrain);
            valGrad(jj,:)=G;
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case 'ILAG'
        %% interpolation using linear shape functions based on Lagrange polynoms
        parfor (jj=1:nbReqEval,numWorkers)
            [valResp(jj),G]=LagInterpEval(reqResp(jj,:),dataTrain);
            valGrad(jj,:)=G;
            
        end
    otherwise
        error(['Wrong type of surrogate model (see. on ',mfilename,')']);
        
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%reordering gradients
if np>1
    if exist('stoGZ','var')&&exist('trGZ','var')
        stoGZFinal=zeros(nv);
        trGZFinal=zeros(nv);
    end
    GZ=zeros(nv);
    if nv(3)>1
        for ll=1:nv(3)
            tmp=valGrad(:,ll);
            GZ(:,:,ll)=reshape(tmp,nv(1),nv(2));
        end
        if exist('stoGZ','var')&&exist('trGZ','var')
            for ll=1:nv(3)
                tmp=stoGZ(:,ll);
                tmp1=trGZ(:,ll);
                stoGZFinal(:,:,ll)=reshape(tmp,nv(1),nv(2));
                trGZFinal(:,:,ll)=reshape(tmp1,nv(1),nv(2));
            end
        end
    else
        GZ=valGrad;
        if exist('stoGZ','var')&&exist('trGZ','var')
            stoGZFinal=stoGZ;
            trGZFinal=trGZ;
        end
    end
else
    GZ=valGradN;
    if exist('stoGZ','var')&&exist('trGZ','var')
        stoGZFinal=stoGZ;
        trGZFinal=trGZ;
    end
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Storage of evaluations


if np>1
    if nv(3)==1
        if exist('stoZFinal','var')&&exist('trZFinal','var')
            Z.stoZ=stoZFinal;
            Z.trZ=trZFinal;
        end
        Z.Z=valResp;
        if ~isempty(varResp);Z.var=varResp;end
        if exist('wei','var');if ~isempty(wei);Z.wei=wei;end, end
        if exist('ei','var');if ~isempty(ei);Z.ei=ei;end, end
        if exist('gei','var');if ~isempty(gei);Z.gei=gei;end, end
        if exist('lcb','var');if ~isempty(lcb);Z.lcb=lcb;end, end
        if exist('explorEI','var');if ~isempty(explorEI);Z.explorEI=explorEI;end, end
        if exist('exploitEI','var');if ~isempty(exploitEI);Z.exploitEI=exploitEI;end, end
    else
        if exist('stoZFinal','var')&&exist('trZFinal','var')
            Z.stoZ=reshape(stoZFinal,nv(1),nv(2));
            Z.trZ=reshape(trZFinal,nv(1),nv(2));
        end
        Z.Z=reshape(valResp,nv(1),nv(2));
        if ~isempty(varResp);Z.var=reshape(varResp,nv(1),nv(2));end
        if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,nv(1),nv(2),size(wei,3));end, end
        if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,nv(1),nv(2));end, end
        if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,nv(1),nv(2),size(gei,3));end, end
        if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,nv(1),nv(2));end, end
        if exist('explorEI','var');if ~isempty(explorEI);Z.explorEI=reshape(explorEI,nv(1),nv(2));end, end
        if exist('exploitEI','var');if ~isempty(exploitEI);Z.exploitEI=reshape(exploitEI,nv(1),nv(2));end, end
    end
else
    if exist('stoZ','var')&&exist('trZ','var')
        Z.stoZ=reshape(stoZ,nv(1),nv(2));
        Z.trZ=reshape(trZ,nv(1),nv(2));
    end
    Z.Z=reshape(valResp,nv(1),nv(2));
    if ~isempty(varResp);Z.var=reshape(varResp,nv(1),nv(2));end
    if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,nv(1),nv(2),size(wei,3));end, end
    if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,nv(1),nv(2));end, end
    if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,nv(1),nv(2),size(gei,3));end, end
    if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,nv(1),nv(2));end, end
    if exist('explorEI','var');if ~isempty(explorEI);Z.explorEI=reshape(explorEI,nv(1),nv(2));end, end
    if exist('exploitEI','var');if ~isempty(exploitEI);Z.exploitEI=reshape(exploitEI,nv(1),nv(2));end, end
end
Z.GZ=GZ;
if exist('stoGZFinal','var')==1&&exist('trGZFinal','var')==1
    Z.stoGZ=stoGZFinal;Z.trGZ=trGZFinal;
end

%end of evaluations
if nbReqEval>1&&Verb
    fprintf('++ Evaluation at %i points\n',nbReqEval);
    countTime.stop;
    fprintf('#########################################\n');
end

end





