%% Example of use of the GRENAToolbox with the MultiDOE one
% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

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


%load folder structure
initDirGRENAT;
%customClean;
countTime=mesuTime;
%parallel execution (options and starting of the workers)
paraCluster=execParallel(false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define the sampling using MultiDOE toolbox
dimPB=2; %number of design parameters
ns=20; %number if sample points
typeDOE='LHS'; %type of DOE
testFunction='Mystery'; %test function
%
mDOE=multiDOE(dimPB,typeDOE,ns,[],[],testFunction);
%mDOE.show;
%
samplePts=mDOE.sorted;
%
%evaluate function at sample points
[resp,grad]=evalFunGrad(mDOE.funTest,samplePts,'eval');
%Data for plotting functions
[gridRef]=buildDisp(mDOE,initNbPts(mDOE.dimPB));
[respRef,gradRef]=evalFunGrad(mDOE.funTest,gridRef,'disp');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create GRENAT Object
metaGRENAT=GRENAT('GKRG',samplePts,resp,grad);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%building of the surrogate model
metaGRENAT.train;
%define the reference (optional)
metaGRENAT.defineRef(gridRef,respRef,gradRef);
%evaluation of the surrogate model at the grid points
metaGRENAT.eval(gridRef);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%display the result
metaGRENAT.show;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute display error
metaGRENAT.errCalc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Stop workers
paraCluster.stop();

countTime.stop();

% 
% %%%%%%%%%%%%%%%%%%%%%
% 
% initDirGRENAT();
% customClean;
% 
% %display the date
% dispDate;
% 
% %initialization of display variables
% dispData=initDisp();
% 
% 
% fprintf('++++++++++++++++++++++++++++++++++++++++++\n')
% fprintf('  >>>   Building surrogate model    <<<\n');
% [tMesu,tInit]=mesuTime;
% 
% %parallel execution (options and starting of the workers)
% parallelStatus.on=false;
% parallelStatus.workers='auto';
% execParallel('start',parallelStatus);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %studied function
% funTEST='Manu';
% %Beale(2),Bohachevky1/2/3(2),Booth(2),Branin(2),Coleville(4)
% %Dixon(n),Gold(2),Michalewicz(n),mystery(2),Peaks(2),Rosenbrock(n)
% %Sixhump(2),Schwefel(n),Sphere(n),SumsSuare(n),AHE(n),Cst(n),Dejong(n)
% %rastrigin(n),RHE(n)
% % dimension du pb (nb de variables)
% dimPB=1;
% %esp=[0 15];
% esp=[];
% %%Definition of the design space
% [doe]=initDOE(dimPB,esp,funTEST);
% %number of steps per dimensions (for plotting)
% dispData.nbSteps=initNbPts(doe.dimPB);%max([3 floor((30^2)^(1/doe.dim_pb))]);
% %kind of sampling
% doe.type='IHS_manu';
% %number of sample points
% doe.ns=5;
% %execute sampling
% sampling=buildDOE(doe);
% samplePts=sampling.sorted;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %load parameters of the surrogate model
% data.type='GSVR';
% data.kern='matern32';
% metaData=initMeta(data);
% metaData.cv.disp=true;
% metaData.para.estim=0;
% metaData.para.l.val=[0.1439];% 0.0711];
% metaData.para.dispEstim=false;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%building of the surrogate model
% [approx]=BuildMeta(samplePts,eval,grad,metaData);
% %evaluation of the surrogate model at the grid points
% [K]=EvalMeta(gridRef,approx);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %computation of the confidence intervals
% if isfield(K,'var');[ci68,ci95,ci99]=BuildCI(K.Z,K.var);end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%display
% %defaults parameters
% dispData.on=true;
% dispData.newFig=false;
% dispData.ci.on=true;% display confidence intervals
% dispData.render=true;
% dispData.d3=true;
% dispData.xlabel='x_1';
% dispData.ylabel='x_2';
% 
% figure
% subplot(2,3,1)
% dispData.title='Reference function';
% displaySurrogate(gridRef,respRef,samplePts,eval,grad,dispData);
% subplot(2,3,2)
% dispData.title='Approximate function';
% displaySurrogate(gridRef,K.Z,samplePts,eval,grad,dispData);
% subplot(2,3,4)
% dispData.title='';
% dispData.render=false;
% dispData.d3=false;
% dispData.d2=true;
% dispData.contour=true;
% dispData.gridGrad=true;
% dispData.sampleGrad=true;
% ref.Z=respRef;ref.GZ=gradRef;
% displaySurrogate(gridRef,ref,samplePts,eval,grad,dispData);
% subplot(2,3,5)
% displaySurrogate(gridRef,K,samplePts,eval,grad,dispData);
% subplot(2,3,3)
% dispData.d3=true;
% dispData.d2=false;
% dispData.contour=false;
% dispData.gridGrad=false;
% dispData.sampleGrad=false;
% dispData.samplePts=false;
% dispData.render=true;
% dispData.title='Variance';
% displaySurrogate(gridRef,K.var,samplePts,eval,grad,dispData);
% subplot(2,3,6)
% dispData.title='Confidence intervals at 95%';
% dispData.trans=true;
% dispData.uni=true;
%  displaySurrogateCI(gridRef,ci95,dispData,K.Z);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%Computation and display of the errors
% err=critErrDisp(K.Z,respRef,approx);
% fprintf('=====================================\n');
% fprintf('=====================================\n');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %stop workers
% execParallel('stop',parallelStatus);
% 
% mesuTime(tMesu,tInit);
