%% Evaluation of the surrogate model
% L. LAURENT -- 04/12/2011 -- luc.laurent@lecnam.net
% modification: 12/12/2011

function [Z]=EvalMeta(evalSample,avaiData,metaData,Verb)

[tMesu,tInit]=mesu_time;

%reordering building data
if ~iscell(avaiData)
    buildData={avaiData};
    Z=struct;
else
    buildData=avaiData;
    if numel(avaiData)~=1
        Z=cell(size(avaiData));
    else
        Z=[];
    end
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%choose verbosity of the function
if nargin==3
    Verb=true;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%number of design parameters
np=buildData{1}.np;
%number of initial sample poins
ns=buildData{1}.ns;
%size of the required non-sample points
nbv=size(evalSample);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%reordering non-sample points
if np>1
    % if the non-sample points corresponds to a grid
    if nbv(3)~=1
        %number a required evaluations
        nbReqEval=prod(nbv(1:2));
        reqResp=zeros(nbReqEval,nbv(3));
        for ll=1:nbv(3)
            tmp=evalSample(:,:,ll);
            reqResp(:,ll)=tmp(:);
        end
    else
        %if not the number a required evaluations is determined
        nbReqEval=nbv(1);
        reqResp=evalSample;
    end
else
    nbReqEval=prod(nbv(1:2)); %number a required evaluations
    reqResp=evalSample(:);
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%variables for storage
if np>1
    varResp=zeros(size(reqResp,1),1);
    valResp=zeros(size(reqResp,1),1);
    valGrad=zeros(nbReqEval,np);
else
    varResp=[];
    valResp=[];
    valGrad=[];
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
    global parallel
    numWorkers=parallel.num;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%% Evaluation of various surrogate models
