%fonction Beale
%L. LAURENT -- 16/09/2011 -- luc.laurent@ens-cachan.fr

%minimum global: f(x1,x2)=0 pour (x1,x2)=(3,-0.5)

%Domaine d'etude de la fonction: -4.5<x1<4.5, -4.5<x<4.5 
function [p,dp]=fct_beale(xx)


if size(xx,3)>2
    error('La fonction Beale est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format varibale entrée fct Beale');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end

p = (1.5 - xxx + xxx.*yyy).^2 + (2.25 - xxx + xxx.*yyy.^2).^2 + (2.625 - xxx + xxx.*yyy.^3).^2;


if nargout==2
    dp(:,:,1)=2*(yyy-1).*(1.5-xxx+xxx.*yyy)+...
        2*(yyy.^2-1).*(2.25 - xxx + xxx.*yyy.^2) +...
        2*(yyy.^3-1).*(2.625 - xxx + xxx.*yyy.^3);
    dp(:,:,2)=2*xxx.*(1.5-xxx+xxx.*yyy)+...
        4*xxx.*yyy.*(2.25 - xxx + xxx.*yyy.^2) +...
        6*xxx.*yyy.^2.*(2.625 - xxx + xxx.*yyy.^3);
end
end