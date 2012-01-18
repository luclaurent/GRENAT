dim=1;
fct='rf_invmultiqua';

pas=10^-2;

if dim==1

x=-10:pas:10;
[ev,dev,ddev]=feval(fct,x',1);

figure
hold on
plot(x,ev,'b')
plot(x,dev,'r')
plot(x,ddev,'k')
axis([-10 10 -500 500]);
end