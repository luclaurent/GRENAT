% Example of use of GRENAT without the sampling toolbox
% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

initDirGRENAT();
customClean;

%display the date
dispDate;

%initialization of display variables
dispData=initDisp();

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
metaData=initMeta;
metaData.type='KRG';
metaData.kern='matern32';
metaData.cv.disp=true;
metaData.para.estim=false;
metaData.normOn=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%building of the surrogate model
[approx]=BuildMeta(sampling,resp,grad,metaData);
%evaluation of the surrogate model at the grid points
[K]=EvalMeta(gridRef,approx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of the confidence intervals
if isfield(K,'var');[ci68,ci95,ci99]=BuildCI(K.Z,K.var);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display
% default values
dispData.on=true;
dispData.newFig=false;
dispData.ci.on=true; % display confidence intervals
dispData.render=false;
dispData.d3=true;
dispData.samplePts=true;
dispData.xlabel='x_1';
dispData.ylabel='x_2';

figure
subplot(2,3,1)
dispData.title='Reference function';
displaySurrogate(gridRef,respRef,sampling,resp,grad,dispData);
subplot(2,3,2)
dispData.title='Approximate function';
displaySurrogate(gridRef,K.Z,sampling,resp,grad,dispData);
subplot(2,3,4)
dispData.title='';
dispData.render=false;
dispData.d3=false;
dispData.d2=true;
dispData.contour=true;
dispData.gridGrad=true;
ref.Z=respRef;
displaySurrogate(gridRef,ref,sampling,resp,grad,dispData);
subplot(2,3,5)
displaySurrogate(gridRef,K,sampling,resp,grad,dispData);
subplot(2,3,3)
dispData.d3=true;
dispData.d2=false;
dispData.contour=false;
dispData.gridGrad=false;
dispData.render=false;
dispData.title='Variance';
dispData.samplePts=false;
displaySurrogate(gridRef,K.var,sampling,resp,grad,dispData);
subplot(2,3,6)
dispData.title='95% confidence interval';
dispData.trans=true;
dispData.uni=true;
displaySurrogateCI(gridRef,ci95,dispData,K.Z);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Computation and display of the errors
err=critErrDisp(K.Z,respRef,approx.build);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Stop workers
execParallel('stop',parallel);

mesuTime(tMesu,tInit);
