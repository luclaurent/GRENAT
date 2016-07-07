%% Initialization of the surrogate model
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

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

classdef initMeta < handle
    properties
        useGrad=true;         %taking into account gradients
        type='KRG';            %type of surrogate model
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%parameters
        para;               %struct for storing choice of parameters
        stepTaylor=10^-2;   %Taylor's step for indirect gradient-based
        lVal=1;             %internal length (correlation length)
        pVal=2;             %power exponent for generalized exponential kernel function
        nuVal=0.6;          %smoothness coefficient for Matern kernel function
        polyOrder=1;        %polynomial order for kriging, xLS
        swfPara=1;         %swf parameter
        %% internal parameters for SVR/GSVR
        e0=1e-2;            %thickness of the tube (not used for nu-SVR)
        ek=1e-2;            %thickness of the tube of gradient (not used for nu-SVR)
        c0=1e6;             %constant for trade off between flatness of the function and the amount up to
                            %which deviations larger to e0 are tolerated
        ck=1e6;             %same trade off constant as before
        nuSVR=0.6;          %parameter of the nu-SVR (nu in [0,1])
        nuGSVR=0.6;         %idem for nu-GSVR
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% internal parameters estimation
        estim=true;         % seek for best values of the internal parameters
        aniso=true;         % anisotropic model (one internal length per variable)
        dispEstim=false;    % display objective function to be minimised
        saveEstim=false;         %save evolution function to be minimized
        dispIterGraph=false;% display iterations of the optimisation process on a figure (1D/2D)
        dispIterCmd=false;  % display iteration in the console
        dispPlotAlgo=false; % display convergence information on figures
        method='pso';       % optimizer used for finding internal parameter
        sampManuOn=0;       % initial sampling or not
        sampManu='IHS';     % method used for the initial sampling for GA ('', 'LHS','IHS'...)
        nbSampInit=[];      % number of sample points of the initial sampling for GA
        critOpti=10^-6;     % Value of the stopping criterion of the optimizer
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        kern='matern32';    %kernel function
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        normOn=true;        %normalization
        recond=true;        %improve condition number of matrix (kriging, RBF, SVR...)
        cvOn=true;          %cross-validation
        cvFull=false;       %compute all CV criteria
        cvDisp=false;       %display QQ plot CV
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% infill strategy
        infillOn=false;     %activate/desactivate computation of the infill criterion
        infillParaWEI=0.5;  %parameters for Weighted Expected Improvement
        infillParaGEI=1;    %parameters for Generalized Expected Improvement   
        infillParaLCB=0.5;  %parameters for Lower Confidence Bound 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Check interpolation
        checkInterp=true;   %activate/deactivate the checking of the interpolation property
    end
    properties (Access = private,Constant)
        infoProp=affectTxtProp;
        typeAvail={};
        typeTxt={};
    end
    methods
         %constructor
        function obj=initMeta(varargin)            
            %if they are input variables
            if nargin>0;conf(obj,varargin{:});end
            %display message
            fprintf('=========================================\n')
            fprintf(' >> Initialization of the metamodel configuration\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%setters
        function set.useGrad(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.useGrad,boolIn)
                    fprintf(' >>> Use input gradients : ');
                    SwitchOnOff(boolIn);
                end
                obj.useGrad=boolIn;
            end
        end
        %        
        function set.type(obj,charIn)
            if isG(charIn,'char')
                if ismember(charIn,obj.typeAvail)
                    if strcmp(obj.type,charIn)
                        fprintf(' >>> Type of metamodel : %s (previous %s)',charIn,obj.type);
                    end
                    obj.type=charIn;
                else
                    fprintf(' Type %s not available\n',charIn);
                    availableType(obj);
                end
            end
        end
        %
        function set.para(obj,varargin)
            keyOk={'',''};
            
        end
        function set.stepTaylor(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.stepTaylor~=doubleIn)
                    fprintf(' >>> Taylor''s step for indirect gradient-based : [');
                    fprintf('%d ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.stepTaylor);fprintf('])\n');
                end
                obj.stepTaylor=doubleIn;
            end
        end
        function set.lVal(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.lVal~=doubleIn)
                    fprintf(' >>> Internal length : [');
                    fprintf('%d ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.lVal);fprintf('])\n');
                end
                obj.lVal=doubleIn;
            end
        end
        function set.pVal(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.pVal~=doubleIn)
                    fprintf(' >>> Power exponent generalized exponential kernel : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.pVal);fprintf('])\n');
                end
                obj.pVal=doubleIn;
            end
        end
        function set.nuVal(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nuVal~=doubleIn)
                    fprintf(' >>> Smoothness coefficient for Matern kernel function : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.nuVal);fprintf('])\n');
                end
                obj.nuVal=doubleIn;
            end
        end
        function set.polyOrder(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.polyOrder~=doubleIn)
                    fprintf(' >>> Polynomial order for kriging, xLS : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.polyOrder);fprintf('])\n');
                end
                obj.polyOrder=doubleIn;
            end
        end
        function set.swfPara(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.swfPara~=doubleIn)
                    fprintf(' >>> SWF parameter : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.swfPara);fprintf('])\n');
                end
                obj.swfPara=doubleIn;
            end
        end
        function set.e0(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.e0~=doubleIn)
                    fprintf(' >>> Thickness of the tube (nu-SVR) : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.e0);fprintf('])\n');
                end
                obj.e0=doubleIn;
            end
        end
        function set.ek(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.ek~=doubleIn)
                    fprintf(' >>> Thickness of the tube (nu-GSVR) : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.ek);fprintf('])\n');
                end
                obj.ek=doubleIn;
            end
        end
        function set.c0(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.c0~=doubleIn)
                    fprintf(' >>> Constant for trade off (nu-SVR) : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.c0);fprintf('])\n');
                end
                obj.c0=doubleIn;
            end
        end
        function set.ck(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.ck~=doubleIn)
                    fprintf(' >>> Constant for trade off (nu-GSVR) : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.ck);fprintf('])\n');
                end
                obj.ck=doubleIn;
            end
        end
        function set.nuSVR(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nuSVR~=doubleIn)
                    fprintf(' >>> Parameter for nu-SVR : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.nuSVR);fprintf('])\n');
                end
                obj.nuSVR=doubleIn;
            end
        end
        function set.nuGSVR(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nuGSVR~=doubleIn)
                    fprintf(' >>> Parameter for nu-GSVR : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.nuGSVR);fprintf('])\n');
                end
                obj.nuGSVR=doubleIn;
            end
        end
        function set.estim(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.estim,boolIn)
                    fprintf(' >>> Estimation of the hyperparameters : ');
                    SwitchOnOff(boolIn);
                end
                obj.estim=boolIn;
            end
        end
        function set.aniso(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.aniso,boolIn)
                    fprintf(' >>> anisotropic model : ');
                    SwitchOnOff(boolIn);
                end
                obj.aniso=boolIn;
            end
        end
        function set.dispEstim(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispEstim,boolIn)
                    fprintf(' >>> Show estimation process : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispEstim=boolIn;
            end
        end
        function set.saveEstim(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.saveEstim,boolIn)
                    fprintf(' >>> Save function used for finding hyperparameters : ');
                    SwitchOnOff(boolIn);
                end
                obj.saveEstim=boolIn;
            end
        end
        function set.dispIterGraph(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispIterGraph,boolIn)
                    fprintf(' >>> Plot iterations estimation process : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispIterGraph=boolIn;
            end
        end
        function set.dispIterCmd(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispIterCmd,boolIn)
                    fprintf(' >>> Display iterations in command windows : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispIterCmd=boolIn;
            end
        end
        function set.dispPlotAlgo(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.dispPlotAlgo,boolIn)
                    fprintf(' >>> Plot convergence information on figures : ');
                    SwitchOnOff(boolIn);
                end
                obj.dispPlotAlgo=boolIn;
            end
        end
        method='pso';       % optimizer used for finding internal parameter
        sampManu='IHS';     % method used for the initial sampling for GA ('', 'LHS','IHS'...)
        function set.sampManuOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.sampManuOn,boolIn)
                    fprintf(' >>> Plot convergence information on figures : ');
                    SwitchOnOff(boolIn);
                end
                obj.sampManuOn=boolIn;
            end
        end
        function set.nbSampInit(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nbSampInit~=doubleIn)
                    fprintf(' >>> Number of sample points for GA, PSO : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.nbSampInit);fprintf('])\n');
                end
                obj.nbSampInit=doubleIn;
            end
        end
                function set.critOpti(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nbSampInit~=doubleIn)
                    fprintf(' >>> Stopping criterion for estimation process : [');
                    fprintf('%i ',doubleIn);fprintf('] ');
                    fprintf('(previous [');fprintf('%d ',obj.critOpti);fprintf('])\n');
                end
                obj.critOpti=doubleIn;
            end
                end
        function set.kern(obj,charIn)
            if isG(charIn,'char')
                if ismember(charIn,obj.kernAvail)
                    if strcmp(obj.kern,charIn)
                        fprintf(' >>> Kernel function : %s (previous %s)',charIn,obj.kern);
                    end
                    obj.kern=charIn;
                else
                    fprintf(' Kernel function %s not available\n',charIn);
                    availableKern(obj);
                end
            end
        end
function set.normOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.normOn,boolIn)
                    fprintf(' >>> Normalization of the data : ');
                    SwitchOnOff(boolIn);
                end
                obj.normOn=boolIn;
            end
