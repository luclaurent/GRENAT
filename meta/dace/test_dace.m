
xx_aff=linspace(-5,5,100);xx_aff=xx_aff';
yy_aff=fct_manu(xx_aff);

xx=linspace(-5,5,5);xx=xx';
yy=fct_manu(xx);
theta=1 ;

[dmodel,perf]=dacefit(xx,yy,@regpoly0,@corrgauss,theta,10^-3,100);
[yy_app,err] = predictor(xx,dmodel);

[yy_app_aff,err] = predictor(xx_aff,dmodel);

figure
plot(xx_aff,yy_app_aff)
hold on
plot(xx_aff,yy_aff,'r')

xx_aff=linspace(-5,5,100);xx_aff=xx_aff';
yy_aff=fct_manu(xx_aff);

xx=linspace(-5,5,5);xx=xx';
yy=fct_manu(xx);
theta=1 ;

[dmodel,perf]=dacefit(xx,yy,@regpoly0,@corrgauss,theta,10^-3,5);
[yy_app,err] = predictor(xx,dmodel);

[yy_app_aff,err] = predictor(xx_aff,dmodel);

figure
plot(xx_aff,yy_app_aff)
hold on
plot(xx_aff,yy_aff,'r')