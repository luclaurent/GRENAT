%Fonction Dixon & Price 
%modif L. LAURENT -- 16/09/2011 -- ajout calcul gradient


%Domaine d'etude de la fonction: -10<xi<10


function [p,dp] = fct_dixon(xx)

%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    error('Mauvais format variable entrée fct Dixon & Price');
else
    p=(xx(:,:,1)-1).^2;
    for iter=2:nbvar
       p=p+iter*(2*xx(:,:,iter).^2-xx(:,:,iter-1)).^2;
    end
    
    if nargout==2
        dp=zeros(size(xx));
        for iter=1:nbvar
            if iter==1
                dp(:,:,iter)=2*(xx(:,:,iter)-1)-4*(2*xx(:,:,iter+1).^2-xx(:,:,iter));
            elseif iter==nbvar
                dp(:,:,iter)=iter*8*xx(:,:,iter).*(2*xx(:,:,iter).^2-xx(:,:,iter-1));
            else
                dp(:,:,iter)=iter*8*xx(:,:,iter).*(2*xx(:,:,iter).^2-xx(:,:,iter-1))...
                    -2*iter*(2*xx(:,:,iter+1).^2-xx(:,:,iter));
                
            end                
        end
    end

end
end