%Fonction Michalewicz
%modif L. LAURENT -- 16/09/2011 -- ajout calcul gradient

function [p,dp] = fct_michalewicz(xx)

%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    error('Mauvais format variable entrée fct Michalewicz');
else
    p=0;
    for iter=2:nbvar
        p=p+sin(xx(:,:,iter)).*sin(iter*xx(:,:,iter).^2/pi).^20;
    end
    
    if nargout==2
        dp=zeros(size(xx));
        for iter=1:nbvar
            dp(:,:,iter)=cos(xx(:,:,iter)).*sin(iter*xx(:,:,iter).^2/pi).^20+...
                40*iter/pi*xx(:,:,iter).*sin(xx(:,:,iter)).*cos(iter*xx(:,:,iter).^2/pi).^19;            
        end
    end
    
end
end