%fonction Goldstein & Price  
%L. LAURENT -- 13/12/2010 -- luc.laurent@ens-cachan.fr

%minimum global: f(x1,x2)=3 pour (x1,x2)=(0,-1)

%Domaine d'etude de la fonction: -2<x1<2, -2<x<2 (
function [p,dp1,dp2]=fct_gold(xx,yy)


a = 1+(xx+yy+1).^2.*(19-14*xx+3*xx.^2-14*yy+6.*xx.*yy+3*yy.^2);
b = 30+(2*xx-3*yy).^2.*(18-32*xx+12*xx.^2+48*yy-36*xx.*yy+27*yy.^2);
p = a.*b;


if nargout==3
    dp1=24*(-1+2*xx-3*yy).*(2*xx-3*yy).*(2*xx-3*(1+yy)).*...
        (1+(1+xx+yy).^2.*(19+3*xx.^2+yy.*(-14+3*yy)+2*xx.*(-7+3*yy)))+...
        12*(-2+xx+yy).*(-1+xx+yy).*(1+xx+yy).*(30+(2*xx-3*yy).^2.*...
        (12*xx.^2-4*xx.*(8+9*yy)+3*(6+yy.*(16+9*yy))));
    dp2=-36*(-1+2*xx-3*yy).*(2*xx-3*yy).*(2*xx-3*(1+yy)).*...
        (1+(1+xx+yy).^2.*(19-3*xx.^2+yy.*(-14+3*yy)+2*xx.*(-7+3*yy)))+...
        12*(-2+xx+yy).*(-1+xx+yy).*(1+xx+yy).*...
        (30+(2*xx-3*yy).^2.*(12*xx.^2-4*xx.*(8+9*yy)+3*(6+yy.*(16+9*yy))));
end