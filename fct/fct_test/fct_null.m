% Fonction nulle
% L. LAURENT -- 20/10/2011 --

function [res,dres]=fct_null(xx)

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
    res=zeros(size(xxx));
    if nargout==2
        dres(:,:,1)=res;
        dres(:,:,2)=res;
    end

else
    res=zeros(size(xx(:,:,1)));
    if nargout==2
        dres(:,:,1)=res;
        dres(:,:,2)=res;
    end
end
end