%fonction Axis parallel hyper-ellipsoid (Weighted Sphere Model)
%L. LAURENT -- 21/02/2012 -- laurent@lmt.ens-cachan.fr

%1 minimum global: x=(0,0,...,0) >> f(x)=0

%domaine d'etude -5.12<xi<5.12

function [p,dp,infos]=fct_AHE(xx,dim)

% pour démonstration
dem=false;
if nargin==0
    pas=50;
    [x,y]=meshgrid(linspace(-2,2,pas));
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
            error('Mauvais format variable entree fct AHE');
        end
        p=xxx.^2+2*yyy.^2;
        if nargout==2||dem
            dp(:,:,1)=2*xxx;
            dp(:,:,2)=2*2*yyy;
        end
    else
        vv=reshape(1:nbvar,1,1,nbvar);
        coef=repmat(vv,[size(xx,1) size(xx,2)]);
        cal=coef.*xx.^2;
        p=sum(cal,3);
        if nargout==2||dem
            dp=2*coef.*xx;
        end
    end
else
    if nargin==2
        nbvar=dim;
    end
end
%sortie informations sur la fonction
if nargout==3
    infos.min_glob.Z=0;
    infos.min_glob.X=zeros(1,nbvar);
    infos.min_loc.Z=0;
    infos.min_loc.X=zeros(1,nbvar);
end

%démonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('AHE')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X AHE')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y AHE')
end
end