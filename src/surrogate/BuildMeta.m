%% function for building surrogate model
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr

function [ret]=BuildMeta(sampling,respIn,gradIn,meta,num_fct)

fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('    >>> BUILDING SURROGATE MODEL <<<\n');
[tMesu,tInit]=mesu_time;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%taking into account gradients or not
if isempty(grad_in);avail_grad='Non';grad_in=[];else avail_grad='Oui';end
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
%check for indirect gradient-enhanced surrogate model
InGE=CheckGE(metype);

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Normalization of the input data
if meta.norm
    fprintf(' >> Normalization\n');
    %normalization of the data
    [respInN,infos_e]=norm_denorm(respIn,'norm');
    [samplingN,infos_t]=norm_denorm(sampling,'norm');
    infos.std_e=infos_e.std;std_e=infos_e.std;
    infos.moy_e=infos_e.moy;moy_e=infos_e.moy;
    infos.std_t=infos_t.std;std_t=infos_t.std;
    infos.moy_t=infos_t.moy;moy_t=infos_t.moy;
    if avail_grad
        gradInN=norm_denorm_g(gradIn,'norm',infos);
    end
    %sauvegarde des calculs
    swf.norm.moy_eval=infos_e.moy;
    swf.norm.std_eval=infos_e.std;
    swf.norm.moy_tirages=infos_t.moy;
    swf.norm.std_tirages=infos_t.std;
    swf.norm.on=true;
    clear infos_e infos_t
    clear infos
    swf.norm.on=true;
else
    swf.norm.on=false;
    respInN=respIn;
    samplingN=sampling;
    gradInN=grad;
end

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Check input data (find missing data)
[bilan_manq]=CheckInputData(samplingN,respInN,gradInN);

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
            out_meta=BuildRBF(samplingN,respInN,[],meta,bilan_manq);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'GRBF'
            %% construction du metamodele 'GRBF' (Hermite-Birkhoff Radial Basis Functions)
            fprintf('\n%s\n',[textd 'Gradient-based Radial Basis Functions (GRBF)' textf]);
            rbf=meta_rbf(samplingN,respIn,gradInN,meta,bilan_manq);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'InKRG'
            %% Construction du metamodele de Krigeage Indirect
            fprintf('\n%s\n',[textd 'Krigeage indirect' textf]);
            inkrg=meta_inkrg(samplingN,respInN,gradInN,meta,bilan_manq); %% cas particulier prise en compte des r�ponses pour gradients au lieu des gradients evalues)
            out_meta=inkrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'InRBF'
            %% Construction du metamodele de Krigeage Indirect
            fprintf('\n%s\n',[textd 'Krigeage indirect' textf]);
            inrbf=meta_inrbf(samplingN,respInN,gradInN,meta,bilan_manq); %% cas particulier prise en compte des r�ponses pour gradients au lieu des gradients evalues)
            out_meta=inrbf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'CKRG'
            %% Construction du metamodele de CoKrigeage
            fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
            ckrg=meta_krg_ckrg(samplingN,respInN,gradInN,meta,bilan_manq);
            out_meta=ckrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'KRG'
            %% Construction du metamodele de Krigeage
            fprintf('\n%s\n',[textd 'Krigeage' textf]);
            krg=meta_krg_ckrg(samplingN,respInN,[],meta,bilan_manq);
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
                [dace.model,dace.perf]=dacefit(samplingN,respInN,meta.regr,meta.corr,theta0,lb,ub);
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
                [prg.coef,prg.MSE]=meta_prg(samplingN,respInN,degre);
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
    out_meta.bilan_manq=bilan_manq;
    out_meta.type=type{1};
    out_meta.nb_var=np;
    out_meta.nb_val=nbs;
    out_meta.tirages=sampling;
    out_meta.respN=respInN;
    out_meta.gradN=gradInN;
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
Indirect=false;
Classical=false;
if 
%check Indirect
chkIn=finstr(typeSurrogate,'In');
if chkIn(1)==1;Indirect=true;end
%check gradient-enhanced
chkGE=finstr(typeSurrogate,'G');
if chkGE(1)==1;Classical=true;end
end