% Example of use of GRENAT without the sampling toolbox
% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

initDirGRENAT();
clean;

%display the date
disp_date;

%initialization of display variables
aff=init_aff();

fprintf('++++++++++++++++++++++++++++++++++++++++++\n')
fprintf('  >>>   Building surrogate model    <<<\n');
[tMesu,tInit]=mesu_time;

%parallel execution (options and starting of the workers)
parallel.on=false;
parallel.workers='auto';
exec_parallel('start',parallel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Load of a set of 2D data
C=load('src/various/example_doe.mat');
%sampling points
sampling=C.samples.sampling;
%responses at sample points
resp=C.samples.resp;
%gradients at sample points
grad=C.samples.grad;

%%for displaying and comparing with the actual function
%regular grid
grid_ref=C.ref.grid;
%responses at the grid points
resp_ref=C.ref.resp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load surrogate model parameters
meta=init_meta;
meta.type='CKRG';
meta.cv_aff=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%building of the surrogate model
[approx]=BuidMeta(tirages,resp,grad,meta);
%evaluation of the surrogate model at the grid points
[K]=EvalMeta(grid_ref,approx,meta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of the confidence intervals
if isfield(K,'var');[ci68,ci95,ci99]=const_ci(K.Z,K.var);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display
% default values
aff.on=true;
aff.newfig=false;
aff.ci.on=true;
% display confidence intervals
aff.render=true;
aff.d3=true;
aff.xlabel='x_1';
aff.ylabel='x_2';

figure
subplot(2,3,1)
aff.titre='Reference function';
displaySurrogate(grid_ref,eval_ref,sampling,resp,grad,aff);
subplot(2,3,2)
aff.titre='Approximate function';
displaySurrogate(grid_ref,K.Z,sampling,resp,grad,aff);
subplot(2,3,4)
aff.title='';
aff.render=false;
aff.d3=false;
aff.d2=true;
aff.contour=true;
aff.grad_eval=true;
ref.Z=eval_ref;
displaySurrogate(grid_ref,ref,sampling,resp,grad,aff);
subplot(2,3,5)
displaySurrogate(grid_ref,K,sampling,resp,grad,aff);
subplot(2,3,3)
aff.d3=true;
aff.d2=false;
aff.contour=false;
aff.grad_eval=false;
aff.render=true;
aff.title='Variance';
displaySurrogate(grid_ref,K.var,sampling,resp,grad,aff);
subplot(2,3,6)
aff.titre='I95% confidence interval';
aff.trans=true;
aff.uni=true;
displaySurrogateIC(grid_ref,ci95,aff,K.Z);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Computation and display of the errors
err=crit_err(K.Z,eval_ref,approx);
fprintf('=====================================\n');
fprintf('=====================================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Stop workers
exec_parallel('stop',parallel)

mesu_time(tMesu,tInit);
