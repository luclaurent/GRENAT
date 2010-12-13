%fonction Six-Hump camel back
%L. LAURENT -- 13/12/2010 -- luc.laurent@ens-cachan.fr

%6 minima locaux dont 2 globaux:
%f(x1,x2)=-1.0316 pour (x1,x2)={(-0.0898,0.7126),(0.0898,0.7126)}

%Domaine d'etude de la fonction: -3<x1<3 -2<x2<2
%(conseille: -2<x1<2 -1<x2<1)


function [p,dp1,dp2]=fct_sixhump(xx,yy)


p=(4-2.1*xx.^2+xx.^4/3).*xx.^2+xx.*yy+4*(-1+yy.^2).*yy.^2;


if nargout==3
    dp1=2*xx.*(4-2.1*xx.^2+xx.^4/3)+xx.^2.*(-4.2*xx+4*xx.^3/3)+yy;
    dp2=xx+8*yy.*(-1+yy.^2)+8*yy.^3;
end