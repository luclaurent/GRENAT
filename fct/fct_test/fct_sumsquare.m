%Fonction Sum Square
%modif L. LAURENT -- 16/09/2011 -- ajout calcul gradient

%minimum global: f(xi)=0 pour (x1,x2,x3,x4)=(0,...,0)

%Domaine d'etude de la fonction: -10<xi<10 

function [p,dp] = fct_sumsquare(xx)


%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    error('Mauvais format variable entrée fct Sum Square');
else
    nu(1,1,:)=1:nbvar;
    cal=nu.*xx.^2;
    p=sum(cal,3);
    
    if nargout==2
        dp=2*nu.*xx;
    end
    
end
end