%fonction Branin rcos 
%L. LAURENT -- 13/12/2010 -- luc.laurent@ens-cachan.fr

%3 minima globaux:
%f(x1,x2)=0 pour (x1,x2)={(-pi,12.275),(pi,2.275),(9.42478,2.475)}

%Domaine d'etude de la fonction: -5<x1<10, 0<x2<15

function [p,dp1,dp2]=fct_branin(xx,yy)

a=1;b=5.1/(4*pi^2);c=5/pi;d=6;e=10;f=1/(8*pi);


p = a*(yy-b*xx.^2+c*xx-d).^2+e*(1-f)*cos(xx)+e;

if nargout==3
   dp1=2*a*(yy-b*xx.^2+c*xx-d).*(c-2*b*xx)-e*(1-f)*sin(xx);
   dp2=2*a*(yy-b*xx.^2+c*xx-d);
end
end