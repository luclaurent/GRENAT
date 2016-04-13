%% Initialization of display variables
%% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function aff_def=init_aff()

    aff_def.scale=true;             %scale for displaying gradients
    aff_def.tikz=false;             %save on tikz's format
    aff_def.on=false;               %affichage actif ou non
    aff_def.d3=false;               %affichage 3D
    aff_def.d2=false;               %affichage 2D
    aff_def.contour=false;          %affichage contour
    aff_def.save=true;              %sauvegarde de ts les traces
    aff_def.grad_meta=false;        %affichage des gradients du metamodele
    aff_def.grad_eval=false;        %affichage des gradients evalues
    aff_def.ic.on=false;            %affichage des IC actif ou non
    aff_def.ic.type='0';            %affichage des intervalles de confiance
    aff_def.newfig=true;            %affichage des figures comme nouvelles figure
    aff_def.opt=[];                 %options de traces
    aff_def.uni=false;              %affichage en couleur uni (2D)
    aff_def.color=[];               %couleur d'affichage    
    aff_def.xlabel='x_1';           %nom abscisse
    aff_def.ylabel='x_2';           %nom ordonn*ee
    aff_def.zlabel='';              %nom cote
    aff_def.titre='';               %titre figure
    aff_def.rendu=false;            %rendu de l'affichage 3D
    aff_def.pts=false;              %affichage des points d'evaluation
    aff_def.num=0;                  %numérotation affichage
    aff_def.save=false;             %sauvegarde des donnees
    aff_def.tex=true;               %sauvegarde des données dans le fichier TeX
    aff_def.bar=false;              %affichage des réponses sous forme de barre
    aff_def.trans=false;            %affichage surface en transparence
    aff_def.nbele=Inf;              %nombre d'elements grille de reference reguliere
    aff_def.pas=0;                  %pas de la grille de reference reguliere 
if nargout==0
    global aff
    aff
    aff=aff_def;
    aff
end
