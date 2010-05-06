%%fonction réalisant l'affichage des surfaces de réponse
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr


function status=affichage(X,Y,Z,tirages,eval,aff)

global cofast resultats doe;

if aff.on
    if aff.newfig
        figure;
    else
        hold on
    end

    if aff.d3
        if aff.contour3
            if aff.uni          
                surfc(X,Y,Z.Z,'FaceColor',aff.color,'EdgeColor',aff.color)
            else
                surfc(X,Y,Z.Z)
            end
        else
            if aff.uni          
                surf(X,Y,Z.Z,'FaceColor',aff.color,'EdgeColor',aff.color)
            else
                surf(X,Y,Z.Z)
            end
        end
        if aff.pts
        hold on
        plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                'MarkerFaceColor','g',...
                'MarkerSize',15)
     
        end
        if aff.grad
            %détermination des vecteurs de plus grandes pentes (dans le
            %sens de descente du gradient)
            for ii=1:size(Z.GR1,1)
                for jj=1:size(Z.GR1,2)
                    vec.X(ii,jj)=-Z.GR1(ii,jj);
                    vec.Y(ii,jj)=-Z.GR2(ii,jj);
                    vec.Z(ii,jj)=-Z.GR1(ii,jj)^2-Z.GR2(ii,jj)^2;
                    %normalisation du vecteur de plus grande pente
                    vec.N(ii,jj)=sqrt(vec.X(ii,jj)^2+vec.Y(ii,jj)^2+vec.Z(ii,jj)^2);
                    vec.Xn(ii,jj)=vec.X(ii,jj)/vec.N(ii,jj);
                    vec.Yn(ii,jj)=vec.Y(ii,jj)/vec.N(ii,jj);
                    vec.Zn(ii,jj)=vec.Z(ii,jj)/vec.N(ii,jj);
                    
                end
            end
            hold on
      
           %hcones =coneplot(X,Y,Z.Z,vec.X,vec.Y,vec.Z,0.1,'nointerp');
           % hcones=coneplot(X,Y,Z.Z,Z.GR1,Z.GR2,-ones(size(Z.GR1)),0.1,'nointerp');
           % set(hcones,'FaceColor','red','EdgeColor','none')
            
            %hold on
            %dimension maximale espace de conception
            dimm=max(abs(max(max(X))-min(min(X))),abs(max(max(Y))-min(min(Y)))); 
            %dimension espace de réponse
            dimr=abs(max(max(Z.Z))-min(min(Z.Z)));
            %norme maxi du gradient
            nmax=max(max(vec.N));
            quiver3(X,Y,Z.Z,vec.X,vec.Y,vec.Z,10^4*dimr/nmax,'b','MaxHeadSize',0.1*dimr/nmax,'AutoScaleFactor',10^4*dimr/nmax,'AutoScale','off')
        end
    end
    
    if aff.grad||cofast.grad
                        %dimension maxi espace de conception
                dimm=max(abs(max(max(X))-min(min(X))),abs(max(max(Y))-min(min(Y))));
                %calcul norme gradient
                ngr=zeros(size(Z.GR1));
                for ii=1:size(Z.GR1,1)
                    for jj=1:size(Z.GR1,2)
                        ngr(ii,jj)=norm([Z.GR1(ii,jj) Z.GR2(ii,jj)],2);
                    end
                end
                %recherche du maxi de la norme du gradient
                nm=mean(mean(ngr));
    end
    
    if aff.d2
        if aff.contour2
           [C,h]=contourf(X,Y,Z.Z);       
           set(h,'LineWidth',2)
           if aff.grad                
               hold on;

                quiver(X,Y,Z.GR1,Z.GR2,nm*0.001);
           end
            if aff.pts
                hold on
                plot(tirages(:,1),tirages(:,2),'.','MarkerEdgeColor','g',...
                'MarkerFaceColor','g',...
                'MarkerSize',15)     
            end
            if cofast.grad
                %hold on;
                %figure;
                
               quiver(resultats.tirages(:,1),resultats.tirages(:,2),resultats.grad.gradients(:,1),resultats.grad.gradients(:,2),...
                   nm*0.001,'LineWidth',2);
               
            end
           
           text_handle = clabel(C,h);
            set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        end
    end

    if aff.rendu
        hlight=light;               % activ. éclairage
        lighting('gouraud')         % type de rendu
        lightangle(hlight,48,70)    % dir. éclairage
    end

    
    title(aff.titre);
    xlabel(aff.xlabel);
    ylabel(aff.ylabel);
    if aff.d3
        zlabel(aff.zlabel);    
        view(3)
    end
    
    
end
end
