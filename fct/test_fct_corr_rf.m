dim=1;
fct='rf_thin_plate_splines';

pas=10^-2;

if dim==1

x=-10:pas:10;
[ev,dev,ddev]=feval(fct,x');

figure
hold on
plot(x,ev,'b')
plot(x,dev,'r')
plot(x,ddev,'k')
axis([-10 10 -500 500]);
end