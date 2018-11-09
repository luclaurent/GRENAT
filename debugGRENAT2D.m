% Example of use of GRENAT without the sampling toolbox
% L. LAURENT -- 16/05/2016 -- luc.laurent@lecnam.net

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

clear all

%load folder structure
initDirGRENAT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load test function
testFun=optiGTest('Branin1');%Rosenbrock % Branin1
%%Load of a set of 2D data
dimPB=2;
ns=20; %number if sample points
typeDOE='IHS'; %type of DOE
%
mDOE=multiDOE(dimPB,typeDOE,ns,testFun.xMin,testFun.xMax);
mDOE.show;
%
sampling=mDOE.unsorted;
% sampling=[%
%    -24   -15
%     15    24
%    -12    12
%     -6   -27
%     30     3
%     27    -9
%     21   -21
%     12    -3
%     -9    30
%      0    21
%     24    27
%     18    15
%      6     9
%    -27    18
%      9   -24
%    -21     6
%    -18   -18
%      3   -12
%    -15    -6
%     -3     0
%    ];
%
%evaluate function at sample points
[resp,~,grad]=testFun.evalObj(sampling);
%Data for plotting functions
[gridRef]=buildDisp(mDOE,initNbPts(mDOE.dimPB));
[respRef,gradRef]=testFun.evalObj(gridRef);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create GRENAT Object
metaGRENAT=GRENAT('SVR',sampling,resp,grad);
% 'cauchy','circular','constant',...
%             'cubicspline0','cubicspline1','cubicspline2',...
%             'expg','expo','invmultiqua','linear','linearspline',...
%             'logk','matern','matern32','matern52','multiqua','powerk',...
%             'quadraticspline','ratmultiqua','tstudent','thinplatespline',...
%             'spherical','sexp','wave','wavelet',...
%             'wendland10','wendland20','wendland21','wendland30',...
%             'wendland31','wendland32','wendland41','wendland42',...
%             'wendland52','wendland53'
metaGRENAT.confMeta.conf('kern','matern32')
%metaGRENAT.confMeta.conf('polyOrder',2)
metaGRENAT.confMeta.conf('estimOn',true)
metaGRENAT.confMeta.conf('lVal',[0.01 0.01]);%Branin1 [4.662201911444302e-01     2.644279506437699e-01])
%metaGRENAT.confMeta.conf('recond',false)
metaGRENAT.confMeta.conf('normOn',true)
metaGRENAT.confMeta.conf('aniso',true)
metaGRENAT.confMeta.conf('typeEstim','logli')
metaGRENAT.confMeta.conf('dispEstim',false)
metaGRENAT.confMeta.conf('method','pso')
%metaGRENAT.confMeta.conf('dispIterGraph',true)
%metaGRENAT.confMeta.conf('dispIterCmd',true)
%metaGRENAT.confMeta.conf('dispPlotAlgo',true)
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
metaGRENAT.show(gridRef);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute display error
metaGRENAT.errCalc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check interpolation
metaGRENAT.checkInterp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Stop workers
%paraCluster.stop();

