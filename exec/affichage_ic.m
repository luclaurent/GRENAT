%% Affichage des intervalles de confiance 
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function affichage_ic(X,ic,aff)
if aff.newfig
    figure;
end

%en dimension 1
if (size(X,1)==1 | size(X,2)==1) & size(X,3)==1
    hold on;
    hs=area(X,ic.sup,min(ic.inf));
    hi=area(X,ic.inf,min(ic.inf));
    set(hs(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
    set(hi(1),'FaceColor',[1 1 1],'EdgeColor','none')
    hold off
else
    XX=X(:,:,1);
    YY=X(:,:,2);
    surf(XX,YY,ic.sup)
    hold on
    surf(XX,YY,ic.inf)
    hold off
    title(aff.titre)
    xlabel(aff.xlabel)
    ylabel(aff.ylabel)
    zlabel(aff.zlabel)
end
                    