%fonction Booth
%L. LAURENT -- 16/09/2011 -- luc.laurent@ens-cachan.fr

%minimum global: f(x1,x2)=0 pour (x1,x2)=(1,3)

%Domaine d'etude de la fonction: -10<x1<10, -10<x<10 
function [p,dp]=fct_booth(xx)


if size(xx,3)>2
    error('La fonction Booth est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format varibale entrée fct Booth');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end

p = (xxx+2*yyy-7).^3+(2*xxx-yyy-5).^2;


if nargout==2
    dp(:,:,1)=3*(xxx+2*yyy-7).^2+4*(2*xxx-yyy-5);
    dp(:,:,2)=6*(xxx+2*yyy-7).^2-2*(2*xxx-yyy-5);
end
end