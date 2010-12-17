%% Affichage des intervalles de confiance 
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function affichage_ic(X,ic,aff)
if aff.newfig
    figure;
end

hold on;
hs=area(X,ic.sup,min(ic.inf));
hi=area(X,ic.inf,min(ic.inf));
set(hs(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
set(hi(1),'FaceColor',[1 1 1],'EdgeColor','none')
hold off
                    