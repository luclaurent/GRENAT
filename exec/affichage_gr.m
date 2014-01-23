%fonction réalisant l'affichage des gradient des métamodèles
%L. LAURENT  -- 12/04/2010 -- luc.laurent@ens-cachan.fr

function affichage_gr(X,Y,Z,GR1,GR2,aff)
if aff.on
    if aff.grad
        figure;
       [C,h]=contourf(X,Y,Z);       
       set(h,'LineWidth',2)

       hold on;
       quiver(X,Y,GR1,GR2);
       text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
        'Edgecolor',[.7 .7 .7])
    end
end
end