%% function for building surrogate model
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr

function [ret]=BuildMeta(sampling,respIn,gradIn,metaData)

fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('    >>> BUILDING SURROGATE MODEL <<<\n');
[tMesu,tInit]=mesuTime;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%taking into account gradients or not
if isempty(gradIn);avail_grad='No';grad_in=[];else avail_grad='Yes';end
fprintf('\n++ Gradients are available: %s\n',avail_grad);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%number of design variables
np=size(sampling,2);
%number of sample points
ns=size(sampling,1);
fprintf(' >> Number of design variables: %d \n >> Number of sample points: %d\n',np,ns);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%for building many different surrogate models
if ~iscell(metaData.type)
    metype={metaData.type};
else
    metype=metaData.type;
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Normalization of the input data
if metaData.norm
    fprintf(' >> Normalization: ');if metaData.norm; fprintf('Yes\n');else fprintf('No\n');end
    %normalization of the data
    [respN,infoDataR]=NormRenorm(respIn,'norm');
    [samplingN,infoDataS]=NormRenorm(sampling,'norm');
    if avail_grad
        gradN=NormRenormG(gradIn,'norm',infoDataS,infoDataR);
    end
else
    respN=respIn;
    samplingN=sampling;
    gradN=grad;
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Check input data (find missing data)
[missStatus]=CheckInputData(samplingN,respN,gradN);

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%check for indirect gradient-enhanced surrogate model
InGE=CheckGE(metype);
if InGE
    IndirectData=PrepIn(samplingN,respN,gradN,metaData,missStatus);
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%% Building various surrogate models
%initialization of the storage
ret=cell(length(metaData.type),1);
% Building of the surrogate models
num_meta=1;
for type=metype
    [InGE,cGE]=CheckGE(metype);
    %%in the case of Indirect-gradient-based approach
    if InGE
        samplingOk=IndirectData.new.sampling;
        respOk=IndirectData.new.resp;
        gradOk=[];
        fprintf('\n%s\n',[textd 'Indirect gradient-enhanced approach' textf]);
    elseif cGE
        samplingOk=samplingN;
        respOk=respN;
        gradOk=gradN;
    else
        samplingOk=samplingN;
        respOk=respN;
        gradOk=[];
    end
    %Building surrogate model
    switch type{1}
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        case 'SWF'
            %% Building of the 'Shepard Weighting Functions' surrogate model
            outMeta=SWFBuild(samplingOk,respOk,gradOk,metaData);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'RBF','InRBF','GRBF'}
            %% Building of the (Gradient-Enhanced) Radial Basis Functions (RBF/GRBF)
            outMeta=RBFBuild(samplingOk,respOk,gradOk,metaData,missStatus);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'KRG','InKRG','GKRG'}
            %% Building of the (Gradient-Enhanced) Kriging/Cokriging (KRG/GKRG)
            outMeta=KRGBuild(samplingOk,respOk,gradOk,metaData,missStatus);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'DACE','InDACE'}
            %% Construction du metamodele de Krigeage (DACE)
            fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
            if metaData.para.estim
                switch metaData.corr
                    case {'correxpg'}
                        lb=[metaData.para.l_min.*ones(1,np), metaData.para.p_min];
                        ub=[metaData.para.l_max.*ones(1,np), metaData.para.p_max];
                    otherwise
                        lb=metaData.para.l_min.*ones(np,1);
                        ub=metaData.para.l_max.*ones(np,1);
                end
                theta0=(ub-lb)./2;
                [dace.model,dace.perf]=dacefit(samplingN,respN,metaData.regr,metaData.corr,theta0,lb,ub);
            else
                switch metaData.corr
                    case {'correxpg'}
                        theta0=[metaData.para.l_val metaData.para.p_val];
                    otherwise
                        theta0=metaData.para.l_val;
                end
                [dace.model,dace.perf]=dacefit(sampling,respIn,metaData.regr,metaData.corr,theta0);
            end
            outMeta=dace;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            ite_prg=1;
            ret{num_meta}.prg=length(metaData.deg);
            for degre=metaData.deg
                %% Construction du metamodele de Regression polynomiale
                dd=['-- Degre du polynome \n',num2str(degre)];
                fprintf(dd);
                [prg.coef,prg.MSE]=meta_prg(samplingN,respN,degre);
                outMeta.prg{ite_prg}=prg;
                ite_prg=ite_prg+1;
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILIN'
            %% Construction du metamodele d'interpolation lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base ' textf]);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILAG'
            %% interpolation par fonction de base lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
    end
    
    
    %stockage des informations utiles
    outMeta.missStatus=missStatus;
    outMeta.type=type{1};
    outMeta.np=np;
    outMeta.ns=ns;
    outMeta.sampling=sampling;
    outMeta.respN=respN;
    outMeta.gradN=gradN;
    outMeta.infill=metaData.infill;
    if numel(metype)==1
        ret=outMeta;
    else
        ret{num_meta}=outMeta;
    end
    num_meta=num_meta+1;
end

mesuTime(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
end

%function for checking if the surrogate model is a classical
%gradient-enhanced or indirect gradient-enhanced surrogate model
function [Indirect,Classical]=CheckGE(typeSurrogate)
%check Indirect
nn=regexp(typeSurrogate,'^In');
Indirect=~all(cellfun(@isempty,nn));
%check gradient-enhanced
nn=regexp(typeSurrogate,'^G');
Classical=~all(cellfun(@isempty,nn));
end