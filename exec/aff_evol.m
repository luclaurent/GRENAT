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
%echelle log
ech_log=opt_plot.ech_log;

%initialisation du graphe
if init
    hold on
    if ~isempty(bornes)
        set(gca,'xlim',bornes,'XGrid','on','YGrid','on')
        if ech_log; set(gca,'Yscale','log');end
    end
    xlabel(labelx)
    ylabel(labely)
    %trace graphe
    idd=feval(type,X,Y,'.k');
    idd=plot(X,Y,'sr','MarkerSize',2);
    %trace de la cible
    if ~isempty(cible)
        ext_bornes_x=get(gca,'xlim');
        plot(ext_bornes_x,cible*ones(1,2),'LineWidth',2,'Color','r');
        warning off all
        ext_bornes_y=get(gca,'ylim');
        new_bornes_y=ext_bornes_y;
        if ext_bornes_y(1)==cible
            new_bornes_y(1)=new_bornes_y(1)-0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(new_bornes_y)
        elseif ext_bornes_y(2)==cible
            new_bornes_y(2)=new_bornes_y(2)+0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            ylim(new_bornes_y)
        end
        warning on all
    end
    %affectation nom au graphe
    set(idd,'Tag',tag);
    warning off all
    title(titre)
    drawnow
    warning on all
    %hold off
else
    %evolution du graphe en enrichissement
    id_graph=findobj(get(id_plot,'Children'),'Tag',tag);
    %ajout nouveaux elements
    %set(id_graph,'LineStyle','None')
    xdat=get(id_graph,'Xdata');
    ydat=get(id_graph,'Ydata');
    
    if iscell(xdat)
        newX=[xdat{1} X];
        newY=[ydat{1} Y];
        yy=horzcat(ydat{:});
        maxY=max(yy(:));
        minY=min(yy(:));
        xx=horzcat(xdat{:});
        maxX=max(xx(:));
        minX=min(xx(:));
    else
        newX=[xdat X];
        newY=[ydat Y];
        maxY=max(max(ydat));
        minY=min(min(ydat));
        maxX=max(max(xdat));
        minX=min(min(xdat));
    end
    %Mise a jour du graphe
    idd=feval(type,id_plot,newX,newY,'k');
    %hold on
    %affectation nom au graphe
    set(idd,'Tag',tag);
    plot(id_plot,newX,newY,'ok','MarkerSize',2);
    ext_bornes_x=get(id_plot,'xlim');
    maxX=max([maxX,newX,ext_bornes_x]);
    minX=min([minX,newX,ext_bornes_x]);
    %trace de la cible
    if ~isempty(cible)
        maxY=max([maxY,cible]);
        minY=min([minY,cible]);
        warning off all        
        plot(id_plot,[minX maxX],cible*ones(1,2),'LineWidth',2,'Color','r');
        ext_bornes_y=get(id_plot,'ylim');
        new_bornes_y=ext_bornes_y;
        if ext_bornes_y(1)==cible
            if ech_log
                new_bornes_y(1)=new_bornes_y(1)-eps;
            else
            new_bornes_y(1)=new_bornes_y(1)-0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            end
        elseif ext_bornes_y(2)==cible
            if ech_log
                new_bornes_y(2)=new_bornes_y(2)+eps;
            else                
                new_bornes_y(2)=new_bornes_y(2)+0.2*abs(new_bornes_y(2)-new_bornes_y(1));
            end
        end
        warning on all
    else
        new_bornes_y=[];
    end
    if ech_log
        new_bornes_y=new_bornes_y(new_bornes_y>0);
    end
    maxY=max([maxY,newY,new_bornes_y]);
    minY=min([minY,newY,new_bornes_y]);

    ylim(id_plot,[minY maxY])
    xlim(id_plot,[minX maxX])
    xlabel(id_plot,labelx)
    ylabel(id_plot,labely)
    title(id_plot,titre)
    drawnow
    %hold off
end

end