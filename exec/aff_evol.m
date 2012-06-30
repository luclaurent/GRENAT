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
%type de graphe 'semilogy' 'semilogx' 'plot' 'stairs...
type=opt_plot.type;
%bornes graphe
bornes=opt_plot.bornes;

%initialisation du graphe
if init
    hold on
    if ~isempty(bornes)
        set(gca,'xlim',bornes,'XGrid','on','YGrid','on')
    end
    xlabel(labelx)
    ylabel(labely)
    %trace graphe
    idd=feval(type,X,Y,'k');
    plot(X,Y,'.k')
    %trace de la cible
    if ~isempty(cible)
        ext_bornes_x=get(gca,'xlim');
        plot(ext_bornes_x,cible*ones(1,2),'LineWidth',2,'Color','r');
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
    hold off
else
    %evolution du graphe en enrichissement
    id_graph=findobj(get(id_plot,'Children'),'Tag',tag);
    %ajout nouveaux elements
    set(id_graph,'LineStyle','None')
    xdat=get(id_graph,'Xdata');
    ydat=get(id_graph,'Ydata');
    if iscell(xdat)
        newX=[xdat{1} X];
        newY=[ydat{1} Y];
    else
        newX=[xdat X];
        newY=[ydat Y];
    end
    %Mise a jour du graphe
    hold(id_plot)
    idd=feval(type,id_plot,newX,newY,'k');
    idd=plot(id_plot,newX,newY,'.k');
    set(idd,'Tag',tag);
    %affectation nom au graphe
    
    
    %set(id_graph,'Xdata',newX,'Ydata',newY)
    %trace de la cible
    if ~isempty(cible)
        ext_bornes_x=get(id_plot,'xlim');
        plot(id_plot,ext_bornes_x,cible*ones(1,2),'LineWidth',2,'Color','r');
        ext_bornes_y=get(id_plot,'ylim');
        new_bornes_y=ext_bornes_y;
        if ext_bornes_y(1)==cible
            new_bornes_y(1)=new_bornes_y(1)-0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(id_plot,new_bornes_y)
        elseif ext_bornes_y(2)==cible
            new_bornes_y(2)=new_bornes_y(2)+0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(id_plot,new_bornes_y)
        end
    end
    xlabel(id_plot,labelx)
    ylabel(id_plot,labely)
    title(id_plot,titre)
    drawnow
    hold off
end

end