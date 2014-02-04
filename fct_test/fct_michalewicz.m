%Fonction Michalewicz
%modif L. LAURENT -- 16/09/2011 -- ajout calcul gradient

%minimum global: dependent du nb de variables

%Domaine d'etude de la fonction: 0<xi<pi


function [p,dp,infos] = fct_michalewicz(xx,dim)
% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=pi;
    [x,y]=meshgrid(linspace(0,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    %Nombre de variables
    nbvar=size(xx,3);
    
    if nbvar==1
        error('Mauvais format variable entr�e fct Michalewicz');
    else
        p=0;
        for iter=1:nbvar
            p=p+sin(xx(:,:,iter)).*sin(iter*xx(:,:,iter).^2/pi).^20;
        end
        p=-p;
        if nargout==2||dem
            dp=zeros(size(xx));
            for iter=1:nbvar
                dp(:,:,iter)=cos(xx(:,:,iter)).*sin(iter*xx(:,:,iter).^2/pi).^20+...
                    40*iter/pi*xx(:,:,iter).*sin(xx(:,:,iter)).*cos(iter*xx(:,:,iter).^2/pi).^19;
            end
        end
        dp=-dp;
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
    xlabel('x'), ylabel('y'), title('Michalewicz')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Michalewicz')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Michalewicz')
    p=[];
end
end