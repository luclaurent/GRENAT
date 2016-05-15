% Example of use of the GRENAToolbox with the LMTir one
% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

initDirGRENAT([],'LMTir');
clean;

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
%studied function
funTEST='mystery';
%beale(2),bohachevky1/2/3(2),booth(2),branin(2),coleville(4)
%dixon(n),gold(2),michalewicz(n),mystery(2),peaks(2),rosenbrock(n)
%sixhump(2),schwefel(n),sphere(n),sumsquare(n),AHE(n),cste(n),dejong(n)
%rastrigin(n),RHE(n)
% dimension du pb (nb de variables)
dimPB=2;
%esp=[0 15];
esp=[];
%%Definition of the design space
[doe]=initDOE(dimPB,esp,funTEST);
%number of steps per dimensions (for plotting)
dispData.nbSteps=initNbSteps(doe.dimPB);%max([3 floor((30^2)^(1/doe.dim_pb))]);
%kind of sampling
doe.type='IHS';
%number of sample points
doe.ns=35;
%execute sampling
sampling=BuildDOE(doe);
samplePts=sampling.sorted;
%evaluate function at sample points
[eval,grad]=buildResp(doe.fct,samplePts,'eval');
%Data for plotting functions
[gridRef,dispData]=gene_aff(doe,dispData);
[respRef,gradRef]=buildResp(doe.funTest,gridRef,'aff');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load parameters of the surrogate model
data.type='GRBF';
data.rbf='matern32';
metaData=initMeta(data);
metaData.cv.disp=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%building of the surrogate model
[approx]=BuildMeta(samplePts,eval,grad,metaData);
%evaluation of the surrogate model at the grid points
[K]=EvalMeta(gridRef,approx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of the confidence intervals
if isfield(K,'var');[ci68,ci95,ci99]=BuildCI(K.Z,K.var);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%display
%defaults parameters
dispData.on=true;
dispData.newFig=false;
dispData.ci.on=true;% display confidence intervals
dispData.render=true;
dispData.d3=true;
dispData.xlabel='x_1';
dispData.ylabel='x_2';

figure
subplot(2,3,1)
dispData.titre='Reference function';
displaySurrogate(gridRef,respRef,samplePts,eval,grad,dispData);
subplot(2,3,2)
dispData.titre='Approximate function';
displaySurrogate(gridRef,K.Z,samplePts,eval,grad,dispData);
subplot(2,3,4)
dispData.title='';
dispData.render=false;
dispData.d3=false;
dispData.d2=true;
dispData.contour=true;
dispData.gridGrad=true;
dispData.sampleGrad=true;
ref.Z=respRef;ref.GZ=gradRef;
displaySurrogate(gridRef,ref,samplePts,eval,grad,dispData);
subplot(2,3,5)
displaySurrogate(gridRef,K,samplePts,eval,grad,dispData);
subplot(2,3,3)
dispData.d3=true;
dispData.d2=false;
dispData.contour=false;
dispData.gridGrad=false;
dispData.sampleGrad=false;
dispData.render=true;
dispData.title='Variance';
displaySurrogate(gridRef,K.var,samplePts,eval,grad,dispData);
subplot(2,3,6)
dispData.title='Confidence intervals at 95%';
dispData.trans=true;
dispData.uni=true;
 displaySurrogateCI(gridRef,ic95,dispData,K.Z);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Computation and display of the errors
err=critErrDisp(K.Z,respRef,approx);
fprintf('=====================================\n');
fprintf('=====================================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stop workers
execParallel('stop',parallel)

mesuTime(tMesu,tInit);
