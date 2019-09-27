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
testFun=optiGTest('Custom02');
Fx = @(x) 0.002201370*x.^10 - 0.1052876*x.^9 + 2.151650*x.^8 - ...
        24.60697*x.^7 + 173.4160*x.^6 - 782.1379*x.^5 +...
        2267.874*x.^4 -4114.980*x.^3 + 4357.030*x.^2 -...
        2327.900*x + 550 ;
%%Load of a set of 1D data
%sampling points
sampling=[0.6 1.5 3 5.2 6.5 8 10]';
%responses and gradients at sample points
[resp,grad]=testFun.evalObj(sampling);
resp=Fx(sampling);
%%for displaying and comparing with the actual function
%regular grid
gridRef=linspace(0,10,300)';
%responses at the grid points
[respRef,gradRef]=testFun.evalObj(gridRef);
respRef=Fx(gridRef);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create GRENAT Object
metaGRENAT=GRENAT('KRG',sampling,resp,grad);
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
metaGRENAT.confMeta.conf('polyOrder',0)
metaGRENAT.confMeta.conf('estimOn',false)
metaGRENAT.confMeta.conf('normOn',true)
metaGRENAT.confMeta.conf('recond',false)
metaGRENAT.confMeta.conf('lVal',0.6173);
metaGRENAT.confMeta.conf('typeEstim','logli')
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
%paraCluster.stop();

