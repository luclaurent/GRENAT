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

function meta=initMeta(in,parallelOn)

if nargin<=1
    parallelOn=false;
end

fprintf('=========================================\n')
fprintf('  >>> INITIALIZATION Surrogate Model \n');
[tMesu,tInit]=mesuTime;

%% default configuration
%taking into account gradients
meta.useGrad=false;
%type of surrogate model
meta.type='KRG';
%Taylor's step for indirect gradient-based
meta.para.stepTaylor=10^-2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% internal parameters
%length 
meta.para.l_val=1;
%power
meta.para.p_val=2;
%smoothness
meta.para.nu_val=0.6;
%order polynomial 
meta.polyOrder=1;
%parameter for SWF
swf_para=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% internal parameters for SVR/GSVR
meta.para.e0=1e-2; %thickness of the tube (not used for nu-SVR)
meta.para.ek=1e-2; %thickness of the tube of gradient (not used for nu-SVR)
%constant for trade off between flatness of the function and the amount up to 
%which deviations larger to e0 are tolerated
meta.para.c0=1e6;
%same trade off constant as before 
meta.para.ck=1e6;
%parameter of the nu-SVR/nu-GSVR (nu in [0,1])
meta.para.nuSVR=0.6; 
meta.para.nuGSVR=0.6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% kernel function
meta.kern='matern32';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalization
meta.normOn=true;
%improve condition number of matrix (kriging, RBF, SVR...)
meta.recond=true;
%cross-validation
meta.cv.on=true;
%compute all CV criteria
meta.cv.full=false;
%display QQ plot CV
meta.cv.disp=false;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% internal parameters estimation
% seek for best values of the internal parameters
meta.para.estim=true;
% anisotropic model (one internal length per variable)
meta.para.aniso=true;
% display objective function to be minimised
meta.para.dispEstim=false;
%save evolution function to be minimized
meta.para.save=false;
% display iterations of the optimisation process on a figure (1D/2D)
meta.para.dispIterGraph=false;
% display iteration in the console
meta.para.dispIterCmd=false;
% display convergence information on figures
meta.para.dispPlotAlgo=false;
% optimizer used for finding internal parameter
meta.para.method='pso';
% initial sampling or not
meta.para.sampManuOn=0;
% method used for the initial sampling for GA ('', 'LHS','IHS'...)
meta.para.sampManu='IHS';
% number of sample points of the initial sampling for GA
meta.para.nbSampInit=[];
% Value of the stopping criterion of the optimizer
meta.para.critOpti=10^-6;
% bounds of the space on which internal parameters are looked for
if meta.para.estim
    meta.para.l.min=1e-1;
    meta.para.l.max=30;
    meta.para.l.val=1;
    meta.para.p.max=2;
    meta.para.p.min=1.001;
    meta.para.p.val=2;
    meta.para.nu.min=1.5;
    meta.para.nu.max=5;
    meta.para.nu.val=3/2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% infill strategy 
meta.infill.on=false;
meta.infill.paraWEI=0.5;
meta.infill.paraGEI=1;
meta.infill.paraLCB=0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check interpolation
meta.check=true;

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

if usejava('jvm')&&parallelOn
    %count number of available workers (for parallelism)
    def_parallel=parcluster;
    meta.NumWorkers=def_parallel.NumWorkers;
else
    meta.NumWorkers=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mesuTime(tMesu,tInit);
fprintf('=========================================\n')