for numMeta=1:numel(buildData)
    type=buildData{numMeta}.type;
    metaBuild=buildData{numMeta};
    
    %load variables
    sampling=metaBuild.sampling;
    eval=metaBuild.eval;
    grad=metaBuild.grad;
    
    %check or not the interpolation quality of the surrogate model
    if metaData.check
        checkZ=zeros(ns,1);
        checkGZ=zeros(ns,np);
    end
    switch type
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        case 'SWF'
            %%	Evaluation of the 'Shepard Weighting Functions' surrogate model
            for jj=1:nbReqEval
                [valResp(jj),G]=SWFEval(reqResp(jj,:),metaBuild);
                valGrad(jj,:)=G;
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'GRBF','RBF','InRBF'}
            %% Evaluation of RBF/GRBF surrogate model
            parfor (jj=1:nbReqEval,numWorkers)                
                [valResp(jj),G,varResp(jj),det]=RBFEval(reqResp(jj,:),metaBuild);
                valGrad(jj,:)=G;
            end
            %% check interpolation
            if metaData.check
                parfor (jj=1:size(sampling,1),numWorkers)
                    [checkZ(jj),G]=RBFEval(sampling(jj,:),metaBuild);
                    checkGZ(jj,:)=G;
                end
                checkInterp(eval,checkZ,'resp')
                if metaBuild.in.availGrad
                    checkInterp(grad,checkGZ,'grad')
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'KRG','GKRG','InKRG'}            
            %specific storage
            stoZ=valResp;trZ=valResp;
            tzGZ=valGrad;stoGZ=valGrad;
            %% Evaluation of KRG/GKRG surrogate model
            parfor (jj=1:nbReqEval,numWorkers)
                [valResp(jj),G,varResp(jj),det]=KRGEval(reqResp(jj,:),metaBuild);
                valGrad(jj,:)=G;
                stoZ(jj)=det.stoZ;
                trZ(jj)=det.trZ;
                tzGZ(jj,:)=det.tzGZ;
                stoGZ(jj,:)=det.stoGZ;
            end
            %% check interpolation
            if metaData.check
                parfor (jj=1:size(sampling,1),numWorkers)
                    [checkZ(jj),G]=eval_krg_ckrg(sampling(jj,:),metaBuild);
                    checkGZ(jj,:)=G;
                end
                checkInterp(eval,checkZ,'resp')
                if metaBuild.in.pres_grad
                    checkInterp(grad,checkGZ,'grad')
                end
            end
            
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            
        case 'DACE'
            %% Evaluation of Kriging (DACE)
            for jj=1:nbReqEval
                [valResp(jj),G,varResp(jj)]=predictor(reqResp(jj,:),metaBuild.model);
                valGrad(jj,:)=G;
            end
            %% check interpolation
            if metaData.check
                parfor (jj=1:size(sampling,1),numWorkers)
                    [checkZ(jj),G]=predictor(sampling(jj,:),metaBuild.model);
                    checkGZ(jj,:)=G;
                end
                checkInterp(eval,checkZ,'resp')
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            for degre=metaData.deg
                %% Evaluation of the polynomial regression surrogate model
                parfor (jj=1:nbReqEval,numWorkers)
                    valResp(jj)=LSEval(metaBuild.prg.coef,reqResp(jj,1),evalSample(jj,2),metaBuild);
                    %calculation of the gradients
                    [GRG1,GRG2]=LSEvalD(metaBuild.prg.coef,reqResp(jj,1),evalSample(jj,2),metaBuild);
                    valGrad(jj,:)=[GRG1,GRG2];
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILIN'
            %% interpolation using linear shape functions
            parfor (jj=1:nbReqEval,numWorkers)
                [valResp(jj),G]=LInterpEval(reqResp(jj,:),metaBuild);
                valGrad(jj,:)=G;                
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILAG'
            %% interpolation using linear shape functions based on Lagrange polynoms
            parfor (jj=1:nbReqEval,numWorkers)
                [valResp(jj),G]=LagInterpEval(reqResp(jj,:),metaBuild);
                valGrad(jj,:)=G;
                
            end
            
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
    if metaData.infill.on&&exist('varResp','var')
        %smallest response
        respMin=min(metaBuild.eval);
        %computation of infill criteria
        [ei,wei,gei,lcb,exploitEI,explorEI]=InfillCrit(respMin,valResp,varResp,metaData.infill);
    end
    
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %reordering gradients
    if np>1
        if exist('stoGZ','var')==1&&exist('trGZ','var')==1
            stoGZFinal=zeros(nbv(1),nbv(2),nbv(3));
            trGZFinal=zeros(nbv(1),nbv(2),nbv(3));
        end
        GZ=zeros(nbv(1),nbv(2),nbv(3));
        if nbv(3)>1
            for ll=1:nbv(3)
                tmp=valGrad(:,ll);
                GZ(:,:,ll)=reshape(tmp,nbv(1),nbv(2));
            end
            if exist('stoGZ','var')==1&&exist('trGZ','var')==1
                for ll=1:nbv(3)
                    tmp=stoGZ(:,ll);
                    tmp1=tzGZ(:,ll);
                    stoGZFinal(:,:,ll)=reshape(tmp,nbv(1),nbv(2));
                    trGZFinal(:,:,ll)=reshape(tmp1,nbv(1),nbv(2));
                end
            end
        else
            GZ=valGrad;
            if exist('stoGZ','var')==1&&exist('trGZ','var')==1
                stoGZFinal=stoGZ;
                trGZFinal=tzGZ;
            end
        end
    else
        GZ=valGrad;
        if exist('stoGZ','var')==1&&exist('trGZ','var')==1
            stoGZFinal=stoGZ;
            trGZFinal=tzGZ;
        end
    end
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %Storage of evaluations
    if numel(buildData)==1
        if np>1
            if nbv(3)==1
                if exist('stoZ','var')==1&&exist('Z_reg','var')==1
                    Z.stoZ=stoZ;
                    Z.trZ=trZ;
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
                if exist('stoZ','var')==1&&exist('trZ','var')==1
                    Z.stoZ=reshape(stoZ,nbv(1),nbv(2));
                    Z.trZ=reshape(trZ,nbv(1),nbv(2));
                end
                Z.Z=reshape(valResp,nbv(1),nbv(2));
                if ~isempty(varResp);Z.var=reshape(varResp,nbv(1),nbv(2));end
                if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,nbv(1),nbv(2),size(wei,3));end, end
                if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,nbv(1),nbv(2));end, end
                if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,nbv(1),nbv(2),size(gei,3));end, end
                if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,nbv(1),nbv(2));end, end
                if exist('explorEI','var');if ~isempty(explorEI);Z.explorEI=reshape(explorEI,nbv(1),nbv(2));end, end
                if exist('exploitEI','var');if ~isempty(exploitEI);Z.exploitEI=reshape(exploitEI,nbv(1),nbv(2));end, end
            end
        else
            if exist('stoZ','var')==1&&exist('trZ','var')==1
                Z.stoZ=reshape(stoZ,nbv(1),nbv(2));
                Z.trZ=reshape(trZ,nbv(1),nbv(2));
            end
            Z.Z=reshape(valResp,nbv(1),nbv(2));
            if ~isempty(varResp);Z.var=reshape(varResp,nbv(1),nbv(2));end
            if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,nbv(1),nbv(2),size(wei,3));end, end
            if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,nbv(1),nbv(2));end, end
            if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,nbv(1),nbv(2),size(gei,3));end, end
            if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,nbv(1),nbv(2));end, end
            if exist('explorEI','var');if ~isempty(explorEI);Z.explorEI=reshape(explorEI,nbv(1),nbv(2));end, end
            if exist('exploitEI','var');if ~isempty(exploitEI);Z.exploitEI=reshape(exploitEI,nbv(1),nbv(2));end, end
        end
        Z.GZ=GZ;
        if exist('stoGZFinal','var')==1&&exist('trGZFinal','var')==1
            Z.stoGZFinal=stoGZFinal;Z.trGZFinal=trGZFinal;
        end
    else
        Z{numMeta}.Z=reshape(valResp,nbv(1),nbv(2));
        Z{numMeta}.GZ=GZ;
        if ~isempty('var_rep');Z{numMeta}.var=reshape(varResp,nbv(1),nbv(2));end
        if exist('wei','var');if ~isempty(wei);Z{numMeta}.wei=reshape(wei,nbv(1),nbv(2),size(wei,3));end, end
        if exist('gei','var');if ~isempty(gei);Z{numMeta}.gei=reshape(gei,nbv(1),nbv(2),size(gei,3));end, end
        if exist('ei','var');if ~isempty(ei);Z{numMeta}.ei=reshape(ei,nbv(1),nbv(2));end, end
        if exist('lcb','var');if ~isempty(lcb);Z{numMeta}.lcb=reshape(lcb,nbv(1),nbv(2));end, end
        if exist('explorEI','var');if ~isempty(explorEI);Z{numMeta}.explorEI=reshape(explorEI,nbv(1),nbv(2));end, end
        if exist('exploitEI','var');if ~isempty(exploitEI);Z{numMeta}.exploitEI=reshape(exploitEI,nbv(1),nbv(2));end, end
        if exist('stoGZFinal','var')==1&&exist('trGZFinal','var')==1
            Z{numMeta}.stoGZFinal=stoGZFinal;Z{numMeta}.trGZFinal=trGZFinal;
        end
        if exist('stoZ','var')==1&&exist('trZ','var')==1
            Z{numMeta}.stoZ=stoZ;Z{numMeta}.trZ=trZ;
        end
    end
end

if nbReqEval>1&&Verb
    fprintf('++ Evaluation at %i points\n',nbReqEval);
    mesu_time(tMesu,tInit);
    fprintf('#########################################\n');
end

end

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
            fprintf('Num\t||DiffZ \t||Eval \t||Zcheck\n');
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



