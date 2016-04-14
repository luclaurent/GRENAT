%fonction Branin rcos
%L. LAURENT -- 13/12/2010 -- luc.laurent@lecnam.net
%modif le 16/09/2011 -- modif �criture input pour passage code � n
%variables

%3 minima globaux:
%f(x1,x2)=0 pour (x1,x2)={(-pi,12.275),(pi,2.275),(9.42478,2.475)}

%Domaine d'etude de la fonction: -5<x1<10, 0<x2<15

function [p,dp,infos]=fct_branin(xx,dim)

a=1;b=5.1/(4*pi^2);c=5/pi;d=6;e=10;f=1/(8*pi);
% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=10;
    XX=linspace(-5,10,pas);
    YY=linspace(0,15,pas);
    [x,y]=meshgrid(XX,YY);
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    if size(xx,3)>2
        error('La fonction Branin est une fonction de deux variables');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format variable entr�e fct Branin');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    
    p = a*(yyy-b*xxx.^2+c*xxx-d).^2+e*(1-f)*cos(xxx)+e;
    
    if nargout==2||dem
        dp(:,:,1)=2*a*(yyy-b*xxx.^2+c*xxx-d).*(c-2*b*xxx)-e*(1-f)*sin(xxx);
        dp(:,:,2)=2*a*(yyy-b*xxx.^2+c*xxx-d);
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
    pts=[-pi,12.275;pi,2.275;9.42478,2.475];
    infos.min_glob.X=pts;
    infos.min_glob.Z=a*(pts(:,2)-b*pts(:,1).^2+c*pts(:,1)-d).^2+e*(1-f)*cos(pts(:,1))+e;
    infos.min_loc.Z=[0;0;0];
    infos.min_loc.X=[-pi,12.275;pi,2.275;9.42478,2.475];
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Branin')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Branin')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Branin')
end
end