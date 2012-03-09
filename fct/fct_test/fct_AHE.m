%fonction Axis parallel hyper-ellipsoid (Weighted Sphere Model)
%L. LAURENT -- 21/02/2012 -- laurent@lmt.ens-cachan.fr

%1 minimum global: x=(0,0,...,0) >> f(x)=0

%domaine d'�tude -5.12<xi<5.12

function [p,dp]=fct_AHE(xx)
%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entr�e fct WSM');
    end
    p=xxx.^2+2*yyy.^2;
    if nargout==2
        dp(:,:,1)=2*xxx;
        dp(:,:,2)=2*2*yyy;
    end
    
else
    vv=reshape(1:nbvar,1,1,nbvar);
    coef=repmat(vv,[size(xx,1) size(xx,2)]);
    cal=coef.*xx.^2;
    p=sum(cal,3);
    if nargout==2
        dp=2*coef.*xx;
    end
    
end

end