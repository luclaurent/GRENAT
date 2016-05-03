% Example of use of GRENAT without the sampling toolbox
% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

initDirGRENAT();
customClean;

%display the date
dispDate;

%initialization of display variables
aff=initDisp();

fprintf('++++++++++++++++++++++++++++++++++++++++++\n')
fprintf('  >>>   Building surrogate model    <<<\n');
[tMesu,tInit]=mesuTime;

%parallel execution (options and starting of the workers)
parallel.on=false;
parallel.workers='auto';
execParallel('start',parallel);

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
gridRef=C.ref.grid;
%responses at the grid points
respRef=C.ref.resp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load surrogate model parameters
meta=initMeta;
meta.type='RBF';
meta.cv.disp=true;
meta.para.estim=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%building of the surrogate model
[approx]=BuildMeta(sampling,resp,grad,meta);
%evaluation of the surrogate model at the grid points
[K]=EvalMeta(gridRef,approx,meta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of the confidence intervals
if isfield(K,'var');[ci68,ci95,ci99]=BuildCI(K.Z,K.var);end
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
displaySurrogate(gridRef,eval_ref,sampling,resp,grad,aff);
subplot(2,3,2)
aff.titre='Approximate function';
displaySurrogate(gridRef,K.Z,sampling,resp,grad,aff);
subplot(2,3,4)
aff.title='';
aff.render=false;
aff.d3=false;
aff.d2=true;
aff.contour=true;
aff.grad_eval=true;
ref.Z=eval_ref;
displaySurrogate(gridRef,ref,sampling,resp,grad,aff);
subplot(2,3,5)
displaySurrogate(gridRef,K,sampling,resp,grad,aff);
subplot(2,3,3)
aff.d3=true;
aff.d2=false;
aff.contour=false;
aff.grad_eval=false;
aff.render=true;
aff.title='Variance';
displaySurrogate(gridRef,K.var,sampling,resp,grad,aff);
subplot(2,3,6)
aff.titre='I95% confidence interval';
aff.trans=true;
aff.uni=true;
displaySurrogateIC(gridRef,ci95,aff,K.Z);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Computation and display of the errors
err=critErrDisp(K.Z,respRef,approx);
fprintf('=====================================\n');
fprintf('=====================================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Stop workers
execParallel('stop',parallel)

mesuTime(tMesu,tInit);
