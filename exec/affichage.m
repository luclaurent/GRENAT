%%fonction realisant l'affichage des surfaces de reponse
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr


function status=affichage(grille,Z,tirages,eval,grad,aff)

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
                %dimension mini espace de conception
                dimm=min(abs(max(max(grille_X))-min(min(grille_X))),...
                    abs(max(max(grille_Y))-min(min(grille_Y))));
                %calcul norme gradient
                ngr=zeros(size(Z.GR1));
                for ii=1:size(Z.GR1,1)*size(Z.GR1,2)
                    ngr(ii)=norm([Z.GR1(ii) Z.GR2(ii)],2);
                end
                %recherche du maxi de la norme du gradient
                nm=max(max(ngr));

                %definition de la taille mini de la grille d'affichage
                tailg=min(aff.pas);
                
                %taille de la plus grande fleche
                para_fl=1.3;
                tailf=para_fl*tailg;

                %echelle
                ech=tailf/nm;
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
                        quiver(grille_X,grille_Y,ech*Z.GR1,ech*Z.GR2,'AutoScale','off');
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
                            ech*grad(:,1),ech*grad(:,2),...
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
