%fonction Bohachevsky2
%L. LAURENT -- 16/09/2011 -- luc.laurent@ens-cachan.fr

%minimum global: f(x1,x2)=0 pour (x1,x2)=(0,0)

%Domaine d'etude de la fonction: -100<x1<100, -100<x2<100 
function [p,dp]=fct_bohachevsky2(xx)


if size(xx,3)>2
    error('La fonction Bohachevsky 2 est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format varibale entrée fct Bohachevsky 2');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end

p = xxx.^2+2*yyy.^2-0.3*cos(3*pi*xxx).*cos(4*pi*yyy)+0.3;


if nargout==2
    dp(:,:,1)=2*xxx+0.9*pi*sin(3*pi*xxx).*cos(4*pi*yyy);
    dp(:,:,2)=4*yyy+1.2*pi*cos(3*pi*xxx).*sin(4*pi*yyy);
end
end