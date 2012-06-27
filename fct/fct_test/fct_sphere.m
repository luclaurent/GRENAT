%Fonction Sphere
%modif L. LAURENT -- 16/09/2011 -- ajout calcul gradient


%minimum global: f(xi)=0 pour (x1,x2,x3,x4)=(0,...,0)

%Domaine d'etude de la fonction: -10<xi<10 


function [p,dp,infos] = fct_sphere(xx,dim)
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
    error('Mauvais format variable entr�e fct Sphere');
else
    cal=xx.^2;
    p=sum(cal,3);
    
    if nargout==2||dem
        dp=2*xx;
    end
    
end
else
    nbvar=dim;
    p=[];
    dp=[];
end
%sortie informations sur la fonction
if nargout==3
    pts=[-0.0898,0.7126;0.0898,0.7126];
    infos.min_glob.X=pts;
    infos.min_glob.Z=[-1.0316;-1.0316];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Sphere')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Sphere')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Sphere')
    p=[];
end

end