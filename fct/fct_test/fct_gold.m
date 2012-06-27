%fonction Goldstein & Price
%L. LAURENT -- 13/12/2010 -- luc.laurent@ens-cachan.fr
%modif le 16/09/2011 -- modif ecriture input pour passage code a n
%variables

%minimum global: f(x1,x2)=3 pour (x1,x2)=(0,-1)

%Domaine d'etude de la fonction: -2<x1<2, -2<x<2
function [p,dp,infos]=fct_gold(xx,dim)
% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=2;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    if size(xx,3)>2
        error('La fonction Goldstein est une fonction de deux variables');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format varibale entr�e fct Goldstein');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    a = 1+(xxx+yyy+1).^2.*(19-14*xxx+3*xxx.^2-14*yyy+6.*xxx.*yyy+3*yyy.^2);
    b = 30+(2*xxx-3*yyy).^2.*(18-32*xxx+12*xxx.^2+48*yyy-36*xxx.*yyy+27*yyy.^2);
    p = a.*b;
    
    
    if nargout==2||dem
        dp(:,:,1)=24*(-1+2*xxx-3*yyy).*(2*xxx-3*yyy).*(2*xxx-3*(1+yyy)).*...
            (1+(1+xxx+yyy).^2.*(19+3*xxx.^2+yyy.*(-14+3*yyy)+2*xxx.*(-7+3*yyy)))+...
            12*(-2+xxx+yyy).*(-1+xxx+yyy).*(1+xxx+yyy).*(30+(2*xxx-3*yyy).^2.*...
            (12*xxx.^2-4*xxx.*(8+9*yyy)+3*(6+yyy.*(16+9*yyy))));
        dp(:,:,2)=-36*(-1+2*xxx-3*yyy).*(2*xxx-3*yyy).*(2*xxx-3*(1+yyy)).*...
            (1+(1+xxx+yyy).^2.*(19-3*xxx.^2+yyy.*(-14+3*yyy)+2*xxx.*(-7+3*yyy)))+...
            12*(-2+xxx+yyy).*(-1+xxx+yyy).*(1+xxx+yyy).*...
            (30+(2*xxx-3*yyy).^2.*(12*xxx.^2-4*xxx.*(8+9*yyy)+3*(6+yyy.*(16+9*yyy))));
        
    end
else
    nbvar=2;
    p=[];
    dp=[];
end

%sortie informations sur la fonction
if nargout==3
    pts=[0 -1];
    xxx=pts(1);
    yyy=pts(2);
    a = 1+(xxx+yyy+1).^2.*(19-14*xxx+3*xxx.^2-14*yyy+6.*xxx.*yyy+3*yyy.^2);
    b = 30+(2*xxx-3*yyy).^2.*(18-32*xxx+12*xxx.^2+48*yyy-36*xxx.*yyy+27*yyy.^2);
    p = a.*b;
    infos.min_glob.X=pts;
    infos.min_glob.Z=p;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Goldstein & Price')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Goldstein & Price')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Goldstein & Price')
    p=[];
end
end