%fonction Ackley
%L. LAURENT -- 16/05/2012 -- laurent@lmt.ens-cachan.fr

%nombruex minimums locaux
%1 minimum global: x=(0,0,...,0) >> f(x)=0

%domaine d'étude -2<xi<2 (recherche large -15<xi<30)

function [p,dp]=fct_ackley(xx)

a=20;
b=0.2;
c=2*pi;
d=5.7;

%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    
    if size(xx,2)==2
        xxx=xx(:,1);yyy=xx(:,2);
    elseif size(xx,1)==2
        xxx=xx(:,2);yyy=xx(:,1);
    else
        error('Mauvais format variable entrée fct Rastrigin');
    end
    norme=sqrt(xxx.^2+yyy.^2);
    ex1=exp(-b*norme/sqrt(2));
    ex2=exp(1/2*(cos(c*xxx)+cos(c*yyy)));
    p=-a*ex1-ex2+a+exp(1);%+d
    if nargout==2
        dp(:,:,1)=a*b/sqrt(2)*xxx/norme*ex1+1/2*c*sin(c*xxx)*ex2;
        dp(:,:,2)=a*b/sqrt(2)*yyy/norme*ex1+1/2*c*sin(c*yyy)*ex2;
    end
    
else
    norme=sqrt(sum(xx.^2,3));
    ex1=exp(-b*norme/sqrt(nbvar));
    sco=sum(cos(c*xx),3);
    ex2=exp(1/nbvar*sco);
    p=-a*ex1-ex2+a+exp(1);%+d 
    if nargout==2
        dp=zeros(size(xx));
        for ii=1:nbvar
            dp(:,:,ii)=a*b*1/sqrt(nbvar)*xx(:,:,ii)./norme.*ex1+c/nbvar*sin(c*xx(:,:,ii)).*ex2;
        end
    end
    
end

end

