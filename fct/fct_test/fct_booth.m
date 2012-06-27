%fonction Booth
%L. LAURENT -- 16/09/2011 -- luc.laurent@ens-cachan.fr

%minimum global: f(x1,x2)=0 pour (x1,x2)=(1,3)

%Domaine d'etude de la fonction: -10<x1<10, -10<x<10
function [p,dp,infos]=fct_booth(xx,dim)

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
    if size(xx,3)>2
        error('La fonction Booth est une fonction de deux variables');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format varibale entr�e fct Booth');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    p = (xxx+2*yyy-7).^2+(2*xxx+yyy-5).^2;
    
    
    if nargout==2||dem
        dp(:,:,1)=2*(xxx+2*yyy-7)+4*(2*xxx-yyy-5);
        dp(:,:,2)=4*(xxx+2*yyy-7)+2*(2*xxx-yyy-5);
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
    infos.min_glob.Z=0;
    infos.min_glob.X=[1 3];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Booth')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Booth')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Booth')
end
end