%%fonction realisant l'affichage des surfaces de reponse
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr


function status=affichage(grille,Z,tirages,eval,grad,aff)

%% Parametres d'entree:
%       - grille: grille de tracé (meshgrid en 2D) sous la forme
%       grille(:,:,1) et grille(:,:,2) en 2D pour respectivement les
%       abscisse et ordonnée. En 1D il s'agit juste d'un vecteur de réels
%       obtenu par exemple avec linspace
%       - Z: structure des données à tracer
%           * Z.Z: cotes obtenus au points definis par la grille
%           * Z.GR1 et Z.GR2: composant des gradients calcules aux points
%           definis par la gille
%       - tirages: liste des points tires (par strategie quelconque)
%       - eval: evaluations/cotes obtenus aux points du tirage
%       - grad: gradients obtenus aux points de tirage
%       - aff: structure contenant l'ensemble des options gere par la
%       fonction
%           * aff.on: affichage actif ou non (booleen)
%           * aff.newfig: affichage du trace dans une nouvelle figure
%           (booleen)
%           * aff.grad_meta: affichage des gradients calcules aux points de
%           la grille (issus generalement du metamodele)
%           * aff.grad_eval: affichage des gradients calcules aux points du
%           tirages
%           * aff.d3: affichage graphique 3D (surf quiver3...)
%           * aff.contour3: affichage des lignes de niveaux sur graphiques
%           3D
%           * aff.d2: affichage graphique 2D (plot quiver...)
%           * aff.contour2: affichage des courbes de niveaux en 2D
%           * aff.pts: affichage des points d'evaluation
%           * aff.uni: affichage des surfaces en une couleurs (booleen)
%           * aff.color: couleur choisie
%           * aff.rendu: rendu sur graphique 3D
%           * aff.save: sauvegarde figures en eps et png
%           * aff.tikz: sauvegarde au format Tikz
%           * aff.tex: ecriture du fichier TeX associe
%           * aff.opt: option courbes en 1D
%           * aff.titre: titre figure
%           * aff.xlabel: nom axe x
%           * aff.ylabel: nom axe y
%           * aff.zlabel: nom axe z
%           * aff.scale: mise à l'échelle gradients
%           * aff.doss: dossier de sauvegarde figures
%           * aff.pas: pas de la grille d'affichage

%traitement des cas 1D ou 2D
esp1d=false;esp2d=false;
if size(tirages,2)==1
    esp1d=true;
elseif size(tirages,2)==2
    esp2d=true;
    if size(grille,3)>1
        grille_X=grille(:,:,1);
        grille_Y=grille(:,:,2);
    else
        grille_X=grille(:,1);
        grille_Y=grille(:,2);
    end
else
    error('Mauvaise dimension de l espace de conception');
end

