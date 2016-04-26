%% function for building surrogate model
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr

function [ret]=BuildMeta(sampling,respIn,gradIn,meta,num_fct)

fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('    >>> BUILDING SURROGATE MODEL <<<\n');
[tMesu,tInit]=mesu_time;
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
nbs=size(sampling,1);
fprintf(' >> Number of design variables: %d \n >> Number of sample points: %d\n',np,nbs);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%for building many different surrogate models
if ~iscell(meta.type)
    metype={meta.type};
else
    metype=meta.type;
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Normalization of the input data
if meta.norm
    fprintf(' >> Normalization\n');
    %normalization of the data
    [respN,infoDataR]=NormRenorm(respIn,'norm');
    [samplingN,infoDataS]=NormRenorm(sampling,'norm');
    infoData.stdR=infoDataR.std;stdR=infoDataR.std;
    infoData.moyR=infoDataR.moy;moyR=infoDataR.moy;
    infoData.stdS=infoDataS.std;stdS=infoDataS.std;
    infoData.moyS=infoDataS.moy;moyS=infoDataS.moy;
    if avail_grad
        gradN=NormRenormG(gradIn,'norm',infoDataS,infoDataR);
    end
    %sauvegarde des calculs
    swf.norm.moyR=infoDataR.moy;
    swf.norm.stdR=infoDataR.std;
    swf.norm.moyS=infoDataS.moy;
    swf.norm.stdS=infoDataS.std;
    swf.norm.on=true;
    clear infos_e infos_t
    clear infos
    swf.norm.on=true;
else
    swf.norm.on=false;
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
    InData=PrepIn()
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%% Building various surrogate models
%initialization of the storage
ret=cell(length(meta.type),1);
% Building of the surrogate models
num_meta=1;
for type=metype
    %Building surrogate model
    switch type{1}
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        case 'SWF'
            %% Building of the 'Shepard Weighting Functions' surrogate model
            out_meta=BuildSWF(samplingN,respIn,grad_in,meta);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'RBF','InRBF','GRBF'}
            [InD,GE]=CheckGE(type{1})
            %% construction du metamodele 'RBF' (Radial Basis Functions)
            fprintf('\n%s\n',[textd 'Radial Basis Functions (RBF)' textf]);
            out_meta=BuildRBF(samplingN,respN,[],meta,missStatus);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'GRBF'
            %% construction du metamodele 'GRBF' (Hermite-Birkhoff Radial Basis Functions)
            fprintf('\n%s\n',[textd 'Gradient-based Radial Basis Functions (GRBF)' textf]);
            rbf=meta_rbf(samplingN,respIn,gradN,meta,missStatus);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'InKRG'
            %% Construction du metamodele de Krigeage Indirect
            fprintf('\n%s\n',[textd 'Krigeage indirect' textf]);
            inkrg=meta_inkrg(samplingN,respN,gradN,meta,missStatus); %% cas particulier prise en compte des r�ponses pour gradients au lieu des gradients evalues)
            out_meta=inkrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'InRBF'
            %% Construction du metamodele de Krigeage Indirect
            fprintf('\n%s\n',[textd 'Krigeage indirect' textf]);
            inrbf=meta_inrbf(samplingN,respN,gradN,meta,missStatus); %% cas particulier prise en compte des r�ponses pour gradients au lieu des gradients evalues)
            out_meta=inrbf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'CKRG'
            %% Construction du metamodele de CoKrigeage
            fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
            ckrg=meta_krg_ckrg(samplingN,respN,gradN,meta,missStatus);
            out_meta=ckrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'KRG'
            %% Construction du metamodele de Krigeage
            fprintf('\n%s\n',[textd 'Krigeage' textf]);
            krg=meta_krg_ckrg(samplingN,respN,[],meta,missStatus);
            out_meta=krg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'DACE'
            %% Construction du metamodele de Krigeage (DACE)
            fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
            if meta.para.estim
                switch meta.corr
                    case {'correxpg'}
                        lb=[meta.para.l_min.*ones(1,np), meta.para.p_min];
                        ub=[meta.para.l_max.*ones(1,np), meta.para.p_max];
                    otherwise
                        lb=meta.para.l_min.*ones(np,1);
                        ub=meta.para.l_max.*ones(np,1);
                end
                theta0=(ub-lb)./2;
                [dace.model,dace.perf]=dacefit(samplingN,respN,meta.regr,meta.corr,theta0,lb,ub);
            else
                switch meta.corr
                    case {'correxpg'}
                        theta0=[meta.para.l_val meta.para.p_val];
                    otherwise
                        theta0=meta.para.l_val;
                end
                [dace.model,dace.perf]=dacefit(sampling,respIn,meta.regr,meta.corr,theta0);
            end
            out_meta=dace;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            ite_prg=1;
            ret{num_meta}.prg=length(meta.deg);
            for degre=meta.deg
                %% Construction du metamodele de Regression polynomiale
                dd=['-- Degre du polynome \n',num2str(degre)];
                fprintf(dd);
                [prg.coef,prg.MSE]=meta_prg(samplingN,respN,degre);
                out_meta.prg{ite_prg}=prg;
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
    out_meta.bilan_manq=missStatus;
    out_meta.type=type{1};
    out_meta.nb_var=np;
    out_meta.nb_val=nbs;
    out_meta.tirages=sampling;
    out_meta.respN=respN;
    out_meta.gradN=gradN;
    out_meta.enrich=meta.enrich;
    if numel(metype)==1
        ret=out_meta;
    else
        ret{num_meta}=out_meta;
    end
    num_meta=num_meta+1;
end

mesu_time(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
end

%function for checking if the surrogate model is a classical
%gradient-enhanced or indirect gradient-enhanced surrogate model
function [Indirect,Classical]=CheckGE(typeSurrogate)
%check Indirect
nn=regexp(typeSurrogate,'^In');
Indirect=any(cellfun(@isempty,nn));
%check gradient-enhanced
nn=regexp(typeSurrogate,'^G');
Classical=any(cellfun(@isempty,nn));
end