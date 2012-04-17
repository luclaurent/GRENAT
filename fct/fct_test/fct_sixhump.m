%fonction Six-Hump camel back
%L. LAURENT -- 13/12/2010 -- luc.laurent@ens-cachan.fr
%modif le 16/09/2011 -- modif écriture input pour passage code à n
%variables

%6 minima locaux dont 2 globaux:
%f(x1,x2)=-1.0316 pour (x1,x2)={(-0.0898,0.7126),(0.0898,0.7126)}

%Domaine d'etude de la fonction: -3<x1<3 -2<x2<2
%(conseille: -2<x1<2 -1<x2<1)


function [p,dp]=fct_sixhump(xx)


if size(xx,3)>2
    error('La fonction SixHump est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entrée fct SixHump');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end

p=(4-2.1*xxx.^2+xxx.^4/3).*xxx.^2+xxx.*yyy+4*(-1+yyy.^2).*yyy.^2;


if nargout==2
    dp(:,:,1)=2*xxx.*(4-2.1*xxx.^2+xxx.^4/3)+xxx.^2.*(-4.2*xxx+4*xxx.^3/3)+yyy;
    dp(:,:,2)=xxx+8*yyy.*(-1+yyy.^2)+8*yyy.^3;
end
end