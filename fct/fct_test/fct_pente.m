% Fonction pente
% L. LAURENT -- 15/12/2011 --

function [p,dp,infos]=fct_pente(xx,dim)

%pente dans la direction
dir=2;


% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=5;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    %Nombre de variables
    nbvar=size(xx,3);
    
    %valeur constant
    val=10;
    
    if nbvar==1
        
        p=val*xx(:,dir);
        if nargout==2
            
            dp(:,:,1)=0*p;
            dp(:,:,2)=0*p;
            dp(:,:,dir)=val*ones(size(p));
        end
        
    else
        p=val*xx(:,:,dir);
        if nargout==2||dem
            dp=zeros(size(xx));
            dp(:,:,dir)=val*ones(size(p));
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
    xlabel('x'), ylabel('y'), title('Pente')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Pente')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Pente')
    p=[];
end

end