end
        function set.recond(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.recond,boolIn)
                    fprintf(' >>> Improve condition number of matrices (KRG, RBF...) : ');
                    SwitchOnOff(boolIn);
                end
                obj.recond=boolIn;
            end
        end
                function set.cvOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.cvOn,boolIn)
                    fprintf(' >>> Cross-validation : ');
                    SwitchOnOff(boolIn);
                end
                obj.cvOn=boolIn;
            end
                end
                        function set.cvFull(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.cvFull,boolIn)
                    fprintf(' >>> All CV criteria : ');
                    SwitchOnOff(boolIn);
                end
                obj.cvFull=boolIn;
            end
        end
        
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        normOn=true;        %normalization
        recond=true;        %improve condition number of matrix (kriging, RBF, SVR...)
        cvOn=true;          %cross-validation
        cvFull=false;       %compute all CV criteria
        cvDisp=false;       %display QQ plot CV
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% infill strategy
        infillOn=false;     %activate/desactivate computation of the infill criterion
        infillParaWEI=0.5;  %parameters for Weighted Expected Improvement
        infillParaGEI=1;    %parameters for Generalized Expected Improvement   
        infillParaLCB=0.5;  %parameters for Lower Confidence Bound 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Check interpolation
        checkInterp=true;   %activate/deactivate the checking of the interpolation property
        %
        function set.d2(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.d2,boolIn)
                    fprintf(' >>> 2D display: ');
                    SwitchOnOff(boolIn);
                end
                obj.d2=boolIn;
            end
        end
        %
        function set.contour(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.contour,boolIn)
                    fprintf(' >>> Display contour: ');
                    SwitchOnOff(boolIn);
                end
                obj.contour=boolIn;
            end
        end
        %
        function set.tikz(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.tikz,boolIn)
                    fprintf(' >>> Save display using tikz (matlab2tikz): ');
                    SwitchOnOff(boolIn);
                end
                obj.tikz=boolIn;
            end
        end
        %
        function set.save(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.save,boolIn)
                    fprintf(' >>> Save display using fig: ');
                    SwitchOnOff(boolIn);
                end
                obj.save=boolIn;
            end
        end
        %
        function set.directory(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.directory,charIn)
                    fprintf(' >>> Saving directory : %s (previous %s)',charIn,obj.directory);
                end
                obj.directory=charIn;
            end
        end
        %
        function set.gridGrad(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.gridGrad,boolIn)
                    fprintf(' >>> Show gradients on the grid: ');
                    SwitchOnOff(boolIn);
                end
                obj.gridGrad=boolIn;
            end
        end
        %
        function set.sampleGrad(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.sampleGrad,boolIn)
                    fprintf(' >>> Show gradients at the sample points: ');
                    SwitchOnOff(boolIn);
                end
                obj.sampleGrad=boolIn;
            end
        end
        %
        function set.ciOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.ciOn,boolIn)
                    fprintf(' >>> Show confidence intervals (if available): ');
                    SwitchOnOff(boolIn);
                end
                obj.ciOn=boolIn;
            end
        end
        %
        function set.ciType(obj,charIn)
            if isG(charIn,'char')
                if xor(obj.ciType,charIn)
                    fprintf(' >>> Type of confidence interval : %s (previous %s)',charIn,obj.ciType);
                end
                obj.ciType=charIn;
            end
        end
        %
        function set.newFig(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.newFig,boolIn)
                    fprintf(' >>> Show in new figure: ');
                    SwitchOnOff(boolIn);
                end
                obj.newFig=boolIn;
            end
        end
        %
        function set.opt(obj,charIn)
            if isG(charIn,'char')
                if xor(obj.opt,charIn)
                    fprintf(' >>> Plot options : %s (previous %s)',charIn,obj.opt);
                end
                obj.opt=charIn;
            end
        end
        %
        function set.xlabel(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.xlabel,charIn)
                    fprintf(' >>> X label : %s (previous %s)',charIn,obj.xlabel);
                end
                obj.xlabel=charIn;
            end
        end
        %
        function set.ylabel(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.ylabel,charIn)
                    fprintf(' >>> Y label : %s (previous %s)',charIn,obj.ylabel);
                end
                obj.ylabel=charIn;
            end
        end
        %
        function set.zlabel(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.zlabel,charIn)
                    fprintf(' >>> Z label : %s (previous %s)',charIn,obj.zlabel);
                end
                obj.zlabel=charIn;
            end
        end
        %
        function set.title(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.title,charIn)
                    fprintf(' >>> Z label : %s (previous %s)',charIn,obj.title);
                end
                obj.title=charIn;
            end
        end
        %
        function set.color(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.color,charIn)
                    fprintf(' >>> Color for uniform display : %s (previous %s)',charIn,obj.color);
                end
                obj.color=charIn;
            end
        end
        %
        function set.uni(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.uni,boolIn)
                    fprintf(' >>> Uniform color: ');
                    SwitchOnOff(boolIn);
                end
                obj.uni=boolIn;
            end
        end
        %
        function set.render(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.render,boolIn)
                    fprintf(' >>> 3D rendering: ');
                    SwitchOnOff(boolIn);
                end
                obj.render=boolIn;
            end
        end
        %
        function set.samplePts(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.samplePts,boolIn)
                    fprintf(' >>> Show sample points: ');
                    SwitchOnOff(boolIn);
                end
                obj.samplePts=boolIn;
            end
        end
        %
        function set.num(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.num~=doubleIn)
                    fprintf(' >>> Number of the plot: %d (previous %d)',doubleIn,obj.num);
                end
                obj.num=doubleIn;
            end
        end
        %
        function set.nbSteps(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nbSteps~=doubleIn)
                    fprintf(' >>> Number of steps of the reference grid: %d (previous %d)',doubleIn,obj.nbSteps);
                end
                obj.nbSteps=doubleIn;
            end
        end
        %
        function set.step(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.step~=doubleIn)
                    fprintf(' >>> Size of steps of the reference grid: %d (previous %d)',doubleIn,obj.step);
                end
                obj.step=doubleIn;
            end
        end
        %
        function set.nv(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nv~=doubleIn)
                    fprintf(' >>> Number of sample points of the reference grid: %d (previous %d)',doubleIn,obj.nv);
                end
                obj.nv=doubleIn;
            end
        end
        %
        function set.tex(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.tex,boolIn)
                    fprintf(' >>> Save data in TeX file: ');
                    SwitchOnOff(boolIn);
                end
                obj.tex=boolIn;
            end
        end
        %
        function set.bar(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.bar,boolIn)
                    fprintf(' >>> Use bar on plot: ');
                    SwitchOnOff(boolIn);
                end
                obj.bar=boolIn;
            end
        end
        %
        function set.trans(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.trans,boolIn)
                    fprintf(' >>> Transparency: ');
                    SwitchOnOff(boolIn);
                end
                obj.trans=boolIn;
            end
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
                                fprintf('>> Wrong keyword %s\n',keyW);
                            end
                        end
                    end
                end
                if ~okConf
                    fprintf(' Wrong syntax used for conf method\n')
                    fprintf('use: conf(''key1'',val1,''key2'',val2...)\n')
                    fprintf('List of the avilable keywords:\n');
                    dispTableTwoColumnsStruct(listProp,obj.infoProp);
                end
            else
                fprintf('Current configuration\n');
            end
        end
    end
