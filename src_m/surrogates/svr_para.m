%analyse sensibilité des paramètres
%execution svr1D
clear all
close all
addpath('crit')
%%SVR test
aF=10;
bF=0;
cF=5;
nn=30;
%funTEST=@(x) exp(-x/aF).*cos(x)+1/aF*x+bF;
%dfunTEST=@(x) -exp(-x/aF).*(sin(x)+1/aF.*cos(x))+1/aF;
funTEST=@(x) (6.*x-2).^2.*sin(12.*x-4);%+randn(length(x),1);

nns=5;


XXX=linspace(0,1,nns)';
[XXXn,NIX]=norm_denorm(XXX,'norm');

YYY=funTEST(XXX);
[YYYn,NIY]=norm_denorm(YYY,'norm');

e=1;
C=logspace(-5,4,100);
xi=1e-6;
sigma=0.2;
nu=0.2;
funKernel=@(XXI,XXJ,p) exp(-1/(p^2)*(XXI-XXJ)^2);

eN=norm_denorm(e,'norm',NIY);

Xp=[0:0.01:1]';
Xpn=norm_denorm(Xp,'norm',NIX);
Zref=funTEST(Xp);

for ii=1:length(C)
    [SVRalpha,SVR_V,SVR_mu]=esvrbuild(XXXn,YYYn,sigma,nu,C(ii),xi,funKernel);
    ZN=svrpred(Xpn,XXXn,sigma,SVR_mu,SVRalpha,funKernel);
    ZZ=norm_denorm(ZN,'denorm',NIY);
    err=crit_err(ZZ',Zref);
    mse(ii)=err.emse;
    rmse(ii)=err.rmse;
    r2(ii)=err.r2;
    r2adj(ii)=err.r2adj;
    raae(ii)=err.eraae;
    rmae(ii)=err.ermae;
    eq1(ii)=err.eq1;
    eq2(ii)=err.eq2;
    eq3(ii)=err.eq3;
end

figure;
subplot(3,3,1)
loglog(C,mse)
title('MSE')
subplot(3,3,2)
loglog(C,rmse)
title('RMSE')
subplot(3,3,3)
loglog(C,r2)
title('R_2')
subplot(3,3,4)
loglog(C,r2adj)
title('R_{2adj}')
subplot(3,3,5)
loglog(C,raae)
title('RAAE')
subplot(3,3,6)
loglog(C,rmae)
title('RMAE')
subplot(3,3,7)
loglog(C,eq1)
title('Q_1')
subplot(3,3,8)
loglog(C,eq2)
title('Q_2')
subplot(3,3,9)
loglog(C,eq3)
title('Q_3')

C=1e4;
sigma=linspace(0.1,1,100);
for ii=1:length(sigma)
    sigma(ii)
    [SVRalpha,SVR_V,SVR_mu]=esvrbuild(XXXn,YYYn,sigma(ii),nu,C,xi,funKernel);
    ZN=svrpred(Xpn,XXXn,sigma(ii),SVR_mu,SVRalpha,funKernel);
    ZZ=norm_denorm(ZN,'denorm',NIY);%ZZ=ZN;
    err=crit_err(ZZ',Zref);
    mse(ii)=err.emse;
    rmse(ii)=err.rmse;
    r2(ii)=err.r2;
    r2adj(ii)=err.r2adj;
    raae(ii)=err.eraae;
    rmae(ii)=err.ermae;
    eq1(ii)=err.eq1;
    eq2(ii)=err.eq2;
    eq3(ii)=err.eq3;
end

figure;
subplot(3,3,1)
loglog(sigma,mse)
title('MSE')
subplot(3,3,2)
loglog(sigma,rmse)
title('RMSE')
subplot(3,3,3)
loglog(sigma,r2)
title('R_2')
subplot(3,3,4)
loglog(sigma,r2adj)
title('R_{2adj}')
subplot(3,3,5)
loglog(sigma,raae)
title('RAAE')
subplot(3,3,6)
loglog(sigma,rmae)
title('RMAE')
subplot(3,3,7)
loglog(sigma,eq1)
title('Q_1')
subplot(3,3,8)
loglog(sigma,eq2)
title('Q_2')
subplot(3,3,9)
loglog(sigma,eq3)
title('Q_3')


C=1e4;
sigma=0.2;
nu=linspace(0,1,100);
for ii=1:length(nu)
    nu(ii)
    [SVRalpha,SVR_V,SVR_mu]=esvrbuild(XXXn,YYYn,sigma,nu(ii),C,xi,funKernel);
    ZN=svrpred(Xpn,XXXn,sigma,SVR_mu,SVRalpha,funKernel);
    ZZ=norm_denorm(ZN,'denorm',NIY);%ZZ=ZN;
    err=crit_err(ZZ',Zref);
    mse(ii)=err.emse;
    rmse(ii)=err.rmse;
    r2(ii)=err.r2;
    r2adj(ii)=err.r2adj;
    raae(ii)=err.eraae;
    rmae(ii)=err.ermae;
    eq1(ii)=err.eq1;
    eq2(ii)=err.eq2;
    eq3(ii)=err.eq3;
end

figure;
subplot(3,3,1)
loglog(nu,mse)
title('MSE')
subplot(3,3,2)
loglog(nu,rmse)
title('RMSE')
subplot(3,3,3)
loglog(nu,r2)
title('R_2')
subplot(3,3,4)
loglog(nu,r2adj)
title('R_{2adj}')
subplot(3,3,5)
loglog(nu,raae)
title('RAAE')
subplot(3,3,6)
loglog(nu,rmae)
title('RMAE')
subplot(3,3,7)
loglog(nu,eq1)
title('Q_1')
subplot(3,3,8)
loglog(nu,eq2)
title('Q_2')
subplot(3,3,9)
loglog(nu,eq3)
title('Q_3')

