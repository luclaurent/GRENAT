% Fonction pente
% L. LAURENT -- 15/12/2011 --

function [res,dres]=fct_pente(xx)

%pente dans la direction
dir=1;

%Nombre de variables
nbvar=size(xx,3);

%valeur constant
val=10;

if nbvar==1

    res=val*xx(:,dir);
    if nargout==2
        dres(:,:,1)=0*res;
        dres(:,:,2)=0*res;
        dres(:,:,dir)=val*ones(size(res));
    end
    
else
    res=val*xx(:,:,dir);
    if nargout==2
        dres(:,:,1)=0*res;
        dres(:,:,2)=0*res;
        dres(:,:,dir)=val*ones(size(res));
    end
end
end