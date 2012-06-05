%Fonction de Rosenbrock 
%modif L. LAURENT -- 12/05/2010 -- ajout calcul gradient
%modif le 16/09/2011 -- modif écriture input pour passage code à n
%variables

function [ros,dros] = fct_rosenbrock(xx)

%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entrée fct Rosenbrock');
    end
    ros=100.*(yyy-xxx.^2).^2 + (1 - xxx).^2;
    if nargout==2
        dros(:,:,1)=-400.*xxx.*(yyy-xxx.^2)-2*(1-xxx);
        dros(:,:,2)=200*(yyy-xxx.^2);
    end

else
    ros=0;
    for iter=1:nbvar-1
       ros=ros+100*(xx(:,:,iter).^2-xx(:,:,iter+1)).^2+(xx(:,:,iter)-1).^2;
    end
    
    if nargout==2
        for iter=1:nbvar
            if iter==1
                dros(:,:,iter)=400*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1);
            elseif iter==nbvar
                dros(:,:,iter)=200*(xx(:,:,iter)- xx(:,:,iter-1).^2)+2*(xx(:,:,iter)-1);
            else
                dros(:,:,iter)=200*(xx(:,:,iter)-xx(:,:,iter-1).^2)+...
                    400*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1);
                
            end                
        end
    end

end
end