%Fonction de Rosenbrock 
%modif L. LAURENT -- 12/05/2010 -- ajout calcul gradient

function [ros,dros1,dros2] = fct_rosenbrock(xx,yy)
if(size(xx,1)~=1&&size(xx,2)~=1)
    ros=100.*(yy-xx.^2).^2 + (1 - xx).^2;
else
    ros=100.*(yy-xx.^2).^2 + (1 - xx).^2;
end

if nargout==3
    dros1=-400.*xx.*(yy-xx.^2)-2*(1-xx);
    dros2=200*(yy-xx.^2);
end

end