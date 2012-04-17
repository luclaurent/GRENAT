%Fonction "Mystery" (Sasena 2002) 
%L. LAURENT -- 01/04/2011 -- laurent@lmt.ens-cachan.fr
%modif le 16/09/2011 -- modif écriture input pour passage code à n
%variables

%3 minimas locaux
%1 minimum global: f(x)=-1.4565 pour x={2.5044,2.5778}

%domaine d'etude: 0<xi<5

function [myst,dmyst]=fct_mystery(xx)

a=2;
b=0.01;
c=2;
d=2;
e=7;
f=0.5;
g=0.7;


if size(xx,3)>2
    error('La fonction Mystery est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entrée fct Mystery');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end

myst=a+b*(yyy-xxx.^2).^2+(1-xxx).^2+c*(d-yyy).^2+e*sin(f*xxx).*sin(g*xxx.*yyy);

if nargout==2
   dmyst(:,:,1)=-b*4*(yyy-xxx.^2)-2*(1-xxx)+...
       e*f*cos(f*xxx).*sin(g*xxx.*yyy)+e*g*yyy.*sin(f*xxx).*cos(g*xxx.*yyy);
   dmyst(:,:,2)=2*b*(yyy-xxx.^2)-4*(d-yyy)+e*g*xxx.*sin(f*xxx).*cos(g*xxx.*yyy);
end

