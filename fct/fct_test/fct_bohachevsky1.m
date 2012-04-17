%fonction Bohachevsky1
%L. LAURENT -- 16/09/2011 -- luc.laurent@ens-cachan.fr

%minimum global: f(x1,x2)=0 pour (x1,x2)=(0,0)

%Domaine d'etude de la fonction: -100<x1<100, -100<x2<100 
function [p,dp]=fct_bohachevsky1(xx)


if size(xx,3)>2
    error('La fonction Bohachevsky 1 est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format varibale entrée fct Bohachevsky 1');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end

p = xxx.^2+2*yyy.^2-0.3*cos(3*pi*xxx)-0.4*cos(4*pi*yyy)+0.7;


if nargout==2
    dp(:,:,1)=2*xxx+0.9*pi*sin(3*pi*xxx);
    dp(:,:,2)=4*yyy+1.6*pi*sin(4*pi*yyy);
end
end