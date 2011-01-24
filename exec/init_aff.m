%% Initialisation des variables d'affichage
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function aff=init_aff()

    aff.scale=true;            %mise a  l'echelle (affichage gradients)
    aff.tikz=false;             %sauvegarde au format Tikz
    aff.num=0;                  %iterateur numeros figures
	aff.doss=[];                %dossier de sauvegarde (figures)
    aff.on=false;               %affichage actif ou non
    aff.d3=false;               %affichage 3D
    aff.d2=false;               %affichage 2D
    aff.contour3=false;         %affichage contour sur courbes/surfaces 3D
    aff.contour2=false;         %affichage contour en 2D (sur le plan)
    aff.save=false;             %sauvegarde de ts les traces
    aff.grad_meta=false;        %affichage des gradients du metamodele
    aff.grad_eval=false;        %affichage des gradients evalues
    aff.ic.on=false;            %affichage des IC actif ou non
    aff.ic.type='0';            %affichage des intervalles de confiance
    aff.newfig=true;            %affichage des figures comme nouvelles figure
    aff.opt=[];                 %options de traces
    aff.uni=false;              %affichage en couleur uni (2D)
    aff.color=[];               %couleur d'affichage    
    aff.xlabel='';              %nom abscisse
    aff.ylabel='';              %nom ordonn*ee
    aff.zlabel='';              %nom cote
    aff.titre='';               %titre figure
    aff.rendu=false;            %rendu de l'affichage 3D
    aff.pts=false;              %affichage des points d'evaluation