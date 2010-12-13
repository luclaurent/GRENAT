%fonction Branin rcos 
%L. LAURENT -- 13/12/2010 -- luc.laurent@ens-cachan.fr

function [p,dp1,dp2]=fct_branin(xx,yy)

a=1;b=5.2/pi;c=5/pi;d=6;e=10;f=1/(8*pi);


p = a*(yy-b*xx.^2+c*xx-d).^2+e*(1-f)*cos(xx)+e;

if nargout==3
   dp1=2*a*(yy-b*xx.^2+c*xx-d)*(c-2*b*xx)-e*(1-f)*sin(xx);
   dp2=2*a*(yy-b*xx.^2+c*xx-d);
end
end