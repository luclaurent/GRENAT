%fonction peaks
%L. LAURENT -- 12/05/2010 -- luc.laurent@ens-cachan.fr
%modif le 16/09/2011 -- modif �criture input pour passage code � n
%variables

function [p,dp,infos]=fct_peaks(xx,dim)
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
    
    if size(xx,3)>2
        error('La fonction Peaks est une fonction de deux variables');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format varibale entr�e fct Peaks');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    p =  3*(1-xxx).^2.*exp(-(xxx.^2) - (yyy+1).^2) ...
        - 10*(xxx/5 - xxx.^3 - yyy.^5).*exp(-xxx.^2-yyy.^2) ...
        - 1/3*exp(-(xxx+1).^2 - yyy.^2);
    
    if nargout==2||dem
        dp(:,:,1)=-6*(1-xxx).*exp(-(xxx.^2) - (yyy+1).^2)...
            -6*xxx.*(1-xxx).^2.*exp(-xxx.^2-(yyy+1).^2) ...
            -10*(1/5-3*xxx.^2).*exp(-xxx.^2-yyy.^2)...
            +20*(xxx/5-xxx.^3-yyy.^5).*xxx.*exp(-xxx.^2-yyy.^2)...
            +2/3*(xxx+1).*exp(-(xxx+1).^2-yyy.^2);
        dp(:,:,2)=-6*(1-xxx).^2.*(yyy+1).*exp(-xxx.^2-(yyy+1).^2)...
            +50*yyy.^4.*exp(-xxx.^2-yyy.^2)...
            +20*yyy.*(xxx/5-xxx.^3-yyy.^5).*exp(-xxx.^2 -yyy.^2)...
            +2/3*yyy.*exp(-(xxx+1).^2-yyy.^2);
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
    xlabel('x'), ylabel('y'), title('Peaks')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Peaks')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Peaks')
    p=[];
end

end