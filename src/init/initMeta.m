%% Initialization of the surrogate model
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

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

classdef initMeta < handle
    properties
        useGrad=true;         %taking into account gradients
        type='KRG';            %type of surrogate model
        normOn=true;        %normalization
        recond=true;        %improve condition number of matrix (kriging, RBF, SVR...)
        kern='matern32';    %kernel function
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Check interpolation
        checkInterp=true;   %activate/deactivate the checking of the interpolation property
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        para;               %struct for storing choice of parameters
        estim;              %struct for storing estimation parameters
        infill;             %struct for storing infillment parameters
        cv;                 %struct for storing cross-validation parameters
    end
    properties (SetObservable, AbortSet)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%parameters
        stepTaylor=10^-2;   %Taylor's step for indirect gradient-based
        lVal=1;             %internal length (correlation length)
        pVal=2;             %power exponent for generalized exponential kernel function
        nuVal=0.6;          %smoothness coefficient for Matern kernel function
        lMin=1e-4;
        lMax=30;
        pMax=2;
        pMin=1.001;
        nuMin=1.5;
        nuMax=5;
        polyOrder=0;        %polynomial order for kriging, xLS
        swfPara=1;          %swf parameter
        %% internal parameters for SVR/GSVR
        e0=1e-2;            %thickness of the tube (not used for nu-SVR)
        ek=1e-2;            %thickness of the tube of gradient (not used for nu-SVR)
        c0=1e2;             %constant for trade off between flatness of the function and the amount up to
        %which deviations larger to e0 are tolerated
        ck=1e2;             %same trade off constant as before
        nuSVR=0.6;          %parameter of the nu-SVR (nu in [0,1])
        nuGSVR=0.6;         %idem for nu-GSVR
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% internal parameters estimation
        estimOn=true;       % seek for best values of the internal parameters
        aniso=true;         % anisotropic model (one internal length per variable)
        dispEstim=false;    % display objective function to be minimised
        saveEstim=false;    % save evolution function to be minimized
        typeEstim='logli';  % type of criterion used for estimated the parameters (logli or cv or cvmse or cvwmse or cvlpp)
        dispIterGraph=false;% display iterations of the optimisation process on a figure (1D/2D)
        dispIterCmd=false;  % display iteration in the console
        dispPlotAlgo=false; % display converg ence information on figures
        method='pso';       % optimizer used for finding internal parameter
        sampManuOn=0;       % initial sampling or not
        sampManu='IHS';     % method used for the initial sampling for GA ('', 'LHS','IHS'...)
        nbSampInit=[];      % number of sample points of the initial sampling for GA
        critOpti=10^-6;     % Value of the stopping criterion of the optimizer
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cvOn=true;          %cross-validation
        cvFull=false;       %compute all CV criteria
        cvDisp=false;       %display QQ plot CV
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% infill strategy
        %infillOn=false;     %activate/desactivate computation of the infill criterion
        infillCrit='EI';    %type of criterion used for the infill strategy
        infillParaWEI=0.5;  %parameters for Weighted Expected Improvement
        infillParaGEI=1;    %parameters for Generalized Expected Improvement
        infillParaLCB=0.5;  %parameters for Lower Confidence Bound
    end
    properties (Access = private,Constant)
        infoProp=affectTxtProp;
        kernAvail={'cauchy','circular','constant',...
            'cubicspline0','cubicspline1','cubicspline2',...
            'expg','expo','invmultiqua','linear','linearspline',...
            'logk','matern','matern32','matern52','multiqua','powerk',...
            'quadraticspline','ratmultiqua','tstudent','thinplatespline',...
            'spherical','sexp','wave','wavelet','wendland',...
            'wendland10','wendland20','wendland21','wendland30',...
            'wendland31','wendland32','wendland41','wendland42',...
            'wendland52','wendland53'};
        typeAvail={'SWF','IDW','RBF','InRBF','GRBF','KRG','InKRG','GKRG','SVR','InSVR','GSVR','DACE','InDACE','xLS','GxLS','InxLS'};%,'PRG','ILIN','ILAG'};
        typeTxt={'Shepard Weighting Function or Inverse Distance Weighting',...
            'idem',...
            'Radial Basis Function',...
            'Gradient-Based Indirect Radial Basis Function',...
            'Gradient-Based Radial Basis Function',...
            'Kriging',...
            'Gradient-Based Indirect Kriging',...
            'Gradient-Based Cokriging',...
            'Support Vector Regression',...
            'Gradient-Based Indirect Support Vector Regression',...
            'Gradient-Based Support Vector Regression',...
            'DACE',...
            'Gradient-Based Indirect DACE',...
            'Least-squares',...
            'Gradient-Based Least-squares',...
            'Gradient-Based Indirect Least-squares'};
    end
    methods
        %constructor
        function obj=initMeta(varargin)
            %if they are input variables
            if nargin>0;conf(obj,varargin{:});end
            %display message
            Gfprintf(' >>> Initialization of the metamodel configuration\n');
            %listeners
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%add listener for specific event (execute method after the set
            %%of the 'SetObservable' properties
            %find the 'SetObservable' properties
            setObservProperties=findAttrValue(obj,'SetObservable');
            %create listeners
            addlistener(obj,setObservProperties,'PostSet',@obj.updateAllStruct);
            %create all structures
            updateAllStruct(obj);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%setters
        function set.useGrad(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.useGrad,boolIn)
                    Gfprintf(' >>> Use input gradients : ');
                    SwitchOnOff(boolIn);
                end
                obj.useGrad=boolIn;
            end
        end
        function set.type(obj,charIn)
            if isG(charIn,'char')
                if ismember(charIn,obj.typeAvail)
                    if ~strcmp(obj.type,charIn)
                        Gfprintf(' >>> Type of metamodel : %s (previous %s)\n',charIn,obj.type);
                    end
                    obj.type=charIn;
                else
                    Gfprintf(' Type %s not available\n',charIn);
                    availableType(obj);
                    error('STOP');
                end
            end
        end
        function set.stepTaylor(obj,doubleIn)
            if checkDouble(doubleIn,obj.stepTaylor,'Taylor''s step for indirect gradient-based',0,[])
                obj.stepTaylor=doubleIn;
            end
        end
        function set.lVal(obj,doubleIn)
            if checkDouble(doubleIn,obj.lVal,'Internal length',0,[])
                obj.lVal=doubleIn;
            end
        end
        function set.lMin(obj,doubleIn)
            if checkDouble(doubleIn,obj.lMin,'Minimum internal length',0,[])
                obj.lMin=doubleIn;
            end
        end
        function set.lMax(obj,doubleIn)
            if checkDouble(doubleIn,obj.lMax,'Maximum internal length',0,[])
                obj.lMax=doubleIn;
            end
        end
        function set.pMin(obj,doubleIn)
            if checkDouble(doubleIn,obj.pMin,'Minimum power exponent generalized exponential kernel',0,[])
                obj.pMin=doubleIn;
            end
        end
        function set.pMax(obj,doubleIn)
            if checkDouble(doubleIn,obj.pMax,'Maximum power exponent generalized exponential kernel',0,[])
                obj.pMax=doubleIn;
            end
        end
        function set.nuMin(obj,doubleIn)
            if checkDouble(doubleIn,obj.nuMin,'Minimum smoothness coefficient for Matern kernel',0,[])
                obj.nuMin=doubleIn;
            end
        end
        function set.nuMax(obj,doubleIn)
            if checkDouble(doubleIn,obj.nuMax,'Maximum smoothness coefficient for Matern kernel',0,[])
                obj.nuMax=doubleIn;
            end
        end
        function set.pVal(obj,doubleIn)
            if ~isnan(doubleIn)
                if checkDouble(doubleIn,obj.pVal,'Power exponent generalized exponential kernel',0,[])
                    obj.pVal=doubleIn;
                end
            end
        end
        function set.nuVal(obj,doubleIn)
            if ~isnan(doubleIn)
                if checkDouble(doubleIn,obj.nuVal,'Smoothness coefficient for Matern kernel function',0,[])
                    obj.nuVal=doubleIn;
                end
            end
        end
        function set.polyOrder(obj,doubleIn)
            if checkDouble(doubleIn,obj.polyOrder,'Polynomial order for kriging, xLS',0,[])
                obj.polyOrder=doubleIn;
            end
        end
        function set.swfPara(obj,doubleIn)
            if checkDouble(doubleIn,obj.swfPara,'SWF parameter',0,[])
                obj.swfPara=doubleIn;
            end
        end
        function set.e0(obj,doubleIn)
            if checkDouble(doubleIn,obj.e0,'Thickness of the tube (nu-SVR)',0,[])
                obj.e0=doubleIn;
            end
        end
        function set.ek(obj,doubleIn)
            if checkDouble(doubleIn,obj.ek,'Thickness of the tube (nu-GSVR)',0,[])
                obj.ek=doubleIn;
            end
        end
        function set.c0(obj,doubleIn)
            if checkDouble(doubleIn,obj.c0,'Constant for trade off (nu-SVR)',0,[])
                obj.c0=doubleIn;
            end
        end
        function set.ck(obj,doubleIn)
            if checkDouble(doubleIn,obj.ck,'Constant for trade off (nu-GSVR)',0,[])
                obj.ck=doubleIn;
            end
        end
        function set.nuSVR(obj,doubleIn)
            if checkDouble(doubleIn,obj.nuSVR,'Parameter for nu-SVR',0,1)
                obj.nuSVR=doubleIn;
            end
        end
        function set.nuGSVR(obj,doubleIn)
            if checkDouble(doubleIn,obj.nuGSVR,'Parameter for nu-GSVR',0,1)
                obj.nuGSVR=doubleIn;
            end
        end
        function set.estimOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.estimOn,boolIn)
                    Gfprintf(' >>> Estimation of the hyperparameters : ');
                    SwitchOnOff(boolIn);
                end
                obj.estimOn=boolIn;
            end
        end
        function set.aniso(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.aniso,boolIn)
                    Gfprintf(' >>> anisotropic model : ');
                    SwitchOnOff(boolIn);
                end
                obj.aniso=boolIn;
            end
        end
        function set.dispEstim(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispEstim,boolIn)
                    Gfprintf(' >>> Show estimation process : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispEstim=boolIn;
            end
        end
        function set.saveEstim(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.saveEstim,boolIn)
                    Gfprintf(' >>> Save function used for finding hyperparameters : ');
                    SwitchOnOff(boolIn);
                end
                obj.saveEstim=boolIn;
            end
        end
        function set.typeEstim(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.typeEstim,charIn)
                    Gfprintf(' >>> Type of criterion used for finding hyperparameters : %s (previous %s)',charIn,obj.typeEstim);
                end
                obj.typeEstim=charIn;
            end
        end
        function set.dispIterGraph(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispIterGraph,boolIn)
                    Gfprintf(' >>> Plot iterations estimation process : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispIterGraph=boolIn;
            end
        end
        function set.dispIterCmd(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispIterCmd,boolIn)
                    Gfprintf(' >>> Display iterations in command windows : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispIterCmd=boolIn;
            end
        end
        function set.dispPlotAlgo(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispPlotAlgo,boolIn)
                    Gfprintf(' >>> Plot convergence information on figures : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispPlotAlgo=boolIn;
            end
        end
        function set.method(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.method,charIn)
                    Gfprintf(' >>> Optimizer for estimating hyperparameters : %s (previous %s)',charIn,obj.method);
                end
                obj.method=charIn;
            end
        end
        function set.sampManu(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.sampManu,charIn)
                    Gfprintf(' >>> DOE for initial sampling GA : %s (previous %s)',charIn,obj.sampManu);
                end
                obj.sampManu=charIn;
            end
        end
        function set.sampManuOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.sampManuOn,boolIn)
                    Gfprintf(' >>> Plot convergence information on figures : ');
                    SwitchOnOff(boolIn);
                end
                obj.sampManuOn=boolIn;
            end
        end
        function set.nbSampInit(obj,doubleIn)
            if checkDouble(doubleIn,obj.nbSampInit,'Number of sample points for GA, PSO',0,[])
                obj.nbSampInit=doubleIn;
            end
        end
        function set.critOpti(obj,doubleIn)
            if checkDouble(doubleIn,obj.critOpti,'Stopping criterion for estimation process',0,[])
                obj.critOpti=doubleIn;
            end
        end
        function set.kern(obj,charIn)
            if isG(charIn,'char')
                if ismember(charIn,obj.kernAvail)
                    if strcmp(obj.kern,charIn)
                        Gfprintf(' >>> Kernel function : %s (previous %s)\n',charIn,obj.kern);
                    end
                    obj.kern=charIn;
                else
                    Gfprintf(' Kernel function %s not available\n',charIn);
                    availableKernel(obj);
                end
            end
        end
        function set.normOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.normOn,boolIn)
                    Gfprintf(' >>> Normalization of the data : ');
                    SwitchOnOff(boolIn);
                end
                obj.normOn=boolIn;
            end
        end
        function set.recond(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.recond,boolIn)
                    Gfprintf(' >>> Improve condition number of matrices (KRG, RBF...) : ');
                    SwitchOnOff(boolIn);
                end
                obj.recond=boolIn;
            end
        end
        function set.cvOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.cvOn,boolIn)
                    Gfprintf(' >>> Cross-validation : ');
                    SwitchOnOff(boolIn);
                end
                obj.cvOn=boolIn;
            end
        end
        function set.cvFull(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.cvFull,boolIn)
                    Gfprintf(' >>> All CV criteria : ');
                    SwitchOnOff(boolIn);
                end
                obj.cvFull=boolIn;
            end
        end
        function set.cvDisp(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.cvDisp,boolIn)
                    Gfprintf(' >>> Display QQ plot CV : ');
                    SwitchOnOff(boolIn);
                end
                obj.cvDisp=boolIn;
            end
        end
        
%         function set.infillOn(obj,boolIn)
%             if isG(boolIn,'logical')
%                 if xor(obj.infillOn,boolIn)
%                     Gfprintf(' >>> Computation of the infill criterion : ');
%                     SwitchOnOff(boolIn);
%                 end
%                 obj.infillOn=boolIn;
%             end
%         end
        function set.infillCrit(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.infillCrit,charIn)
                    Gfprintf(' >>> Infill criterion : %s (previous %s)',charIn,obj.kern);
                end
                obj.infillCrit=charIn;
            end
        end
        function set.infillParaWEI(obj,doubleIn)
            if checkDouble(doubleIn,obj.infillParaWEI,'Parameter for Weighted EI',0,1)
                obj.infillParaWEI=doubleIn;
            end
        end
        function set.infillParaGEI(obj,doubleIn)
            if checkDouble(doubleIn,obj.infillParaGEI,'Parameter for Generalized EI',0,[])
                obj.infillParaGEI=doubleIn;
            end
        end
        function set.infillParaLCB(obj,doubleIn)
            if checkDouble(doubleIn,obj.infillParaLCB,'Parameter for Lower Confidence Bound',0,[])
                obj.infillParaLCB=doubleIn;
            end
        end
        function set.checkInterp(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.checkInterp,boolIn)
                    Gfprintf(' >>> Check interpolation property : ');
                    SwitchOnOff(boolIn);
                end
                obj.checkInterp=boolIn;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %list available techniques
        function availableType(obj)
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
            Gfprintf('Available techniques for surrogate models\n');
            dispTableTwoColumns(obj.typeAvail,obj.typeTxt);
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %list available kernel function
        function availableKernel(obj)
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
            Gfprintf('Available kernel functions for surrogate models\n');
            dispTableTwoColumns(obj.typeAvail,obj.typeTxt);
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %function for defining parameters
        function definePara(obj,paraIn)
            paraOk=false;
            if ~isempty(paraIn)
                if isa(paraIn,'struct')
                    obj.lVal=paraIn.l.Val;
                    obj.lMin=paraIn.l.Min;
                    obj.lMax=paraIn.l.Max;
                    obj.pVal=paraIn.p.Val;
                    obj.pMin=paraIn.p.Min;
                    obj.pMax=paraIn.p.Max;
                    obj.nuVal=paraIn.nu.Val;
                    obj.nuMin=paraIn.nu.Min;
                    obj.nuMax=paraIn.nu.Max;
                    obj.stepTaylor=paraIn.stepTaylor;
                    obj.polyOrder=paraIn.polyOrder;
                    obj.swfPara=paraIn.swfPara;
                    obj.e0=paraIn.e0;
                    obj.ek =paraIn.ek;
                    obj.c0=paraIn.c0;
                    obj.ck=paraIn.ck;
                    obj.nuSVR=paraIn.nuSVR;
                    obj.nuGSVR=paraIn.nuGSVR;
                    paraOk=true;
                    %update structure of parameters
                    obj.updatePara;
                end
            end
            if ~paraOk
                keyboard
                Gfprintf('Wrong structure used for declaraing parameters\n')
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %update para struct
        function updatePara(obj)
            obj.para.l.Val=obj.lVal;
            obj.para.l.Min=obj.lMin;
            obj.para.l.Max=obj.lMax;
            obj.para.p.Val=obj.pVal;
            obj.para.p.Min=obj.pMin;
            obj.para.p.Max=obj.pMax;
            obj.para.nu.Val=obj.nuVal;
            obj.para.nu.Min=obj.nuMin;
            obj.para.nu.Max=obj.nuMax;
            obj.para.stepTaylor=obj.stepTaylor;
            obj.para.polyOrder=obj.polyOrder;
            obj.para.swfPara=obj.swfPara;
            obj.para.e0=obj.e0;
            obj.para.ek=obj.ek;
            obj.para.c0=obj.c0;
            obj.para.ck=obj.ck;
            obj.para.nuSVR=obj.nuSVR;
            obj.para.nuGSVR=obj.nuGSVR;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %update infill struct
        function updateInfill(obj)
%             obj.infill.on=obj.infillOn;
            obj.infill.crit=obj.infillCrit;
            obj.infill.wei=obj.infillParaWEI;
            obj.infill.gei=obj.infillParaGEI;
            obj.infill.lcb=obj.infillParaLCB;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %update estimation struct
        function updateEstim(obj)
            obj.estim.on=obj.estimOn;
            obj.estim.aniso=obj.aniso;
            obj.estim.disp=obj.dispEstim;
            obj.estim.save=obj.saveEstim;
            obj.estim.type=obj.typeEstim;
            obj.estim.dispIterGraph=obj.dispIterGraph;
            obj.estim.dispIterCmd=obj.dispIterCmd;
            obj.estim.dispPlotAlgo=obj.dispPlotAlgo;
            obj.estim.method=obj.method;
            obj.estim.sampManuOn=obj.sampManuOn;
            obj.estim.sampManu=obj.sampManu;
            obj.estim.nbSampInit=obj.nbSampInit;
            obj.estim.critOpti=obj.critOpti;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %update cross-validation struct
        function updateCV(obj)
            obj.cv.on=obj.cvOn;
            obj.cv.full=obj.cvFull;
            obj.cv.disp=obj.cvDisp;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %update all structs
        function updateAllStruct(obj,~,~)
            updatePara(obj);
            updateInfill(obj);
            updateEstim(obj);
            updateCV(obj);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %define properties
        function conf(obj,varargin)
            %list properties
            listProp=properties(obj);
            okConf=false;
            %if a input variable is specifiec
            if nargin>2
                %if the number of input argument is even
                if  mod(nargin-1,2)==0
                    %along the argument
                    for itV=1:2:nargin-1
                        %extract keyword and associated value
                        keyW=varargin{itV};
                        keyV=varargin{itV+1};
                        %if the first argument is a string
                        if isa(varargin{1},'char')
                            %check if the keyword is acceptable
                            if ismember(keyW,listProp)
                                okConf=true;
                                obj.(keyW)=keyV;
                            else
                                Gfprintf('\n');
                                Gfprintf('>> Wrong keyword %s\n',keyW);
                            end
                        end
                    end
                end
                if ~okConf
                    Gfprintf('\nWrong syntax used for conf method\n');
                    Gfprintf('use: conf(''key1'',val1,''key2'',val2...)\n');
                    Gfprintf('\nList of the available keywords:\n');
                    dispTableTwoColumnsStruct(listProp,obj.infoProp);
                    Gfprintf('\n');
                end
            else
                Gfprintf('Current configuration\n');
                disp(obj);
            end
        end
        %overload isfield
        function isF=isfield(obj,field)
            isF=isprop(obj,field);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function for declaring the purpose of each properties
function info=affectTxtProp()
info.useGrad='Taking into account gradients';
info.type='type of surrogate model';
info.para='struct for storing choice of parameters';
info.stepTaylor='Taylor''s step for indirect gradient-based';
info.lVal='Nominal internal length (correlation length)';
info.pVal='Nominal power exponent for generalized exponential kernel function';
info.nuVal='Nominal smoothness coefficient for Matern kernel function';
info.lMin='Minimum internal length (correlation length)';
info.lMax='Maximum internal length (correlation length)';
info.pMax='Maximum power exponent for generalized exponential kernel function';
info.pMin='Minimum power exponent for generalized exponential kernel function';
info.nuMin='Minimum smoothness coefficient for Matern kernel function';
info.nuMax='Maximum smoothness coefficient for Matern kernel function';
info.polyOrder='Polynomial order for kriging, xLS';
info.swfPara='Swf parameter';
info.e0='Thickness of the tube (not used for nu-SVR)';
info.ek='Thickness of the tube of gradient (not used for nu-SVR)';
info.c0='Constant for trade off between flatness and deviations (SVR)';
info.ck='Same trade off constant as before';
info.nuSVR='Parameter of the nu-SVR (nu in [0,1])';
info.nuGSVR='Parameter of the nu-GSVR (nu in [0,1])';
info.estim='Struct for storing estimation parameters';
info.estimOn='Seek for best values of the internal parameters';
info.aniso='Anisotropic model (one internal length per variable)';
info.dispEstim='Display objective function to be minimised';
info.saveEstim='Save evolution function to be minimized';
info.typeEstim='Type of criterion used for estimated the parameters (logli or cv)';
info.dispIterGraph='Display iterations of the optimisation process on a figure (1D/2D)';
info.dispIterCmd='Display iteration in the console';
info.dispPlotAlgo='Display convergence information on figures';
info.method='Optimizer used for finding internal parameter';
info.sampManuOn='Initial sampling or not';
info.sampManu='Method used for the initial sampling for GA ('''', ''LHS'',''IHS''...)';
info.nbSampInit='Number of sample points of the initial sampling for GA';
info.critOpti='Value of the stopping criterion of the optimizer';
info.kern='Kernel function';
info.normOn='Normalization';
info.recond='Improve condition number of matrix (kriging, RBF, SVR...)';
info.cv='Struct for storing infillment parameters';
info.cvOn='Cross-validation';
info.cvFull='Compute all CV criteria';
info.cvDisp='Display QQ plot CV';
info.infill='Struct for storing infillment parameters';
info.infillOn='Activate/desactivate computation of the infill criterion';
info.infillCrit='Infill criterion';
info.infillParaWEI='Parameters for Weighted Expected Improvement';
info.infillParaGEI='Parameters for Generalized Expected Improvement';
info.infillParaLCB='Parameters for Lower Confidence Bound';
info.checkInterp='Activate/deactivate the checking of the interpolation property';
end

%function display table with two columns of text
function dispTableTwoColumnsStruct(tableFiedIn,structIn)
%size of every components in tableA
sizeA=cellfun(@numel,tableFiedIn);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableFiedIn)
    Gfprintf('%s%s%s\n',tableFiedIn{itT},spaceTxt(ones(1,spaceA(itT))),structIn.(tableFiedIn{itT}));
end
end

%function display table with two columns of text
function dispTableTwoColumns(tableA,tableB)
%size of every components in tableA
sizeA=cellfun(@numel,tableA);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableA)
    Gfprintf('%s%s%s\n',tableA{itT},spaceTxt(ones(1,spaceA(itT))),tableB{itT});
end
end

%function for checking type a variable and display error message
function okG=isG(varIn,typeIn)
okG=isa(varIn,typeIn);
if ~okG;Gfprintf(' Wrong input variable. Required: %s (current: %s)\n',typeIn,class(varIn));end
end

%function for checking 'double' input of a setter function (with bound
function okCD=checkDouble(varIn,varOld,TxtIn,lB,uB)
okCD=false;
oklB=true;
okuB=true;
%check if it is a double
if isG(varIn,'double')
    %check for different size of the previous and new values
    checkS=false;
    if numel(varOld)==1||numel(varIn)==1
        checkS=all(varOld~=varIn);
    else
        if all(size(varOld)==size(varIn))
            checkS=all(varOld~=varIn);
        end
    end
    if checkS
        %check if the bounds are respected
        if ~isempty(lB)
            oklB=all(varIn>=lB);
        end
        if ~isempty(uB)
            okuB=all(varIn<=uB);
        end
        if ~oklB||~okuB
            Gfprintf(' >>> %s: Wrong variable',TxtIn);
            if ~isempty(lB)
                Gfprintf('Lower bound:');fprintf(' %d',lB);fprintf('\n');
            end
            if ~isempty(uB)
                Gfprintf('Upper bound:');fprintf(' %d',uB);fprintf('\n');
            end
            Gfprintf('Proposed value:');fprintf(' %d',varIn);fprintf('\n');
        else
            Gfprintf(' >>> %s : [',TxtIn);
            fprintf('%i ',varIn);fprintf('] ');
            fprintf('(previous [');fprintf('%d ',varOld);fprintf('])\n');
            okCD=true;
        end
    end
end
end

%display change of state
function SwitchOnOff(boolIn)
if boolIn
    fprintf(' On (previous Off)\n');
else
    fprintf(' Off (previous On)\n');
end
end

%function for finding properties with specific attribute
function cl_out = findAttrValue(obj,attrName,varargin)
if ischar(obj)
    mc = meta.class.fromName(obj);
elseif isobject(obj)
    mc = metaclass(obj);
end
ii = 0; numb_props = length(mc.PropertyList);
cl_array = cell(1,numb_props);
for  c = 1:numb_props
    mp = mc.PropertyList(c);
    if isempty (findprop(mp,attrName))
        error('Not a valid attribute name')
    end
    attrValue = mp.(attrName);
    if attrValue
        if islogical(attrValue) || strcmp(varargin{1},attrValue)
            ii = ii + 1;
            cl_array(ii) = {mp.Name};
        end
    end
end
cl_out = cl_array(1:ii);
end

% function meta=initMeta(in,parallelOn)
%
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% chargement configuration particuliere
% if nargin==0
%     in=[];
% end
% %taking gradients into account
% if isfield(in,'useGrad');meta.useGrad=in.useGrad;end
% %type of surrgate model KRG/GKRG/DACE/RBF/GRBF/SVR/GSVR...
% if isfield(in,'type');meta.type=in.type;end
% %parameter of the kernel function
% if isfield(in,'para')
%     if isfield(in.para,'long');meta.para.l.val=in.para.long;end
%     if meta.para.estim
%         if isfield(in,'long');
%             meta.para.l.max=in.para.long(2);
%             meta.para.l.min=in.para.long(1);
%         end
%     end
%     if isfield(in.para,'pow');meta.para.p.val=in.para.pow;end
%     if meta.para.estim
%         if isfield(in,'pow');
%             meta.para.p.max=in.para.pow(2);
%             meta.para.p.min=in.para.pow(1);
%         end
%     end
%     if isfield(in.para,'nu');meta.para.nu.val=in.para.nu;end
%     if meta.para.estim
%         if isfield(in,'nu');
%             meta.para.nu.max=in.para.nu(2);
%             meta.para.nu.min=in.para.nu(1);
%         end
%     end
% end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% depending on the type of surrogate model
% switch meta.type
%     case 'SWF'
%         if isfield(in,'swf_para');meta.swf_para=in.swf_para;else meta.swf_para=swf_para;end
%     case 'DACE'
%         fctp='regpoly';
%         %regression function
%         if isfield(in,'polyOrder');meta.regr=[fctp num2str(in.polyOrder,'%d')];else meta.regr=[fctp num2str(meta.polyOrder,'%d')];end
%         %correlation function
%         if isfield(in,'corr');meta.corr=['corr' in.corr];else meta.corr=corr;end
%     case {'RBF','GRBF','InRBF'}
%         if isfield(in,'kern');meta.kern=in.kern;end
%     case {'KRG','GKRG','InKRG','SVR','GSVR'}
%         %order of the polynomial basis used for regression
%         if isfield(in,'polyOrder');meta.polyOrder=in.polyOrder;end;
%         %kernel function
%         if isfield(in,'kern');meta.kern=in.kern;end
%
%     otherwise
% end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %normalisation
% if isfield(in,'normOn');meta.normOn=in.normOn;end
% %improve condition number of the matrix
% if isfield(in,'recond');meta.recond=in.recond;end
% %cross-validation
% if isfield(in,'cv');meta.cv=in.cv;end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% estimation parametre long (longueur de correlation)
% if isfield(in,'para');
%     % seek for best values of the internal parameters
%     if isfield(in.para,'estim');meta.para.estim=in.para.estim;end
%     % anisotropic model (one internal length per variable)
%     if isfield(in.para,'aniso');meta.para.aniso=in.para.aniso;end
%     % display objective function to be minimised
%     if isfield(in.para,'dispEstim');meta.para.dispEstim=in.para.dispEstim;end
%     % display iterations of the optimisation process on a figure (1D/2D)
%     if isfield(in.para,'dispIterGraph');meta.para.dispIterGraph=in.para.dispIterGraph;end
%     % display iteration in the console
%     if isfield(in.para,'dispIterCmd');meta.para.dispIterCmd=in.para.dispIterCmd;end
%     % display convergence information on figures
%     if isfield(in.para,'dispPlotAlgo');meta.para.dispPlotAlgo=in.para.dispPlotAlgo;end
%     % optimizer used for finding internal parameter
%     if isfield(in.para,'method');meta.para.method=in.para.method;end
%     % method used for the initial sampling for GA ('', 'LHS','IHS'...)
%     if isfield(in.para,'popManu');meta.para.popManu=in.para.popManu;end
%     % number of sample points of the initial sampling for GA
%     if isfield(in.para,'norpopInitm');meta.para.popInit=in.para.popInit;end
%     % Value of the stopping criterion of the optimizer
%     if isfield(in.para,'critOpti');meta.para.critOpti=in.para.critOpti;end
%     if meta.para.estim
%         if isfield(in.para,'long');
%             meta.para.l.max=in.para.long(2);
%             meta.para.l.min=in.para.long(1);
%         end
%     end
% end
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% infill strategy
% if isfield(in,'infill');
%     if isfield(in.infill,'on');meta.infill.on=in.infill.on;end
%     if isfield(in.infill,'para_wei');meta.infill.para_wei=in.infill.para_wei;end
%     if isfield(in.infill,'para_gei');meta.infill.para_gei=in.infill.para_gei;end
%     if isfield(in.infill,'para_lcb');meta.infill.para_lcb=in.infill.para_lcb;end
%
%     % check interpolation
%     if isfield(in,'check');meta.check=in.check;end
% end


