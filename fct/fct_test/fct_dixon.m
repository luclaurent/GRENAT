%Fonction Dixon & Price 
%modif L. LAURENT -- 16/09/2011 -- ajout calcul gradient


%Domaine d'etude de la fonction: -10<xi<10


function [p,dp,infos] = fct_dixon(xx,dim)
% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=10;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    error('Mauvais format variable entree fct Dixon & Price');
else
    p=(xx(:,:,1)-1).^2;
    for iter=2:nbvar
       p=p+iter*(2*xx(:,:,iter).^2-xx(:,:,iter-1)).^2;
    end
    
    if nargout==2||dem
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
else
    if nargin==2
        nbvar=dim;
    end
    p=[];
    dp=[];
end
%sortie informations sur la fonction
if nargout==3
    pts=NaN;
    infos.min_glob.X=pts;
    infos.min_glob.Z=NaN;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=pts;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Dixon & Price')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Dixon & Price')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Dixon & Price')
end
end