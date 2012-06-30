%% Procedure assurant l'affichage de l'evolution des grandeurs lors des iterations d'enrichissement ou d'optimisation
%% L. LAURENT -- 29/06/2012 -- laurent@lmt.ens-cachan.fr

function aff_evol(X,Y,opt_plot,id_plot)

%test si initialisation ou en phase d'iterations
init=false;
if isempty(id_plot)
    init=true;
end

%tag pour identification graphe
tag=opt_plot.tag;
%titre graphe
titre=opt_plot.title;
%labels axes
labelx=opt_plot.xlabel;
labely=opt_plot.ylabel;
%valeur cible
cible=opt_plot.cible;
%type de graphe 'semilogy' 'semilogx' 'plot'...
type=opt_plot.type;
%bornes graphe
bornes=opt_plot.bornes;

%initialisation du graphe
if init
    hold on
    if ~isempty(bornes)
        set(gca,'xlim',bornes)
    end
    xlabel(labelx)
    ylabel(labely)
    %trace graphe
    switch type
        
        case 'semilogy'
            idd=semilogy(X,Y,'.k');
        case 'semilogx'
            idd=semilogx(X,Y,'.k');
        otherwise
            idd=plot(X,Y,'.k');
    end
    %trace de la cible
    if ~isempty(cible)
        ext_bornes_x=get(gca,'xlim');
        line(ext_bornes_x,cible*ones(1,2),'LineWidth',2,'Color','r');
        ext_bornes_y=get(gca,'ylim');
        new_bornes_y=ext_bornes_y;
        if ext_bornes_y(1)==cible
            new_bornes_y(1)=new_bornes_y(1)-0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(new_bornes_y)
        elseif ext_bornes_y(2)==cible
            new_bornes_y(2)=new_bornes_y(2)+0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(new_bornes_y)
        end
    end
    %affectation nom au graphe
    set(idd,'Tag',tag);
    title(titre)
    drawnow
else
    %evolution du graphe en enrichissement
    id_graph=get(id_plot,'Children');
    %ajout nouveaux elements
    
    get(id_graph,'Xdata')
    if ~isempty(cible)
        indice=2;
    else
        indice=1;
    end
    set(id_graph,'LineStyle','None')
    xdat=get(id_graph,'Xdata');
    ydat=get(id_graph,'Ydata');
    newX=[xdat{indice} X];
    newY=[ydat{indice} Y];
    %Mise a jour du graphe
    set(id_graph,'Xdata',newX,'Ydata',newY)
    %trace de la cible
    if ~isempty(cible)
        ext_bornes_x=get(gca,'xlim');
        line(ext_bornes_x,cible*ones(1,2),'LineWidth',2,'Color','r');
        ext_bornes_y=get(gca,'ylim');
        new_bornes_y=ext_bornes_y;
        if ext_bornes_y(1)==cible
            new_bornes_y(1)=new_bornes_y(1)-0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(new_bornes_y)
        elseif ext_bornes_y(2)==cible
            new_bornes_y(2)=new_bornes_y(2)+0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(new_bornes_y)
        end
    end
    drawnow
end

end