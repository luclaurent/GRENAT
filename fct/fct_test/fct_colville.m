%fonction Colville
%L. LAURENT -- 16/09/2011 -- luc.laurent@ens-cachan.fr

%minimum global: f(x1,x2,x3,x4)=0 pour (x1,x2,x3,x4)=(1,1,1,1)

%Domaine d'etude de la fonction: -10<xi<10 
function [p,dp]=fct_colville(xx)


if size(xx,3)>2
    error('La fonction Colville est une fonction de 4 variables');
elseif size(xx,3)==1
    if size(xx,2)==4
        xxx=xx(:,1);yyy=xx(:,2);zzz=xx(:,3);vvv=xx(:,4);
    elseif size(xx,1)==4
        xxx=xx(1,:);yyy=xx(2,:);zzz=xx(3,:);vvv=xx(4,:);
    else
        error('Mauvais format varibale entr�e fct Colville');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);zzz=xx(:,:,3);vvv=xx(:,:,4);
end

p =100*(xxx.^2-yyy).^2+(xxx-1).^2+(zzz-1).^2+50*(zzz.^2-vvv).^2+...
    10.1*((zzz-1).^2+(vvv-1).^2)+19.8*(yyy-1)*(vvv-1);


if nargout==2
    dp(:,:,1)=400*x1.*(xxx.^2-yyy)+2*(xxx-1);
    dp(:,:,2)=-200*(xxx.^2-yyy)+19.8*(vvv-1);
    dp(:,:,3)=2*(zzz-1)+200*zzz.*(zzz.^2-vvv)+20.2*(zzz-1);
    dp(:,:,4)=-100*(zzz.^2-vvv)+20.2*(vvv-1)+19.8*(yyy-1);
end
end