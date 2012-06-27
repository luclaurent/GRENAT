%Fonction "Mystery" (Sasena 2002)
%L. LAURENT -- 01/04/2011 -- laurent@lmt.ens-cachan.fr
%modif le 16/09/2011 -- modif �criture input pour passage code � n
%variables

%3 minimas locaux
%1 minimum global: f(x)=-1.4565 pour x={2.5044,2.5778}

%domaine d'etude: 0<xi<5

function [p,dp,infos]=fct_mystery(xx,dim)

a=2;
b=0.01;
c=2;
d=2;
e=7;
f=0.5;
g=0.7;

% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=5;
    [x,y]=meshgrid(linspace(0,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    if size(xx,3)>2
        error('La fonction Mystery est une fonction de deux variables');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format variable entree fct Mystery');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    myst=a+b*(yyy-xxx.^2).^2+(1-xxx).^2+c*(d-yyy).^2+e*sin(f*xxx).*sin(g*xxx.*yyy);
    p=myst;
    if nargout==2||dem
        dmyst(:,:,1)=-b*4*(yyy-xxx.^2)-2*(1-xxx)+...
            e*f*cos(f*xxx).*sin(g*xxx.*yyy)+e*g*yyy.*sin(f*xxx).*cos(g*xxx.*yyy);
        dmyst(:,:,2)=2*b*(yyy-xxx.^2)-4*(d-yyy)+e*g*xxx.*sin(f*xxx).*cos(g*xxx.*yyy);
    end
    dp=dmyst;
else
    nbvar=dim;
    p=[];
    dp=[];
end
%sortie informations sur la fonction
if nargout==3
    pts=[2.5044,2.5778];
    infos.min_glob.X=pts;
    infos.min_glob.Z=-1.4565;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Mystery')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Mystery')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Mystery')
    p=[];
end
end