end
    
% bounds of the space on which internal parameters are looked for
if meta.para.estim
    meta.para.l.min=1e-1;
    meta.para.l.max=100;
    meta.para.l.val=1;
    meta.para.p.max=2;
    meta.para.p.min=1.001;
    meta.para.p.val=2;
    meta.para.nu.min=1.5;
    meta.para.nu.max=5;
    meta.para.nu.val=3/2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function for declaring the purpose of each properties
function info=affectTxtProp()
info.scale='scale for displaying gradients';
info.tikz='save on tikz''s format';
info.on='enable/disable display';
info.d3='3D display';
info.d2='2D display';
info.contour='display contour';
info.save='save display';
info.directory='directory for saving figures';
info.gridGrad='display gradients at the points of the grid';
info.sampleGrad='display gradients at sample points';
info.ciOn='display confidence intervals (if available)';
info.ciType='choose CI to display';
info.newFig='display in new figure';
info.opt='plot options';
info.uni='use uniform color';
info.color='choose display color';
info.xlabel='X-axis label';
info.ylabel='Y-axis label';
info.zlabel='Z-axis label';
info.title='title of the figure';
info.render='enable/disable 3D rendering';
info.samplePts='display sample points';
info.num='number of the display numérotation affichage';
info.tex='save data in TeX file';
info.bar='display using bar';
info.trans='display using transparency';
info.nv='number of sample points on the reference grid';
info.nbSteps='number of steps on the reference grid';
info.step='size of the step of the grid';
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
    fprintf('%s%s%s\n',tableFiedIn{itT},spaceTxt(ones(1,spaceA(itT))),structIn.(tableFiedIn{itT}));
