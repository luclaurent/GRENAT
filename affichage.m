%%fonction réalisant l'affichage des surfaces de réponse
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr


function status=affichage(X,Y,Z,tirages,eval,aff)
if aff.on
    if aff.newfig
        figure;
    else
        hold on
    end

    if aff.contour
        if aff.uni          
            surfc(X,Y,Z,'FaceColor',aff.color,'EdgeColor',aff.color)
        else
            surfc(X,Y,Z)
        end
    else
        if aff.uni          
            surf(X,Y,Z,'FaceColor',aff.color,'EdgeColor',aff.color)
        else
            surf(X,Y,Z)
        end
    end

    if aff.rendu
        hlight=light;              % activ. éclairage
        lighting('gouraud')        % type de rendu
        lightangle(hlight,48,70) % dir. éclairage
    end

    if aff.pts
        hold on
        plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                'MarkerFaceColor','g',...
                'MarkerSize',15)
     
    end
    title(aff.titre);
    xlabel(aff.xlabel);
    ylabel(aff.ylabel);
    zlabel(aff.zlabel);
    view(3)
    
    
end
end
