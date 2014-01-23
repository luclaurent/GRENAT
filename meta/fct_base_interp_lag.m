%fonction de détermination des fonctions de base d'interpolation
%polynomiale de Lagrange
% L. LAURENT -- 03/06/2011 -- laurent@lmt.ens-cachan.fr

function [h,dh]=fct_base_interp_lag(x,var)
% decalaration variables
h=zeros(length(var),length(x));
if nargout==2
    dh=h;
end

% en tous les points de l'espace
for itp=1:length(x)
    
    % en tous les points evalues
    for ite=1:length(var)
        ind=find(var~=var(ite));
        pol=(x(itp)-var(ind))./(var(ite)-var(ind));
        h(ite,itp)=prod(pol);
        
        if nargout==2
            dd=0;
            for jj=1:length(var)
                ind=find(var~=var(ite)&var~=var(jj));
                dpol=(x(itp)-var(ind))./(var(ite)-var(ind));
                hh=prod(dpol);
                if jj~=ite
                    dd=dd+1/(var(ite)-var(jj))*hh;
                end
            end
            dh(ite,itp)=dd;
        end
    end
end