end
end

%function for checking type a variable and display erro message
function okG=isG(varIn,typeIn)
okG=isa(varIn,typeIn);
if ~okG;fprintf(' Wrong input variable. Required: %s (current: %s)\n',typeIn,class(varIn));end
end

%display change of state
function SwitchOnOff(boolIn)
if boolIn;
    fprintf(' On (previous Off)\n');
else
    fprintf(' Off (previous On)\n');
end
end


function meta=initMeta(in,parallelOn)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% chargement configuration particuliere
if nargin==0
    in=[];
end
%taking gradients into account
if isfield(in,'useGrad');meta.useGrad=in.useGrad;end
%type of surrgate model KRG/GKRG/DACE/RBF/GRBF/SVR/GSVR...
if isfield(in,'type');meta.type=in.type;end
%parameter of the kernel function
if isfield(in,'para')
    if isfield(in.para,'long');meta.para.l.val=in.para.long;end
    if meta.para.estim
        if isfield(in,'long');
            meta.para.l.max=in.para.long(2);
            meta.para.l.min=in.para.long(1);
        end
    end
    if isfield(in.para,'pow');meta.para.p.val=in.para.pow;end
    if meta.para.estim
        if isfield(in,'pow');
            meta.para.p.max=in.para.pow(2);
            meta.para.p.min=in.para.pow(1);
        end
    end
    if isfield(in.para,'nu');meta.para.nu.val=in.para.nu;end
    if meta.para.estim
        if isfield(in,'nu');
            meta.para.nu.max=in.para.nu(2);
            meta.para.nu.min=in.para.nu(1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% depending on the type of surrogate model
switch meta.type
    case 'SWF'
        if isfield(in,'swf_para');meta.swf_para=in.swf_para;else meta.swf_para=swf_para;end
    case 'DACE'
        fctp='regpoly';
        %regression function
        if isfield(in,'polyOrder');meta.regr=[fctp num2str(in.polyOrder,'%d')];else meta.regr=[fctp num2str(meta.polyOrder,'%d')];end
        %correlation function
        if isfield(in,'corr');meta.corr=['corr' in.corr];else meta.corr=corr;end
    case {'RBF','GRBF','InRBF'}
        if isfield(in,'kern');meta.kern=in.kern;end
    case {'KRG','GKRG','InKRG','SVR','GSVR'}
        %order of the polynomial basis used for regression
        if isfield(in,'polyOrder');meta.polyOrder=in.polyOrder;end; 
        %kernel function
        if isfield(in,'kern');meta.kern=in.kern;end
        
    otherwise
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if isfield(in,'normOn');meta.normOn=in.normOn;end
%improve condition number of the matrix
if isfield(in,'recond');meta.recond=in.recond;end
%cross-validation
if isfield(in,'cv');meta.cv=in.cv;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% estimation parametre long (longueur de correlation)
if isfield(in,'para');
    % seek for best values of the internal parameters
    if isfield(in.para,'estim');meta.para.estim=in.para.estim;end
    % anisotropic model (one internal length per variable)
    if isfield(in.para,'aniso');meta.para.aniso=in.para.aniso;end
    % display objective function to be minimised
    if isfield(in.para,'dispEstim');meta.para.dispEstim=in.para.dispEstim;end
    % display iterations of the optimisation process on a figure (1D/2D)
    if isfield(in.para,'dispIterGraph');meta.para.dispIterGraph=in.para.dispIterGraph;end
    % display iteration in the console
    if isfield(in.para,'dispIterCmd');meta.para.dispIterCmd=in.para.dispIterCmd;end
    % display convergence information on figures
    if isfield(in.para,'dispPlotAlgo');meta.para.dispPlotAlgo=in.para.dispPlotAlgo;end
    % optimizer used for finding internal parameter
    if isfield(in.para,'method');meta.para.method=in.para.method;end
    % method used for the initial sampling for GA ('', 'LHS','IHS'...)
    if isfield(in.para,'popManu');meta.para.popManu=in.para.popManu;end
   % number of sample points of the initial sampling for GA
    if isfield(in.para,'norpopInitm');meta.para.popInit=in.para.popInit;end
    % Value of the stopping criterion of the optimizer
    if isfield(in.para,'critOpti');meta.para.critOpti=in.para.critOpti;end
    if meta.para.estim
        if isfield(in.para,'long');
            meta.para.l.max=in.para.long(2);
            meta.para.l.min=in.para.long(1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% infill strategy 
if isfield(in,'infill');
    if isfield(in.infill,'on');meta.infill.on=in.infill.on;end
    if isfield(in.infill,'para_wei');meta.infill.para_wei=in.infill.para_wei;end
    if isfield(in.infill,'para_gei');meta.infill.para_gei=in.infill.para_gei;end
    if isfield(in.infill,'para_lcb');meta.infill.para_lcb=in.infill.para_lcb;end
    
    % check interpolation
    if isfield(in,'check');meta.check=in.check;end
end


