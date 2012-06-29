%% Procedure assurant l'affichage de l'evolution des grandeurs lors des iterations d'enrichissement ou d'optimisation
%% L. LAURENT -- 29/06/2012 -- laurent@lmt.ens-cachan.fr

function aff_evol(X,Y,opt_plot,iterate)

%test si initialisation ou en phase d'iterations
init=false;
if iterate==1
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
cible.opt_plot.cible;
%type de graphe 'semilogy' 'semilogx' 'plot'...
type=opt_plot.type;
%bornes graphe
bornes=opt_plot.bornes;

%initialisation du graphe
if init
    if ~isempty(bornes)
        set(gca,'xlim',bornes)
    end
    xlabel(labelx)
    ylabel(labely)
    %trace graphe
    id_graph=plot(X,Y,'.k')
    %affectation nom au graphe
    set(id_graph,'Tag',tag);
    title(titre)
else
    %evolution du graphe en enrichissement
    %recuperation id_graph
    id_graph=finobj(get(gca,'Children'),'Tag',tag);
    %nouveaux elements a tracer
    newX=[get(id_graph,'Xdata') X];
    newY=[get(id_graph,'Ydata') Y];
    %Mise à jour du graphe
    set(id_graph,'Xdata',newX,'Ydata',newY)
end

end