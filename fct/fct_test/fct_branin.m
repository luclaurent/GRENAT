%fonction Branin rcos 
%L. LAURENT -- 13/12/2010 -- luc.laurent@ens-cachan.fr
%modif le 16/09/2011 -- modif écriture input pour passage code à n
%variables

%3 minima globaux:
%f(x1,x2)=0 pour (x1,x2)={(-pi,12.275),(pi,2.275),(9.42478,2.475)}

%Domaine d'etude de la fonction: -5<x1<10, 0<x2<15

function [p,dp]=fct_branin(xx)

a=1;b=5.1/(4*pi^2);c=5/pi;d=6;e=10;f=1/(8*pi);

if size(xx,3)>2
    error('La fonction Branin est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entrée fct Branin');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end


p = a*(yyy-b*xxx.^2+c*xxx-d).^2+e*(1-f)*cos(xxx)+e;

if nargout==2
   dp(:,:,1)=2*a*(yyy-b*xxx.^2+c*xxx-d).*(c-2*b*xxx)-e*(1-f)*sin(xxx);
   dp(:,:,2)=2*a*(yyy-b*xxx.^2+c*xxx-d);
end
end