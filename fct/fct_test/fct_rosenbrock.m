%Fonction de Rosenbrock 
%modif L. LAURENT -- 12/05/2010 -- ajout calcul gradient
%modif le 16/09/2011 -- modif ecriture input pour passage code � n
%variables

function [p,dp,infos] = fct_rosenbrock(xx,dim)

% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=2.048;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entr�e fct Rosenbrock');
    end
    p=100.*(yyy-xxx.^2).^2 + (1 - xxx).^2;
    if nargout==2||dem
        dp(:,:,1)=-400.*xxx.*(yyy-xxx.^2)-2*(1-xxx);
        dp(:,:,2)=200*(yyy-xxx.^2);
    end

else
    p=0;
    for iter=1:nbvar-1
       p=p+100*(xx(:,:,iter).^2-xx(:,:,iter+1)).^2+(xx(:,:,iter)-1).^2;
    end
    
    if nargout==2||dem
        for iter=1:nbvar
            if iter==1
                dp(:,:,iter)=400*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1);
            elseif iter==nbvar
                dp(:,:,iter)=200*(xx(:,:,iter)- xx(:,:,iter-1).^2)+2*(xx(:,:,iter)-1);
            else
                dp(:,:,iter)=200*(xx(:,:,iter)-xx(:,:,iter-1).^2)+...
                    400*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1);
                
            end                
        end
    end

end
else
    nbvar=dim;
    p=[];
    dp=[];
end
%sortie informations sur la fonction
if nargout==3
    pts=ones(1,nbvar);
    infos.min_glob.X=pts;
    infos.min_glob.Z=0;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Rosenbrock')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Rosenbrock')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Rosenbrock')
    p=[];
end

end