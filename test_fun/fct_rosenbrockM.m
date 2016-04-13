%Fonction de Rosenbrock Modifiee (Sobester 2005)
% L. LAURENT -- 16/05/2012 -- ajout calcul gradient


function [p,dp,infos] = fct_rosenbrockM(xx,dim)

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
            error('Mauvais format variable entr�e fct Rosenbrock');
        end
        p=a.*(yyy-xxx.^2).^2 + (1 - xxx).^2 + c * (sin(d*(1-xxx)) + sin(d*(1-yyy)));
        if nargout==2||dem
            dp(:,:,1)=-4*a.*xxx.*(yyy-xxx.^2)-2*(1-xxx)-c*d*cos(d(1-xxx));
            dp(:,:,2)=2*a*(yyy-xxx.^2)-c*d*cos(d(1-yyy));
        end
        
    else
        p=0;
        for iter=1:nbvar-1
            p=p+a*(xx(:,:,iter).^2-xx(:,:,iter+1)).^2+(xx(:,:,iter)-1).^2+c*sin(d*(1-xx(:,:,iter)));
        end
        
        if nargout==2||dem
            for iter=1:nbvar
                if iter==1
                    dp(:,:,iter)=4*a*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1)+...
                        c*d*cos(d*(1-xx(:,:,iter)));
                elseif iter==nbvar
                    dp(:,:,iter)=2*a*(xx(:,:,iter)-xx(:,:,iter-1).^2)+2*(xx(:,:,iter)-1)+...
                        c*d*cos(d*(1-xx(:,:,iter)));
                else
                    dp(:,:,iter)=2*a*(xx(:,:,iter)-xx(:,:,iter-1).^2)+...
                        4*a*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1)+c*d*cos(d*(1-xx(:,:,iter)));
                    
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
    xlabel('x'), ylabel('y'), title('RosenbrockM')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X RosenbrockM')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y RosenbrockM')
    p=[];
end

end