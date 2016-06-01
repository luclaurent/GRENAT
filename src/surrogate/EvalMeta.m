%% Evaluation of the surrogate model
% L. LAURENT -- 04/12/2011 -- luc.laurent@lecnam.net
% modification: 12/12/2011

function [Z]=EvalMeta(evalSample,availData,Verb)

[tMesu,tInit]=mesuTime;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%output variable
Z=struct;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%choose verbosity of the function
if nargin==2
    Verb=true;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%number of design parameters
np=availData.used.np;
%number of initial sample poins
ns=availData.used.ns;
%size of the required non-sample points
nv=size(evalSample);
nv(3)=size(evalSample,3);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%reordering non-sample points
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
%normalisation of the sample points
if availData.norm.on
    reqRespN=NormRenorm(reqResp,'norm',availData.norm.sampling);
else
    reqRespN=reqResp;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%variables for storage
if np>1
    varResp=zeros(size(reqRespN,1),1);
    valRespN=varResp;
    valGrad=zeros(nbReqEval,np);
    valGradN=valGrad;
else
    varResp=[];
    valRespN=[];
    valGrad=[];
    valGradN=[];
end
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
samplingU=availData.used.sampling;
respU=availData.used.resp;
gradU=availData.used.grad;
samplingI=availData.in.sampling;
respI=availData.in.resp;
gradI=availData.in.grad;

%check or not the interpolation quality of the surrogate model
if availData.check
    checkZN=zeros(ns,1);
    checkGZN=zeros(ns,np);
end
%depending of the type of surrogate model
switch availData.type
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    case 'SWF'
        %% Evaluation of the 'Shepard Weighting Functions' surrogate model
        for jj=1:nbReqEval
            [valRespN(jj),G]=SWFEval(reqRespN(jj,:),availData);
            valGradN(jj,:)=G;
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case {'GRBF','RBF','InRBF'}
        %% Evaluation of the (Gradient-Enhanced) Radial Basis Functions (RBF/GRBF)
        parfor (jj=1:nbReqEval,numWorkers)
            [valRespN(jj),G,varResp(jj)]=RBFEval(reqRespN(jj,:),availData);
            valGradN(jj,:)=G;
        end
        %% check interpolation
        if availData.check
            parfor (jj=1:size(samplingU,1),numWorkers)
                [checkZN(jj),G]=RBFEval(samplingU(jj,:),availData);
                checkGZN(jj,:)=G;
            end
            if availData.normOn;
                checkZ=NormRenorm(checkZN,'renorm',availData.norm.resp);
            else
                checkZ=checkZN;
            end
            checkInterp(respI,checkZ,'resp')
            if availData.used.availGrad
                if availData.normOn;
                    checkGZ=NormRenormG(checkGZN,'renorm',availData.norm.sampling,availData.norm.resp);
                else
                    checkGZ=checkGZN;
                end
                checkInterp(gradI,checkGZ,'grad')
            end
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case {'KRG','GKRG','InKRG'}
        %specific storage
        stoZN=valRespN;trZN=valRespN;
        trGZN=valGradN;stoGZN=valGradN;
        %% Evaluation of the (Gradient-Enhanced) Kriging/Cokriging (KRG/GKRG)
        %parfor (jj=1:nbReqEval,numWorkers)
        for jj=1:nbReqEval
            [valRespN(jj),G,varResp(jj),detKRG]=KRGEval(reqRespN(jj,:),availData);
            valGradN(jj,:)=G;
            stoZN(jj)=detKRG.stoZ;
            trZN(jj)=detKRG.trZ;
            trGZN(jj,:)=detKRG.trGZ;
            stoGZN(jj,:)=detKRG.stoGZ;
        end
        %% check interpolation
        if availData.check
            parfor (jj=1:size(samplingU,1),numWorkers)
                [checkZN(jj),G]=KRGEval(samplingU(jj,:),availData);
                checkGZN(jj,:)=G;
            end
            if availData.normOn;
                checkZ=NormRenorm(checkZN,'renorm',availData.norm.resp);
            else
                checkZ=checkZN;
            end
            checkInterp(respI,checkZ,'resp')
            if availData.used.availGrad
                if availData.normOn;
                    checkGZ=NormRenormG(checkGZN,'renorm',availData.norm.sampling,availData.norm.resp);
                else
                    checkGZ=checkGZN;
                end
                checkInterp(gradI,checkGZ,'grad')
            end
        end
    case {'SVR','InSVR','GSVR'}
        %% Evaluation of the (Gradient-Enhanced) SVR (SVR/GSVR)
        %parfor (jj=1:nbReqEval,numWorkers)
        for jj=1:nbReqEval
            [valRespN(jj),G,varResp(jj)]=SVREval(reqRespN(jj,:),availData);
            valGradN(jj,:)=G;
        end
        %% check interpolation
        if availData.check
            parfor (jj=1:size(samplingU,1),numWorkers)
                [checkZN(jj),G]=SVREval(samplingU(jj,:),availData);
                checkGZN(jj,:)=G;
            end
            if availData.normOn;
                checkZ=NormRenorm(checkZN,'renorm',availData.norm.resp);
            else
                checkZ=checkZN;
            end
            checkInterp(respI,checkZ,'resp')
            if availData.used.availGrad
                if availData.normOn;
                    checkGZ=NormRenormG(checkGZN,'renorm',availData.norm.sampling,availData.norm.resp);
                else
                    checkGZ=checkGZN;
                end
                checkInterp(gradI,checkGZ,'grad')
            end
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        
    case 'DACE'
        %% Evaluation du metamodele de Krigeage (DACE)
        for jj=1:nbReqEval
            [valRespN(jj),G,varResp(jj)]=predictor(reqRespN(jj,:),availData.model);
            valGradN(jj,:)=G;
        end
        %% check interpolation
        if availData.check
            parfor (jj=1:size(samplingU,1),numWorkers)
                [checkZN(jj),G]=predictor(samplingU(jj,:),availData.model);
                checkGZN(jj,:)=G;
            end
            checkInterp(respU,checkZN,'resp')
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case 'PRG'
        for degre=availData.deg
            %% Evaluation of the polynomial regression surrogate model
            parfor (jj=1:nbReqEval,numWorkers)
                valRespN(jj)=LSEval(availData.prg.coef,reqRespN(jj,1),evalSample(jj,2),availData);
                %calculation of the gradients
                [GRG1,GRG2]=LSEvalD(availData.prg.coef,reqRespN(jj,1),evalSample(jj,2),availData);
                valGradN(jj,:)=[GRG1,GRG2];
            end
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case 'ILIN'
        %% interpolation using linear shape functions
        parfor (jj=1:nbReqEval,numWorkers)
            [valRespN(jj),G]=LInterpEval(reqRespN(jj,:),availData);
            valGradN(jj,:)=G;
        end
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case 'ILAG'
        %% interpolation using linear shape functions based on Lagrange polynoms
        parfor (jj=1:nbReqEval,numWorkers)
            [valRespN(jj),G]=LagInterpEval(reqRespN(jj,:),availData);
            valGradN(jj,:)=G;
            
        end
    otherwise
        error(['Wrong type of surrogate model (see. on ',mfilename,')']);
        
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
% compute infill criteria
explorEI=[];
exploitEI=[];
ei=[];
wei=[];
gei=[];
lcb=[];
if availData.infill.on&&exist('varResp','var')
    %smallest response
    respMin=min(respU);
    %computation of infill criteria
    [ei,wei,gei,lcb,exploitEI,explorEI]=InfillCrit(respMin,valRespN,varResp,availData.infill);