%Affichage actif
if aff.on
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %affichage dans une nouvelle fenetre
    if aff.newfig
        figure;
    else
        hold on
    end
    
    %affichage 2D
    if esp2d
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%mise a� l'echelle des traces de gradients
        if aff.grad_meta||aff.grad_eval
                %calcul norme gradient
                ngr=zeros(size(Z.GR1));
                for ii=1:size(Z.GR1,1)*size(Z.GR1,2)
                    ngr(ii)=norm([Z.GR1(ii) Z.GR2(ii)],2);
                end
                %recherche du maxi de la norme du gradient
                nm=[max(max(Z.GR1)) max(max(Z.GR2))];

                %definition de la taille mini de la grille d'affichage
                if length(aff.pas)==2
                    tailg=aff.pas;
                else
                    tailg(1)=aff.pas;tailg(2)=aff.pas;
                end
                               
                %taille de la plus grande fleche
                para_fl=0.5;
                tailf=para_fl*tailg;

                %echelle
                nm
                tailf
                ech=tailf./nm;
                ech
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %affichage des surfaces 3D
        if aff.d3
            %affichage des contour
            if aff.contour3
                %affichage unicolor
                if aff.uni          
                    surfc(grille_X,grille_Y,Z.Z,'FaceColor',aff.color,'EdgeColor',aff.color)
                else
                    surfc(grille_X,grille_Y,Z.Z)
                end
            else
                if aff.uni          
                    surf(grille_X,grille_Y,Z.Z,'FaceColor',aff.color,'EdgeColor',aff.color)
                else
                    surf(grille_X,grille_Y,Z.Z)
                end
            end
            %affichage des points d'evaluations
            if aff.pts
                hold on
                plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',1);
            end

            %Affichage des gradients
            if aff.grad_eval
                %determination des vecteurs de plus grandes pentes (dans le
                %sens de descente du gradient)
                for ii=1:size(Z.GR1,1)*size(Z.GR1,2)
                    vec.X(ii)=-Z.GR1(ii);
                    vec.Y(ii)=-Z.GR2(ii);
                    vec.Z(ii)=-Z.GR1(ii)^2-Z.GR2(ii)^2;
                    %normalisation du vecteur de plus grande pente
                    vec.N(ii)=sqrt(vec.X(ii)^2+vec.Y(ii)^2+vec.Z(ii)^2);
                    vec.Xn(ii)=vec.X(ii)/vec.N(ii);
                    vec.Yn(ii)=vec.Y(ii)/vec.N(ii);
                    vec.Zn(ii)=vec.Z(ii)/vec.N(ii);
                end
                hold on

               %hcones =coneplot(X,Y,Z.Z,vec.X,vec.Y,vec.Z,0.1,'nointerp');
               % hcones=coneplot(X,Y,Z.Z,Z.GR1,Z.GR2,-ones(size(Z.GR1)),0.1,'nointerp');
               % set(hcones,'FaceColor','red','EdgeColor','none')

                %hold on
                %dimension maximale espace de conception
                dimm=max(abs(max(max(grille_X))-min(min(grille_X))),...
                    abs(max(max(grille_Y))-min(min(grille_Y)))); 
                %dimension espace de reponse
                dimr=abs(max(max(Z.Z))-min(min(Z.Z)));
                %norme maxi du gradient
                nmax=max(max(vec.N));
                quiver3(grille_X,grille_Y,Z.Z,ech*vec.X,ech*vec.Y,ech*vec.Z,...
                    'b','MaxHeadSize',0.1*dimr/nmax,'AutoScale','off')
            end
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %affichage des surfaces 2D (contours)
        if aff.d2
            %affichage des contours
            if aff.contour2
                [C,h]=contourf(grille_X,grille_Y,Z.Z);   
                text_handle = clabel(C,h);
                set(text_handle,'BackgroundColor',[1 1 .6],...
                    'Edgecolor',[.7 .7 .7])
                set(h,'LineWidth',2)
                %affichage des gradients
                if aff.grad_meta                
                    hold on;
                    %remise à l'echelle
                    if aff.scale
                       %quiver(grille_X,grille_Y,ech(1)*Z.GR1,ech(2)*Z.GR2,'AutoScale','off','MaxHeadSize',0.0002);
                       quiver(grille_X,grille_Y,ech(1)*Z.GR1,ech(2)*Z.GR2);
                       %axis equal
                       %ncquiverref(grille_X,grille_Y,ech(1)*Z.GR1,ech(2)*Z.GR2);
                        ech(1)*Z.GR1
                        ech(2)*Z.GR2
                    else
                        quiver(grille_X,grille_Y,Z.GR1,Z.GR2,'AutoScale','off');
                    end
                end
                %affichage des points d'evaluation
                if aff.pts
                    hold on
                    plot(tirages(:,1),tirages(:,2),'.','MarkerEdgeColor','g',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',15)     
                end
                %affichage des gradients
                if aff.grad_eval
                    hold on;
                    %remise à l'echelle
                    if aff.scale
                        quiver(tirages(:,1),tirages(:,2),...
                            ech(1)*grad(:,1),ech(2)*grad(:,2),...
                            'LineWidth',2,'AutoScale','off');

                    else
                        quiver(tirages(:,1),tirages(:,2),...
                            grad(:,1),grad(:,2),...
                            'LineWidth',2,'AutoScale','off');
                    end

                end


            end
        end
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %rendu
        if aff.rendu
            hlight=light;               % activ. eclairage
            lighting('gouraud')         % type de rendu
            lightangle(hlight,48,70)    % dir. eclairage
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % affichage label
        title(aff.titre);
        xlabel(aff.xlabel);
        ylabel(aff.ylabel);
        if aff.d3
            zlabel(aff.zlabel);    
            view(3)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %affichage 1D
    elseif esp1d
        if ~isempty(aff.color)
            if ~isempty(aff.opt)
                plot(grille,Z,aff.opt,'Color',aff.color);
            else
                plot(grille,Z,'Color',aff.color);
            end
        else
            if ~isempty(aff.opt)
                plot(grille,Z,aff.opt);
            else
                plot(grille,Z);
            end
        end
        title(aff.titre);
        xlabel(aff.xlabel);
        ylabel(aff.ylabel);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %sauvegarde traces figure
    if aff.save
        global num
        if isempty(num); num=1; else num=num+1; end
        fich=save_aff(num,aff.doss);
        if aff.tex
            fid=fopen([aff.doss '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,aff.titre,fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %exportation tikz
    if aff.tikz
        nomfig=[aff.doss '/fig_' num2str(aff.num,'%04.0f') '.tex'];
        matlab2tikz(nomfig);
    end
   

    
end
hold off
