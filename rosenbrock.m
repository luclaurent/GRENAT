%Fonction de Rosenbrock

function ros = rosenbrock(xx,yy)
if(size(xx,1)~=1&&size(xx,2)~=1)
    ros=100.*(yy-xx.^2).^2 + (1 - xx).^2;
else
    ros=100.*(yy-xx.^2).^2 + (1 - xx).^2;
end


end

