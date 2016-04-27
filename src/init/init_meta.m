%% Initialization of the surrogate model
%% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function meta=init_meta(in)

fprintf('=========================================\n')
fprintf('  >>> INITIALIZATION Surrogate Model \n');
[tMesu,tInit]=mesuTime;

%% default configuration
%taking into account gradients
meta.grad=false;
%type of surrogate model
meta.type='KRG';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% internal parameters
%length 
meta.para.l_val=1;
%power
meta.para.p_val=2;
%smoothness
meta.para.nu_val=0.6;
%order polynomial 
meta.para.polyorder=0;
%parameter for SWF
swf_para=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% kernel function
meta.kern='matern32';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalization
meta.norm=true;
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
meta.para.disp_estim=false;
% display iterations of the optimisation process on a figure (1D/2D)
meta.para.disp_iter_graph=false;
% display iteration in the console
meta.para.disp_iter_cmd=false;
% display convergence information on figures
meta.para.disp_plot_algo=false;
% optimizer used for finding internal parameter
meta.para.method='pso';
% method used for the initial sampling for GA ('', 'LHS','IHS'...)
meta.para.sampManu='IHS';
% number of sample points of the initial sampling for GA
meta.para.nbSampInit=[];
% Value of the stopping criterion of the optimizer
meta.para.crit_opti=10^-6;
% bounds of the space on which internal parameters are looked for
if meta.para.estim
    meta.para.l.min=1e-4;
    meta.para.l.max=50;
    meta.para.p.max=2;
    meta.para.p.min=1.001;
    meta.para.nu.min=1e-3;
    meta.para.nu.min=5;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% infill strategy 
meta.infill.on=false;
meta.infill.para_wei=0.5;
meta.infill.para_gei=1;
meta.infill.para_lcb=0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check interpolation
meta.verif=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% chargement configuration particuliere
if nargin==0
    in=[];
end
%taking gradients into account
if isfield(in,'grad');meta.grad=in.grad;end
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
        if isfield(in,'para');if isfield(in.para,'polyorder');meta.regr=[fctp num2str(in.polyorder,'%d')];else meta.regr=[fctp num2str(meta.para.polyorder,'%d')];end;end
        %correlation function
        if isfield(in,'corr');meta.corr=['corr' in.corr];else meta.corr=corr;end
    case {'RBF','GRBF','InRBF'}
        if isfield(in,'kern');meta.kern=in.kern;end
    case {'KRG','GKRG','InKRG','SVR','GSVR'}
        %order of the polynomial basis used for regression
        if isfield(in,'para');if isfield(in.para,'polyorder');meta.para.polyorder=in.para.polyorder;end; end
        %kernel function
        if isfield(in,'kern');meta.kern=in.kern;end
        
    otherwise
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if isfield(in,'norm');meta.norm=in.norm;end
%improve condition number of the matrix
if isfield(in,'recond');meta.recond=in.recond;end
%cross-validation
if isfield(in,'cv');meta.cv=in.cv;end
%compute all CV criteria
if isfield(in,'cv_full');meta.cv.full=in.cv.full;end
%display QQ plot CV
if isfield(in,'cv_disp');meta.cv.disp=in.cv.disp;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% estimation parametre long (longueur de correlation)
if isfield(in,'para');
    % seek for best values of the internal parameters
    if isfield(in.para,'estim');meta.para.estim=in.para.estim;end
    % anisotropic model (one internal length per variable)
    if isfield(in.para,'aniso');meta.para.aniso=in.para.aniso;end
    % display objective function to be minimised
    if isfield(in.para,'disp_estim');meta.para.disp_estim=in.para.disp_estim;end
    % display iterations of the optimisation process on a figure (1D/2D)
    if isfield(in.para,'disp_iter_graph');meta.para.disp_iter_graph=in.para.disp_iter_graph;end
    % display iteration in the console
    if isfield(in.para,'disp_iter_cmd');meta.para.disp_iter_cmd=in.para.disp_iter_cmd;end
    % display convergence information on figures
    if isfield(in.para,'disp_plot_algo');meta.para.disp_plot_algo=in.para.disp_plot_algo;end
    % optimizer used for finding internal parameter
    if isfield(in.para,'method');meta.para.method=in.para.method;end
    % method used for the initial sampling for GA ('', 'LHS','IHS'...)
    if isfield(in.para,'popManu');meta.para.popManu=in.para.popManu;end
   % number of sample points of the initial sampling for GA
    if isfield(in.para,'norpopInitm');meta.para.popInit=in.para.popInit;end
    % Value of the stopping criterion of the optimizer
    if isfield(in.para,'crit_opti');meta.para.crit_opti=in.para.crit_opti;end
    if meta.para.estim
        if isfield(in.para,'long');
            meta.para.l.max=in.para.long(2);
            meta.para.l.min=in.para.long(1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% infill strategy 
if isfield(in,'enrich');
    if isfield(in.enrich,'on');meta.enrich.on=in.enrich.on;end
    if isfield(in.enrich,'para_wei');meta.enrich.para_wei=in.enrich.para_wei;end
    if isfield(in.enrich,'para_gei');meta.enrich.para_gei=in.enrich.para_gei;end
    if isfield(in.enrich,'para_lcb');meta.enrich.para_lcb=in.enrich.para_lcb;end
    
    % check interpolation
    if isfield(in,'verif');meta.verif=in.verif;end
end

if usejava('jvm')
    %count number of available workers (for parallelism)
    def_parallel=parcluster;
    meta.worker_parallel=def_parallel.NumWorkers;
else
    meta.worker_parallel=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mesuTime(tMesu,tInit);
fprintf('=========================================\n')