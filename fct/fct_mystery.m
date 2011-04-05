%Fonction "Mystery" (Sasena 2002) 
%L. LAURENT -- 01/04/2011 -- laurent@lmt.ens-cachan.fr

%3 minimas locaux
%1 minimum global: f(x)=-1.4565 pour x={2.5044,2.5778}

%domaine d'etude: 0<xi<5

function [myst,dmyst1,dmyst2]=fct_mystery(xx,yy)

a=2;
b=0.01;
c=2;
d=2;
e=7;
f=0.5;
g=0.7;

myst=a+b*(yy-xx.^2).^2+(1-xx).^2+c*(d-yy).^2+e*sin(f*xx).*sin(g*xx.*yy);

if nargout==3
   dmyst1=-b*4*(yy-xx.^2)-2*(1-xx)+e*f*cos(f*xx).*sin(g*xx.*yy)+e*g*yy.*sin(f*xx).*cos(g*xx.*yy);
   dmyst2=2*b*(yy-xx.^2)-4*(d-yy)+e*g*xx.*sin(f*xx).*cos(g*xx.*yy);
end