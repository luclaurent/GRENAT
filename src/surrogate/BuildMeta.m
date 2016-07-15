%% function for building surrogate model
% L. LAURENT -- 04/12/2011 -- luc.laurent@lecnam.net

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

function [outMeta]=BuildMeta(samplingIn,respIn,gradIn,metaData)

fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('    >>> BUILDING SURROGATE MODEL <<<\n');
countTime=mesuTime;
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
%%%%%%% Building various surrogate models
%variable for storing informations
outMeta=[];
%type of surrogate model
typeMeta=metaData.type;

%check indirect, classical or non-gradient-based approach
[InGE,cGE]=CheckGE(typeMeta);
%%in the case of Indirect-gradient-based approach
if InGE
    IndirectData=PrepIn(samplingIn,respIn,gradIn,metaData,metaData.miss);
    samplingOk=IndirectData.new.sampling;
    respOk=IndirectData.new.resp;
    gradOk=[];
    fprintf('\n%s\n','>> Indirect gradient-enhanced approach');
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

countTime.stop;
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