%fonction Six-Hump camel back
%L. LAURENT -- 13/12/2010 -- luc.laurent@lecnam.net
%modif le 16/09/2011 -- modif ecriture input pour passage code a n
%variables

%6 minima locaux dont 2 globaux:
%f(x1,x2)=-1.0316 pour (x1,x2)={(-0.0898,0.7126),(0.0898,0.7126)}

%Domaine d'etude de la fonction: -3<x1<3 -2<x2<2
%(conseille: -2<x1<2 -1<x2<1)


function [p,dp,infos]=fct_sixhump(xx,dim)

% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=500;
    XX=linspace(-3,3,pas);
    YY=linspace(-2,2,pas);
    [x,y]=meshgrid(XX,YY);
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    if size(xx,3)>2
        error('La fonction SixHump est une fonction de deux variables');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format variable entr�e fct SixHump');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    p=(4-2.1*xxx.^2+xxx.^4/3).*xxx.^2+xxx.*yyy+4*(-1+yyy.^2).*yyy.^2;
    
    
    if nargout==2||dem
        dp(:,:,1)=2*xxx.*(4-2.1*xxx.^2+xxx.^4/3)+xxx.^2.*(-4.2*xxx+4*xxx.^3/3)+yyy;
        dp(:,:,2)=xxx+8*yyy.*(-1+yyy.^2)+8*yyy.^3;
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
    xlabel('x'), ylabel('y'), title('Six-Hump Camel Back')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Six-Hump Camel Back')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Six-Hump Camel Back')
    p=[];
end

end
