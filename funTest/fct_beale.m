%fonction Beale
%L. LAURENT -- 16/09/2011 -- luc.laurent@lecnam.net

%minimum global: f(x1,x2)=0 pour (x1,x2)=(3,-0.5)

%Domaine d'etude de la fonction: -4.5<x1<4.5, -4.5<x<4.5
function [p,dp,infos]=fct_beale(xx,dim)


% pour demonstration
dem=false;
if nargin==0
    pas=50;
    [x,y]=meshgrid(linspace(-2,2,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end

if ~isempty(xx)
    if size(xx,3)>2
        error('La fonction Beale est une fonction de deux variables');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format varibale entr�e fct Beale');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    p = (1.5 - xxx + xxx.*yyy).^2 + (2.25 - xxx + xxx.*yyy.^2).^2 + (2.625 - xxx + xxx.*yyy.^3).^2;
    
    
    if nargout==2||dem
        dp(:,:,1)=2*(yyy-1).*(1.5-xxx+xxx.*yyy)+...
            2*(yyy.^2-1).*(2.25 - xxx + xxx.*yyy.^2) +...
            2*(yyy.^3-1).*(2.625 - xxx + xxx.*yyy.^3);
        dp(:,:,2)=2*xxx.*(1.5-xxx+xxx.*yyy)+...
            4*xxx.*yyy.*(2.25 - xxx + xxx.*yyy.^2) +...
            6*xxx.*yyy.^2.*(2.625 - xxx + xxx.*yyy.^3);
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
    infos.min_glob.X=[3 0.5];
    infos.min_loc.Z=0;
    infos.min_loc.X=[3 0.5];
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Beale')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Beale')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Beale')
end
end

