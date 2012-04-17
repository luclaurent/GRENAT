%fonction Rastrigin
%L. LAURENT -- 21/02/2012 -- laurent@lmt.ens-cachan.fr

%nombreux minimums locaux
%1 minimum global: x=(0,0,...,0) >> f(x)=0

%domaine d'étude -5.12<xi<5.12

%[TZ89] A. Törn and A. Zilinskas. "Global Optimization". Lecture Notes in Computer Science, Nº 350, Springer-Verlag, Berlin,1989.
%[MSB91] H. Mühlenbein, D. Schomisch and J. Born. "The Parallel Genetic Algorithm as Function Optimizer ". Parallel Computing, 17, pages 619-632,1991.

function [p,dp]=fct_rastrigin(xx)

coef=10;

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
    p=coef*2+xxx.^2-coef*cos(2*pi*xxx)+yyy.^2-coef*cos(2*pi*yyy);
    if nargout==2
        dp(:,:,1)=2*xxx+2*coef*pi*sin(2*pi*xxx);
        dp(:,:,2)=2*yyy+2*coef*pi*sin(2*pi*yyy);
    end
    
else
    cal=xx.^2-coef*cos(2*pi*xx);
    p=coef*nbvar+sum(cal,3);
    
    if nargout==2
        dp=2*xx+2*coef*pi*sin(2*pi*xx);
    end
    
end

end

