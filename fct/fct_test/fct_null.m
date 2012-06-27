% Fonction nulle
% L. LAURENT -- 20/10/2011 --

function [p,dp,infos]=fct_null(xx,dim)
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
%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entr�e fct Rosenbrock');
    end
    p=zeros(size(xxx));
    if nargout==2
        dp(:,:,1)=p;
        dp(:,:,2)=p;
    end

else
    p=zeros(size(xx(:,:,1)));
    if nargout==2||dem
        dp(:,:,1)=p;
        dp(:,:,2)=p;
    end
end
else
    nbvar=dim;
    p=[];
    dp=[];
end
%sortie informations sur la fonction
if nargout==3
    pts=NaN;
    infos.min_glob.X=NaN;
    infos.min_glob.Z=NaN;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Null')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Null')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Null')
    p=[];
end
end