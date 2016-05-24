% Example of use of the GRENAToolbox with the LMTir one
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
parallelStatus.on=false;
parallelStatus.workers='auto';
execParallel('start',parallelStatus);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%studied function
funTEST='Mystery';
%Beale(2),Bohachevky1/2/3(2),Booth(2),Branin(2),Coleville(4)
%Dixon(n),Gold(2),Michalewicz(n),mystery(2),Peaks(2),Rosenbrock(n)
%Sixhump(2),Schwefel(n),Sphere(n),SumsSuare(n),AHE(n),Cst(n),Dejong(n)
%rastrigin(n),RHE(n)
% dimension du pb (nb de variables)
dimPB=2;
%esp=[0 15];
esp=[];
%%Definition of the design space
[doe]=initDOE(dimPB,esp,funTEST);
%number of steps per dimensions (for plotting)
dispData.nbSteps=initNbPts(doe.dimPB);%max([3 floor((30^2)^(1/doe.dim_pb))]);
%kind of sampling
doe.type='IHS';
%number of sample points
doe.ns=30;
%execute sampling
sampling=buildDOE(doe);
samplePts=sampling.sorted;
%samplePts=[
%      3.5000    2.5000
%     2.5000    3.5000
%     2.0000    2.0000
%     1.0000    3.0000
%     3.0000    5.0000
%     4.0000    1.0000
%     4.5000    4.5000
%     5.0000    4.0000
%     1.5000    0.5000
%     0.5000    1.5000
%     ];
%evaluate function at sample points
[eval,grad]=evalFunGrad(doe.funT,samplePts,'eval');
%Data for plotting functions
[gridRef,dispData]=buildDisp(doe,dispData);
[respRef,gradRef]=evalFunGrad(doe.funT,gridRef,'disp');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load parameters of the surrogate model
data.type='KRG';
data.kern='matern32';
metaData=initMeta(data);
metaData.cv.disp=true;
metaData.normOn=true;
metaData.para.estim=1;
metaData.para.dispEstim=1;
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
dispData.title='Reference function';
displaySurrogate(gridRef,respRef,samplePts,eval,grad,dispData);
subplot(2,3,2)
dispData.title='Approximate function';
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
 displaySurrogateCI(gridRef,ci95,dispData,K.Z);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Computation and display of the errors
err=critErrDisp(K.Z,respRef,approx);
fprintf('=====================================\n');
fprintf('=====================================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stop workers
execParallel('stop',parallelStatus);

mesuTime(tMesu,tInit);