%fonction de determination des fonctions de base d'interpolation lineaire
%par morceaux
%% L. LAURENT -- 03/06/2011 -- laurent@lmt.ens-cachan.fr

function [h,dh]=fct_base_interp_lin(x,var)
% decalaration variables
h=zeros(length(var),length(x));
if nargout==2
    dh=h;
end

% en tous les points de l'espace
for itp=1:length(x)
    
    % en tous les points evalues
    for ite=1:length(var)
        %%traitement suivant les differents cas de figure
        if ite==1
            if (x(itp)>=var(ite)&&x(itp)<=var(ite+1))
                h(ite,itp)=1-(x(itp)-var(ite))/(var(ite+1)-var(ite));
                if nargout==2
                    dh(ite,itp)=-1/(var(ite+1)-var(ite));
                end                
            elseif (x(itp)<=var(ite))
                h(ite,itp)=1;
                if nargout==2
                    dh(ite,itp)=0;
                end                
            else
                h(ite,itp)=0;
                if nargout==2
                    dh(ite,itp)=0;
                end                
            end            
            
        elseif ite==length(var)
            if (x(itp)>=var(ite-1)&&x(itp)<=var(ite))
                h(ite,itp)=(x-var(ite-1))/(var(ite)-var(ite-1));
                if nargout==2
                    dh(ite,itp)=1/(var(ite)-var(ite-1));
                end                
            elseif (x(itp)>=var(ite))
                h(ite,itp)=1;
                if nargout==2
                    dh(ite,itp)=0;
                end                
            else
                h(ite,itp)=0;
                if nargout==2
                    dh(ite,itp)=0;
                end                
            end
            
        else
            if (x(itp)<=var(ite-1)||x(itp)>=var(ite+1))
                h(ite,itp)=0;
                if nargout==2
                    dh(ite,itp)=0;
                end
                
            elseif (x(itp)>=var(ite-1)&&x(itp)<=var(ite))
                h(ite,itp)=(x(itp)-var(ite-1))/(var(ite)-var(ite-1));
                if nargout==2
                    dh(ite,itp)=1/(var(ite)-var(ite-1));
                end
                
            elseif (x(itp)>=var(ite)&&x(itp)<=var(ite+1))
                h(ite,itp)=1-(x-var(ite))/(var(ite+1)-var(ite));
                if nargout==2
                    dh(ite,itp)=-1/(var(ite+1)-var(ite));
                end                
            end
        end
    end
end
