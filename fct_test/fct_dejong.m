%fonction De Jong
%L. LAURENT -- 21/02/2012 -- laurent@lmt.ens-cachan.fr

%1 minimum global: x=(0,0,...,0) >> f(x)=0

%domaine d'etude -5.12<xi<5.12

function [p,dp,infos]=fct_dejong(xx,dim)

coef=10;


% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=5.12;
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
            error('Mauvais format variable entree fct De Jong');
        end
        p=xxx.^2+yyy.^2;
        if nargout==2||dem
            dp(:,:,1)=2*xxx;
            dp(:,:,2)=2*yyy;
        end
    else
        cal=xx.^2;
        p=sum(cal,3);
        if nargout==2||dem
            dp=2*xx;
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
    pts=zeros(1,nbvar);
    infos.min_glob.X=pts;
    infos.min_glob.Z=zeros(1,nbvar);
    infos.min_loc.Z=pts;
    infos.min_loc.X=zeros(1,nbvar);
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('De Jong')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X De Jong')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y De Jong')
end
end

