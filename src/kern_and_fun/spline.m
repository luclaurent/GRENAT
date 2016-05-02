%% Fonction: spline
%% L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@cnam.fr

function G=spline(xx,theta)

if nargout==2
    deriv=true;
else
    deriv=false;
end
%verification de la dimension du parametre interne
lt=length(theta);
d=size(xx,2);


if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta,1,d);
elseif lt~=d
    error('mauvaise dimension deu parametre interne');
end

%calcul de la valeur de la fonction au point xx
td=theta.*abs(xx);
sp=zeros(1,d);
for kk=1:d
    
    if (0<=td(kk) && td(kk)<=0.2)
        sp(kk)=1-15*td(kk)^2+30*td(kk)^3;
    elseif (0.2<=td(kk) && td(kk)<=1)
        sp(kk)=1.25*(1-td(kk))^3;
    else
        sp(kk)=0;
    end
end

ev=prod(sp,2);

%Evaluation ou drrivre
if ~deriv
    G=ev;
else 
    evd=zeros(1,d);
    for kk=1:size(td,1)
        if (0<=td(kk) && td(kk)<=0.2)
            evd(kk)=(-30*td(kk)+90*td(kk)^2).*sign(xx).*theta;
        elseif (0.2<=td(kk) && td(kk)<=1)
            evd(kk)=3.75*(1-td(kk))^2.*sign(xx).*theta;
        else
            evd(kk)=0;
        end
    end
    %for
        
    %end
else
    error('Mauvais argument de la fonction spline.m');
end  

end

