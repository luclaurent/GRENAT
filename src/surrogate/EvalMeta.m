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
dim_ev=size(evalSample);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%reordering non-sample points
if np>1
    % if the non-sample points corresponds to a grid
    if dim_ev(3)~=1
        %number a required evaluations
        nbReqEval=prod(dim_ev(1:2));
        reqResp=zeros(nbReqEval,dim_ev(3));
        for ll=1:dim_ev(3)
            tmp=evalSample(:,:,ll);
            reqResp(:,ll)=tmp(:);
        end
    else
        %if not the number a required evaluations is determined
        nbReqEval=dim_ev(1);
        reqResp=evalSample;
    end
else
    nbReqEval=prod(dim_ev(1:2)); %number a required evaluations
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
    tirages=metaBuild.tirages;
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
            %% Evaluation du metamodele de RBF/GRBF
            parfor (jj=1:nbReqEval,numWorkers)                
                [valResp(jj),G,varResp(jj),det]=RBFEval(reqResp(jj,:),metaBuild);
                valGrad(jj,:)=G;
            end
            %% verification interpolation
            if metaData.verif
                parfor (jj=1:size(tirages,1),numWorkers)
                    [checkZ(jj),G]=eval_rbf(tirages(jj,:),metaBuild);
                    checkGZ(jj,:)=G;
                end
                verif_interp(eval,checkZ,'rep')
                if metaBuild.in.pres_grad
                    verif_interp(grad,checkGZ,'grad')
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'KRG','CKRG','InKRG'}
            
            %stockage specifique
            Z_sto=valResp;Z_reg=valResp;
            GR_reg=valGrad;GR_sto=valGrad;
            %% Evaluation du metamodele de Krigeage/CoKrigeage
            parfor (jj=1:nbReqEval,numWorkers)
                [valResp(jj),G,varResp(jj),det]=eval_krg_ckrg(reqResp(jj,:),metaBuild);
                valGrad(jj,:)=G;
                Z_sto(jj)=det.Z_sto;
                Z_reg(jj)=det.Z_reg;
                GR_reg(jj,:)=det.GZ_reg;
                GR_sto(jj,:)=det.GZ_sto;
            end
            %% verification interpolation
            if metaData.verif
                parfor (jj=1:size(tirages,1),numWorkers)
                    [checkZ(jj),G]=eval_krg_ckrg(tirages(jj,:),metaBuild);
                    checkGZ(jj,:)=G;
                end
                verif_interp(eval,checkZ,'rep')
                if metaBuild.in.pres_grad
                    verif_interp(grad,checkGZ,'grad')
                end
            end
            
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            
        case 'DACE'
            %% Evaluation du metamodele de Krigeage (DACE)
            for jj=1:nbReqEval
                [valResp(jj),G,varResp(jj)]=predictor(reqResp(jj,:),metaBuild.model);
                valGrad(jj,:)=G;
            end
            %% verification interpolation
            if metaData.verif
                parfor (jj=1:size(tirages,1),numWorkers)
                    [checkZ(jj),G]=predictor(tirages(jj,:),metaBuild.model);
                    checkGZ(jj,:)=G;
                end
                verif_interp(eval,checkZ,'rep')
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            for degre=metaData.deg
                %% Evaluation du metamodele de Regression
                parfor (jj=1:nbReqEval,numWorkers)
                    valResp(jj)=eval_prg(metaBuild.prg.coef,reqResp(jj,1),evalSample(jj,2),metaBuild);
                    %evaluation des gradients du MT
                    [GRG1,GRG2]=evald_prg(metaBuild.prg.coef,reqResp(jj,1),evalSample(jj,2),metaBuild);
                    valGrad(jj,:)=[GRG1,GRG2];
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILIN'
            %% interpolation par fonction de base lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base linï¿½aire' textf]);
            parfor (jj=1:nbReqEval,numWorkers)
                [valResp(jj),G]=interp_lin(reqResp(jj,:),metaBuild);
                GR1(jj,:)=G;
                
            end
            
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILAG'
            %% interpolation par fonction polynomiale de Lagrange
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            parfor (jj=1:nbReqEval,numWorkers)
                [valResp(jj),G]=interp_lag(reqResp(jj,:),metaBuild);
                GR1(jj,:)=G;
                
            end
            
    end
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    % calcul des criteres d'enrichissement
    explor_EI=[];
    exploit_EI=[];
    ei=[];
    wei=[];
    gei=[];
    lcb=[];
    if metaData.enrich.on&&exist('var_rep','var')
        %reponse mini
        eval_min=min(metaBuild.eval);
        %calcul criteres enrichissement
        [ei,wei,gei,lcb,exploit_EI,explor_EI]=crit_enrich(eval_min,valResp,varResp,metaData.enrich);
    end
    
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %reconditionnement gradients
    if np>1
        if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
            GZ_sto=zeros(dim_ev(1),dim_ev(2),dim_ev(3));
            GZ_reg=zeros(dim_ev(1),dim_ev(2),dim_ev(3));
        end
        GZ=zeros(dim_ev(1),dim_ev(2),dim_ev(3));
        if dim_ev(3)>1
            for ll=1:dim_ev(3)
                tmp=valGrad(:,ll);
                GZ(:,:,ll)=reshape(tmp,dim_ev(1),dim_ev(2));
            end
            if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
                for ll=1:dim_ev(3)
                    tmp=GR_sto(:,ll);
                    tmp1=GR_reg(:,ll);
                    GZ_sto(:,:,ll)=reshape(tmp,dim_ev(1),dim_ev(2));
                    GZ_reg(:,:,ll)=reshape(tmp1,dim_ev(1),dim_ev(2));
                end
            end
        else
            GZ=valGrad;
            if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
                GZ_sto=GR_sto;
                GZ_reg=GR_reg;
            end
        end
    else
        GZ=valGrad;
        if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
            GZ_sto=GR_sto;
            GZ_reg=GR_reg;
        end
    end
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %Stockage des evaluations
    if numel(buildData)==1
        if np>1
            if dim_ev(3)==1
                if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                    Z.Z_sto=Z_sto;
                    Z.Z_reg=Z_reg;
                end
                Z.Z=valResp;
                if ~isempty(varResp);Z.var=varResp;end
                if exist('wei','var');if ~isempty(wei);Z.wei=wei;end, end
                if exist('ei','var');if ~isempty(ei);Z.ei=ei;end, end
                if exist('gei','var');if ~isempty(gei);Z.gei=gei;end, end
                if exist('lcb','var');if ~isempty(lcb);Z.lcb=lcb;end, end
                if exist('explor_EI','var');if ~isempty(explor_EI);Z.explor_EI=explor_EI;end, end
                if exist('exploit_EI','var');if ~isempty(exploit_EI);Z.exploit_EI=exploit_EI;end, end
            else
                if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                    Z.Z_sto=reshape(Z_sto,dim_ev(1),dim_ev(2));
                    Z.Z_reg=reshape(Z_reg,dim_ev(1),dim_ev(2));
                end
                Z.Z=reshape(valResp,dim_ev(1),dim_ev(2));
                if ~isempty(varResp);Z.var=reshape(varResp,dim_ev(1),dim_ev(2));end
                if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,dim_ev(1),dim_ev(2),size(wei,3));end, end
                if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,dim_ev(1),dim_ev(2));end, end
                if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,dim_ev(1),dim_ev(2),size(gei,3));end, end
                if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,dim_ev(1),dim_ev(2));end, end
                if exist('explor_EI','var');if ~isempty(explor_EI);Z.explor_EI=reshape(explor_EI,dim_ev(1),dim_ev(2));end, end
                if exist('exploit_EI','var');if ~isempty(exploit_EI);Z.exploit_EI=reshape(exploit_EI,dim_ev(1),dim_ev(2));end, end
            end
        else
            if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                Z.Z_sto=reshape(Z_sto,dim_ev(1),dim_ev(2));
                Z.Z_reg=reshape(Z_reg,dim_ev(1),dim_ev(2));
            end
            Z.Z=reshape(valResp,dim_ev(1),dim_ev(2));
            if ~isempty(varResp);Z.var=reshape(varResp,dim_ev(1),dim_ev(2));end
            if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,dim_ev(1),dim_ev(2),size(wei,3));end, end
            if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,dim_ev(1),dim_ev(2));end, end
            if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,dim_ev(1),dim_ev(2),size(gei,3));end, end
            if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,dim_ev(1),dim_ev(2));end, end
            if exist('explor_EI','var');if ~isempty(explor_EI);Z.explor_EI=reshape(explor_EI,dim_ev(1),dim_ev(2));end, end
            if exist('exploit_EI','var');if ~isempty(exploit_EI);Z.exploit_EI=reshape(exploit_EI,dim_ev(1),dim_ev(2));end, end
        end
        Z.GZ=GZ;
        if exist('GZ_sto','var')==1&&exist('GZ_reg','var')==1
            Z.GZ_sto=GZ_sto;Z.GZ_reg=GZ_reg;
        end
    else
        Z{numMeta}.Z=reshape(valResp,dim_ev(1),dim_ev(2));
        Z{numMeta}.GZ=GZ;
        if ~isempty('var_rep');Z{numMeta}.var=reshape(varResp,dim_ev(1),dim_ev(2));end
        if exist('wei','var');if ~isempty(wei);Z{numMeta}.wei=reshape(wei,dim_ev(1),dim_ev(2),size(wei,3));end, end
        if exist('gei','var');if ~isempty(gei);Z{numMeta}.gei=reshape(gei,dim_ev(1),dim_ev(2),size(gei,3));end, end
        if exist('ei','var');if ~isempty(ei);Z{numMeta}.ei=reshape(ei,dim_ev(1),dim_ev(2));end, end
        if exist('lcb','var');if ~isempty(lcb);Z{numMeta}.lcb=reshape(lcb,dim_ev(1),dim_ev(2));end, end
        if exist('explor_EI','var');if ~isempty(explor_EI);Z{numMeta}.explor_EI=reshape(explor_EI,dim_ev(1),dim_ev(2));end, end
        if exist('exploit_EI','var');if ~isempty(exploit_EI);Z{numMeta}.exploit_EI=reshape(exploit_EI,dim_ev(1),dim_ev(2));end, end
        if exist('GZ_sto','var')==1&&exist('GZ_reg','var')==1
            Z{numMeta}.GZ_sto=GZ_sto;Z{numMeta}.GZ_reg=GZ_reg;
        end
        if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
            Z{numMeta}.Z_sto=Z_sto;Z{numMeta}.Z_reg=Z_reg;
        end
    end
