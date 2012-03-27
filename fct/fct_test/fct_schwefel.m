%fonction Schwefel
%L. LAURENT -- 26/01/2011 -- luc.laurent@ens-cachan.fr
%modif le 16/09/2011 -- modif écriture input pour passage code à n
%variables

%nombreux minimums locaux
%1 minimum global: x=(1,1,...,1) >> f(x)=0

%domaine d'étude -500<xi<500

function [p,dp]=fct_schwefel(xx)

coef=418.9829;

%Nombre de variables
nbvar=size(xx,3);

if nbvar==1
    if nargout==2
        
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error('Mauvais format variable entrée fct Schwefel');
        end
        cal=xxx.*sin(sqrt(abs(xxx)))+yyy.*sin(sqrt(abs(yyy)));
        p=coef*nbvar-cal;
        if nargout==2
            dp(:,:,1)=-sin(sqrt(abs(xxx)))-xxx.*sign(xxx).*cos(sqrt(abs(xxx)))./(2*sqrt(abs(xxx)));
            dp(:,:,2)=-sin(sqrt(abs(yyy)))-xxx.*sign(yyy).*cos(sqrt(abs(yyy)))./(2*sqrt(abs(yyy)));
        end
    end
    
else
    cal=xx.*sin(sqrt(abs(xx)));
    p=coef*nbvar-sum(cal,3);
    
    if nargout==2
        dp=-sin(sqrt(abs(xx)))-xx.*sign(xx).*cos(sqrt(abs(xx)))./(2*sqrt(abs(xx)));
    end
    
end

end

