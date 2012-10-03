%fonction Schwefel
%L. LAURENT -- 26/01/2011 -- luc.laurent@ens-cachan.fr
%modif le 16/09/2011 -- modif �criture input pour passage code � n
%variables

%nombreux minimums locaux
%1 minimum global: x=(1,1,...,1) >> f(x)=0

%domaine d'etude -500<xi<500

function [p,dp,infos]=fct_schwefel(xx,dim)

coef=418.9829;
% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=500;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    %Nombre de variables
    nbvar=size(xx,3);
    
    if nbvar==1
        if nargout==2
            
            if size(xx,2)==2
                xxx=xx(:,1);yyy=xx(:,2);
            elseif size(xx,1)==2
                xxx=xx(:,2);yyy=xx(:,1);
            else
                error('Mauvais format variable entr�e fct Schwefel');
            end
            cal=xxx.*sin(sqrt(abs(xxx)))+yyy.*sin(sqrt(abs(yyy)));
            p=coef*nbvar-cal;
            if nargout==2||dem
                dp(:,:,1)=-sin(sqrt(abs(xxx)))-xxx.*sign(xxx).*cos(sqrt(abs(xxx)))./(2*sqrt(abs(xxx)));
                dp(:,:,2)=-sin(sqrt(abs(yyy)))-xxx.*sign(yyy).*cos(sqrt(abs(yyy)))./(2*sqrt(abs(yyy)));
            end
        end
        
    else
        cal=xx.*sin(sqrt(abs(xx)));
        p=coef*nbvar-sum(cal,3);
        
        if nargout==2||dem
            dp=-sin(sqrt(abs(xx)))-xx.*sign(xx).*cos(sqrt(abs(xx)))./(2*sqrt(abs(xx)));
        end
        
    end
else
    nbvar=dim;
    p=[];
    dp=[];
end
%sortie informations sur la fonction
if nargout==3
    pts=ones(1,nbvar);
    infos.min_glob.X=pts;
    cal=pts(:,1).*sin(sqrt(abs(pts(:,1))))+pts(:,2).*sin(sqrt(abs(pts(:,2))));
    infos.min_glob.Z=coef*nbvar-cal;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Schwefel')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Schwefel')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Schwefel')
    p=[];
end

end
