%Fonction Sphere
%modif L. LAURENT -- 16/09/2011 -- ajout calcul gradient


%minimum global: f(xi)=0 pour (x1,x2,x3,x4)=(0,...,0)

%Domaine d'etude de la fonction: -10<xi<10 


function [p,dp] = fct_sphere(xx)

%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    error('Mauvais format variable entrée fct Sphere');
else
    cal=xx.^2;
    p=sum(cal,3);
    
    if nargout==2
        dp=2*xx;
    end
    
end
end