end

if nbReqEval>1&&Verb
    fprintf('++ Evaluation en %i points\n',nbReqEval);
    mesu_time(tMesu,tInit);
    fprintf('#########################################\n');
end

end

%%% routine de vérification de l'interpolation
function verif_interp(Ref,App,type)
limite_rep=1e-4;
limite_grad=1e-4;
switch type
    case 'rep'
        diffZ=abs(App-Ref);
        IXZverif=find(diffZ>limite_rep);
        if ~isempty(IXZverif)
            fprintf('Pb d''interpolation (eval)\n')
            fprintf('Num\t||DiffZ \t||Eval \t||Zverif\n');
            conc=vertcat(IXZverif',diffZ(IXZverif)',Ref(IXZverif)',App(IXZverif)');
            fprintf('%d\t||%4.2e\t||%4.2e\t||%4.2e\n',conc(:))
        end
    case 'grad'
        diffGZ=abs(App-Ref);
        IXGZverif=find(diffGZ>limite_grad);
        if ~isempty(IXGZverif)
            [IXi,~]=ind2sub(size(diffGZ),IXGZverif);
            IXi=unique(IXi);
            fprintf('Pb d''interpolation (grad)\n')
            nb_var=size(App,2);
            tt=repmat('\t\t',1,nb_var);
            fprintf(['Num\t||DiffGZ' tt '||Grad' tt '||GZverif\n']);
            conc=[IXi,diffGZ(IXi,:),Ref(IXi,:),App(IXi,:)]';
            tt=repmat('%4.2e\t',1,nb_var);
            tt=['%d\t||' tt '||' tt '||' tt '\n'];
            fprintf(tt,conc(:))
            
        end
        diffNG=abs(sqrt(sum(Ref.^2,2))-sqrt(sum(App.^2,2)));
        IXNGZverif=find(diffNG>limite_grad);
        if ~isempty(IXNGZverif)
            fprintf('Pb d''interpolation (grad)\n')
            fprintf('DiffNG\n')
            fprintf('%4.2e\n',diffNG(IXNGZverif))
        end
end
end



