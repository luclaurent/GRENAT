%fonction Rastrigin
%L. LAURENT -- 21/02/2012 -- luc.laurent@lecnam.net

%nombreux minimums locaux
%1 minimum global: x=(0,0,...,0) >> f(x)=0

%domaine d'etude -5.12<xi<5.12

%[TZ89] A. T\¨orn and A. Zilinskas. "Global Optimization". Lecture Notes in Computer Science, No 350, Springer-Verlag, Berlin,1989.
%[MSB91] H. M\¨uhlenbein, D. Schomisch and J. Born. "The Parallel Genetic Algorithm as Function Optimizer ". Parallel Computing, 17, pages 619-632,1991.

function [p,dp,infos]=fct_rastrigin(xx,dim)

coef=10;
% pour demonstration
dem=false;
if nargin==0
    pas=50;
    borne=5.12;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    %Nombre de variables
    nbvar=size(xx,3);
    
    if nbvar==1
        
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format variable entree fct Rastrigin');
        end
        p=coef*2+xxx.^2-coef*cos(2*pi*xxx)+yyy.^2-coef*cos(2*pi*yyy);
        if nargout==2||dem
            dp(:,:,1)=2*xxx+2*coef*pi*sin(2*pi*xxx);
            dp(:,:,2)=2*yyy+2*coef*pi*sin(2*pi*yyy);
        end
        
    else
        cal=xx.^2-coef*cos(2*pi*xx);
        p=coef*nbvar+sum(cal,3);
        
        if nargout==2||dem
            dp=2*xx+2*coef*pi*sin(2*pi*xx);
        end
        
    end
else
    nbvar=dim;
    p=[];
    dp=[];
end
%sortie informations sur la fonction
if nargout==3
    pts=zeros(1,nbvar);
    infos.min_glob.X=pts;
    infos.min_glob.Z=0;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demonstration
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Rastrigin')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Rastrigin')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Rastrigin')
    p=[];
end

end