end


%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
% Renormalization of the data
% responses
if availData.norm.on
    valResp=NormRenorm(valRespN,'renorm',availData.norm.resp);
    %specific components
    if exist('stoZN','var')&&exist('trZN','var')
        stoZ=NormRenorm(stoZN,'renorm',availData.norm.resp);
        trZ=NormRenorm(trZN,'renorm',availData.norm.resp);
    end
    %gradients
    if exist('valGradN','var')
        valGrad=NormRenormG(valGradN,'renorm',availData.norm.sampling,availData.norm.resp);
        if exist('stoGZN','var')&&exist('trGZN','var')
            stoGZ=NormRenormG(stoGZN,'renorm',availData.norm.sampling,availData.norm.resp);
            trGZ=NormRenormG(trGZN,'renorm',availData.norm.sampling,availData.norm.resp);
        end
    end
else
    valResp=valRespN;
    if exist('stoZN','var')&&exist('trZN','var')
        stoZ=stoZN;
        trZ=trZN;
    end
    %gradients
    if exist('valGradN','var')
        valGrad=valGradN;
        if exist('stoGZN','var')&&exist('trGZN','var')
            stoGZ=stoGZN;
            trGZ=trGZN;
        end
    end
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
    mesuTime(tMesu,tInit);
    fprintf('#########################################\n');
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% function for checking interpolation
function checkInterp(ZRef,ZApp,type)
limitResp=1e-4;
limitGrad=1e-4;
switch type
    case 'resp'
        diffZ=abs(ZApp-ZRef);
        IXZcheck=find(diffZ>limitResp);
        if ~isempty(IXZcheck)
            fprintf('Interpolation issue (responses)\n')
            fprintf('Num\t||DiffZ \t||Eval \t\t||Zcheck\n');
            conc=vertcat(IXZcheck',diffZ(IXZcheck)',ZRef(IXZcheck)',ZApp(IXZcheck)');
            fprintf('%d\t||%4.2e\t||%4.2e\t||%4.2e\n',conc(:))
        end
    case 'grad'
        diffGZ=abs(ZApp-ZRef);
        IXGZcheck=find(diffGZ>limitGrad);
        if ~isempty(IXGZcheck)
            [IXi,~]=ind2sub(size(diffGZ),IXGZcheck);
            IXi=unique(IXi);
            fprintf('Interpolation issue (gradient)\n')
            nb_var=size(ZApp,2);
            tt=repmat('\t\t',1,nb_var);
            fprintf(['Num\t||DiffGZ' tt '||Grad' tt '||GZcheck\n']);
            conc=[IXi,diffGZ(IXi,:),ZRef(IXi,:),ZApp(IXi,:)]';
            tt=repmat('%4.2e\t',1,nb_var);
            tt=['%d\t||' tt '||' tt '||' tt '\n'];
            fprintf(tt,conc(:))
            
        end
        diffNG=abs(sqrt(sum(ZRef.^2,2))-sqrt(sum(ZApp.^2,2)));
        IXNGZverif=find(diffNG>limitGrad);
        if ~isempty(IXNGZverif)
            fprintf('Interpolation issue (gradient)\n')
            fprintf('DiffNG\n')
            fprintf('%4.2e\n',diffNG(IXNGZverif))
        end
end
end



