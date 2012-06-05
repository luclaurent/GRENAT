%Fonction de Rosenbrock Modifiee (Sobester 2005) 
% L. LAURENT -- 16/05/2012 -- ajout calcul gradient


function [ros,dros] = fct_rosenbrockM(xx)

%Nombre de variables
nbvar=size(xx,3);

%coefficients
a=100;
c=75;
d=5;

if nbvar==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entrée fct Rosenbrock');
    end
    ros=a.*(yyy-xxx.^2).^2 + (1 - xxx).^2 + c * (sin(d*(1-xxx)) + sin(d*(1-yyy)));
    if nargout==2
        dros(:,:,1)=-4*a.*xxx.*(yyy-xxx.^2)-2*(1-xxx)-c*d*cos(d(1-xxx));
        dros(:,:,2)=2*a*(yyy-xxx.^2)-c*d*cos(d(1-yyy));
    end

else
    ros=0;
    for iter=1:nbvar-1
       ros=ros+a*(xx(:,:,iter).^2-xx(:,:,iter+1)).^2+(xx(:,:,iter)-1).^2+c*sin(d*(1-xx(:,:,iter)));
    end
    
    if nargout==2
        for iter=1:nbvar
            if iter==1
                dros(:,:,iter)=4*a*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1)+...
                    c*d*cos(d*(1-xx(:,:,iter)));
            elseif iter==nbvar
                dros(:,:,iter)=2*a*(xx(:,:,iter)-xx(:,:,iter-1).^2)+2*(xx(:,:,iter)-1)+...
                    c*d*cos(d*(1-xx(:,:,iter)));
            else
                dros(:,:,iter)=2*a*(xx(:,:,iter)-xx(:,:,iter-1).^2)+...
                    4*a*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1)+c*d*cos(d*(1-xx(:,:,iter)));
                
            end                
        end
    end

end
end