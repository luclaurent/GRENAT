%fonction peaks
%L. LAURENT -- 12/05/2010 -- luc.laurent@ens-cachan.fr
%modif le 16/09/2011 -- modif écriture input pour passage code à n
%variables

function [p,dp]=fct_peaks(xx)

if size(xx,3)>2
    error('La fonction Peaks est une fonction de deux variables');
elseif size(xx,3)==1
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format varibale entrée fct Peaks');
    end
    
else
    xxx=xx(:,:,1);yyy=xx(:,:,2);
end

p =  3*(1-xxx).^2.*exp(-(xxx.^2) - (yyy+1).^2) ...
    - 10*(xxx/5 - xxx.^3 - yyy.^5).*exp(-xxx.^2-yyy.^2) ...
    - 1/3*exp(-(xxx+1).^2 - yyy.^2);

if nargout==2
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


end