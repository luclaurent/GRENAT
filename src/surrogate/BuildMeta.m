%% function for building surrogate model
%% L. LAURENT -- 04/12/2011 -- luc.laurent@lecnam.net

function [outMeta]=BuildMeta(samplingIn,respIn,gradIn,metaData)

fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('    >>> BUILDING SURROGATE MODEL <<<\n');
[tMesu,tInit]=mesuTime;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%taking into account gradients or not
availGrad=false;
availGradTxt='No';
if  ~isempty(gradIn);
    availGrad=true;
    availGradTxt='Yes';
end
fprintf('\n++ Gradients are available: %s\n',availGradTxt);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%number of design variables
np=size(samplingIn,2);
%number of sample points
ns=size(samplingIn,1);
fprintf(' >> Number of design variables: %d \n >> Number of sample points: %d\n',np,ns);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Normalization of the input data
fprintf(' >> Normalization: ');if metaData.normOn; fprintf('Yes\n');else fprintf('No\n');end
if metaData.normOn
    %normalization of the data
    [respN,infoDataR]=NormRenorm(respIn,'norm');
    [samplingN,infoDataS]=NormRenorm(samplingIn,'norm');
    if availGrad
        gradN=NormRenormG(gradIn,'norm',infoDataS,infoDataR);
    end
else
    respN=respIn;
    samplingN=samplingIn;
    gradN=gradIn;
    infoDataR.std=[];
    infoDataR.mean=[];
    infoDataS.std=[];
    infoDataS.mean=[];
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Check input data (find missing data)
[metaData.miss]=CheckInputData(samplingN,respN,gradN);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%% Building various surrogate models
%variable for storing informations
outMeta=[];
%type of surrogate model
typeMeta=metaData.type;

%check indirect, classical or non-gradient-based approach
[InGE,cGE]=CheckGE(typeMeta);
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

if metaData.normOn
    metaData.norm.resp=infoDataR;
    metaData.norm.sampling=infoDataS;
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Building surrogate model
switch typeMeta
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    case 'SWF'
        %% Building of the 'Shepard Weighting Functions' surrogate model
        outMeta=SWFBuild(samplingOk,respOk,gradOk,metaData);
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case {'RBF','InRBF','GRBF'}
        %% Building of the (Gradient-Enhanced) Radial Basis Functions (RBF/GRBF)
        outMeta=RBFBuild(samplingOk,respOk,gradOk,metaData);
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case {'KRG','InKRG','GKRG'}
        %% Building of the (Gradient-Enhanced) Kriging/Cokriging (KRG/GKRG)
        outMeta=KRGBuild(samplingOk,respOk,gradOk,metaData);
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case {'SVR','InSVR','GSVR'}
        %% Building of the (Gradient-Enhanced) SVR (SVR/GSVR)
        outMeta=SVRBuild(samplingOk,respOk,gradOk,metaData);
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
            [dace.model,dace.perf]=dacefit(samplingIn,respIn,metaData.regr,metaData.corr,theta0);
        end
        outMeta=dace;
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
    case 'PRG'
        ite_prg=1;
        outMeta{numMeta}.prg=length(metaData.deg);
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
    otherwise
        error(['Wrong type of surrogate model (see. on ',mfilename,')']);
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%concatenate data
outMeta.used.sampling=samplingOk;
outMeta.used.resp=respOk;
outMeta.used.grad=gradOk;
outMeta.in.sampling=samplingIn;
outMeta.in.resp=respIn;
outMeta.in.grad=gradIn;
outMeta=mergestruct(outMeta,metaData);
outMeta.norm.on=metaData.normOn;

mesuTime(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
end

%function for checking if the surrogate model is a classical
%gradient-enhanced or indirect gradient-enhanced surrogate model
function [Indirect,Classical]=CheckGE(typeSurrogate)
%check Indirect
nn=regexp(typeSurrogate,'^In','ONCE');
Indirect=~isempty(nn);
%check gradient-enhanced
nn=regexp(typeSurrogate,'^G','ONCE');
Classical=~isempty(nn);
end