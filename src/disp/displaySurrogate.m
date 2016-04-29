%% function for displaying response surfaces
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr


function figHandle=displaySurrogate(gridXY,Z,sampling,resp,grad,dispData)

%% input parameters:
%       - gridXY: grid used for plotting the responses surface,
%       gridXY(:,:,1) and gridXY(:,:,2) in 2D. In 1D, gridXY is only a
%       vector of reals obtained for instance using linspace
%       - Z: structure of the data to be plotted
%           * vZ: value of the function at the grid points
%           * GZ (nd-array): components of the gradients calculated at the
%           grid points
%       - sampling: vector of the sample points (using DOE for instance)
%       - resp: values at the sample points
%       - grad: gradients at the sample points
%       - dispData: structure that contains all options of the function
%           * dispData.on: active display or not 
%           * dispData.newFig: show in a new figure 
%           * dispData.metaGrad: show gradients computed at grid points
%           * dispData.actualGrad: show gradients computed at sample points
%           * dispData.d3: show 3D plots (surf quiver3...)
%           * dispData.d2: show 2D plots (plot quiver...)
%           * dispData.contour: show isolines
%           * dispData.samplePts: show sample points
%           * dispData.uni: show surface with only one color
%           * dispData.color: chosen color
%           * dispData.render: rendering 3D plots
%           * dispData.save: save figures using eps & png formats
%           * dispData.tikz: save figures using Tikz (TeX) format
%           * dispData.tex: write associated TeX file
%           * dispData.opt: options for 1D plots
%           * dispData.title: title of the figure
%           * dispData.xlabel: name of x-axis
%           * dispData.ylabel: name of y-axis
%           * dispData.zlabel: name of z-axis
%           * dispData.scale: scale the gradients (quiver)
%           * dispData.directory: directory used for saving figures
%           * dispData.step: step of the grid used for plotting
%           * dispData.missData: information about the missing data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load default options
dispDef=initDisp;
%deal with missing options (added to the options structure)
fDef=fieldnames(dispDef);
fAvail=fieldnames(dispData);
fMiss=setxor(fDef,fAvail);
%adding missing options
if ~isempty(fMiss)
    fprintf('Some display options are missing (add its)\n');
    for ii=1:numel(fMiss)
        fprintf('%s ',fMiss{ii});
        dispData.(fMiss{ii})=dispDef.(fMiss{ii});
    end
    fprintf('\n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figHandle=[];

%deal with 1D/2D plots
spa1D=false;spa2D=false;
if size(sampling,2)==1
    spa1D=true;
elseif size(sampling,2)==2
    spa2D=true;
    if size(gridXY,3)>1
        gridX=gridXY(:,:,1);
        gridY=gridXY(:,:,2);
    else
        gridX=gridXY(:,1);
        gridY=gridXY(:,2);
    end
else    
    dispData.bar=true;
end
%reodering responses
if isa(Z,'struct')
    vZ=Z.Z;
else
    vZ=Z;
end

%reodering gradients
if isfield(Z,'GZ')&&spa2D
    GR1=Z.GZ(:,:,1);
    GR2=Z.GZ(:,:,2);
end

if ~isfield(Z,'GZ');dispData.actualGrad=false;end

%available gradients at sample points
availGrad=~isempty(grad);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%seeking and dealing with missing data
listPtsOk=1:size(sampling,1);
listMissResp=[];
listMissGrad=[];
listMissBoth=[];
if isfield(dispData,'missData')
    if dispData.missData.resp.on
        listMissResp=unique(dispData.missData.resp.ixMiss(:));
        for ii=1:numel(listMissResp)
            ix= listPtsOk==listMissResp(ii);
            listPtsOk(ix)=[];
        end
    end
    if dispData.missData.grad.on
        listMissGrad=unique(dispData.missData.grad.ix_manq(:,1));
        for ii=1:numel(listMissGrad)
            ix= listPtsOk==listMissGrad(ii);
            listPtsOk(ix)=[];
        end
    end
    if dispData.missData.eval.on|| dispData.missData.grad.on
        listMissBoth=intersect(listMissResp,listMissGrad);
        for ii=1:numel(listMissBoth)
            ix= listMissResp==listMissBoth(ii);
            listMissResp(ix)=[];
            ix= listMissGrad==listMissBoth(ii);
            listMissGrad(ix)=[];
        end
    end
end

%Affichage actif
if dispData.on
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %affichage dans une nouvelle fenetre
    if dispData.newFig
        figHandle=figure;
    else
        hold on
    end
    
    %affichage 2D
    if spa2D
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%mise a l'echelle des traces de gradients
        if dispData.metaGrad||dispData.actualGrad
            %calcul norme gradient
            ngr=zeros(size(GR1));
            for ii=1:size(GR1,1)*size(GR1,2)
                ngr(ii)=norm([GR1(ii) GR2(ii)],2);
            end
            %recherche du maxi de la norme du gradient
            nm=max(max(ngr));
            
            n1=max(max(abs(GR1)));
            n2=max(max(abs(GR2)));
            
            %definition de la taille mini de la grille d'affichage
            gx=gridX-gridX(1);
            ind= gx>0;
            tailg(1)=min(min(gx(ind)));
            gy=gridY-gridY(1);
            ind= gy>0;
            tailg(2)=min(min(gy(ind)));
            
            
            %taille de la plus grande fleche
            para_fl=0.9;
            tailf=para_fl*tailg;
            
            
            %echelle
            % nm
            %  tailf
            ech=tailf./[n1 n2];
            
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %affichage des surfaces 3D
        if dispData.d3
            %affichage des contour
            if dispData.contour
                %affichage unicolor
                surfc(gridX,gridY,vZ);
                if dispData.uni
                    set(h,'FaceColor',dispData.color,'EdgeColor',dispData.color);
                end
            else
                h=surf(gridX,gridY,vZ);
                if dispData.uni                    
                    set(h,'FaceColor',dispData.color,'EdgeColor',dispData.color);
                end
            end
            
            if dispData.samplePts
                hold on
                
                %affichage des points d'evaluations
                %affichage points ou toutes les infos sont connues
                plot3(sampling(listPtsOk,1),sampling(listPtsOk,2),resp(listPtsOk),...
                    '.','MarkerEdgeColor','k',...
                    'MarkerFaceColor','k',...
                    'MarkerSize',15);
                %affichage points il manque une/des reponse(s)
                plot3(sampling(listMissResp,1),sampling(listMissResp,2),resp(listMissResp),...
                    'rs','MarkerEdgeColor','r',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',7);
                %affichage points il manque un/des gradient(s)
                plot3(sampling(listMissGrad,1),sampling(listMissGrad,2),resp(listMissGrad),...
                    'v','MarkerEdgeColor','g',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',15);
                %affichage points il manque un/des gradient(s) et un/des
                %reponse(s) au m�me point
                plot3(sampling(listMissBoth,1),sampling(listMissBoth,2),resp(listMissBoth),...
                    'd','MarkerEdgeColor','r',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',15);
            end
            
            %Affichage des gradients
            if dispData.actualGrad
                %determination des vecteurs de plus grandes pentes (dans le
                %sens de descente du gradient)
                for ii=1:size(GR1,1)*size(GR1,2)
                    vec.X(ii)=-GR1(ii);
                    vec.Y(ii)=-GR2(ii);
                    vec.Z(ii)=-GR1(ii)^2-GR2(ii)^2;
                    %normalisation du vecteur de plus grande pente
                    vec.N(ii)=sqrt(vec.X(ii)^2+vec.Y(ii)^2+vec.Z(ii)^2);
                    vec.Xn(ii)=vec.X(ii)/vec.N(ii);
                    vec.Yn(ii)=vec.Y(ii)/vec.N(ii);
                    vec.Zn(ii)=vec.Z(ii)/vec.N(ii);
                end
                hold on
                
                %hcones =coneplot(X,Y,vZ,vec.X,vec.Y,vec.Z,0.1,'nointerp');
                % hcones=coneplot(X,Y,vZ,GR1,GR2,-ones(size(GR1)),0.1,'nointerp');
                % set(hcones,'FaceColor','red','EdgeColor','none')
                
                %hold on
                %dimension maximale espace de conception
                dimm=max(abs(max(max(gridX))-min(min(gridX))),...
                    abs(max(max(gridY))-min(min(gridY))));
                %dimension espace de reponse
                dimr=abs(max(max(vZ))-min(min(vZ)));
                %norme maxi du gradient
                nmax=max(max(vec.N));
                quiver3(gridX,gridY,vZ,ech*vec.X,ech*vec.Y,ech*vec.Z,...
                    'b','MaxHeadSize',0.1*dimr/nmax,'AutoScale','off')
            end
            %axis([min(grille_X(:)) max(grille_X(:)) min(grille_Y(:)) max(grille_Y(:)) min(vZ(:)) max(vZ(:))])
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %affichage des surfaces 2D (contours)
        if dispData.d2
            %affichage des contours
            if dispData.contour
                [C,h]=contourf(gridX,gridY,vZ);
                text_handle = clabel(C,h);
                set(text_handle,'BackgroundColor',[1 1 .6],...
                    'Edgecolor',[.7 .7 .7]);
                set(h,'LineWidth',2);
                %affichage des gradients
                if dispData.metaGrad
                    hold on;
                    %remise a� l'echelle
                    if dispData.scale
                        %quiver(grille_X,grille_Y,ech(1)*GR1,ech(2)*GR2,'AutoScale','off','MaxHeadSize',0.0002);
                        quiver(gridX,gridY,ech(1)*GR1,ech(2)*GR2,'Color','b','AutoScale','off','MaxHeadSize',0);
                        %axis equal
                        %ncquiverref(grille_X,grille_Y,ech(1)*GR1,ech(2)*GR2);
                        %ech(1)*GR1
                        %ech(2)*GR2
                    else
                        quiver(gridX,gridY,GR1,GR2,'Color','b','AutoScale','off');
                    end
                end
                %affichage des points d'evaluation
                if dispData.samplePts
                    hold on
                    %affichage points ou toutes les infos sont connues
                    plot(sampling(listPtsOk,1),sampling(listPtsOk,2),...
                        'o','LineWidth',2,'MarkerEdgeColor','k',...
                        'MarkerFaceColor','g',...
                        'MarkerSize',15);
                    %affichage points il manque une/des reponse(s)
                    plot(sampling(listMissResp,1),sampling(listMissResp,2),...
                        'rs','LineWidth',2,'MarkerEdgeColor','k',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',7);
                    %affichage points il manque un/des gradient(s)
                    plot(sampling(listMissGrad,1),sampling(listMissGrad,2),...
                        'v','LineWidth',2,'MarkerEdgeColor','k',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',15);
                    %affichage points il manque un/des gradient(s) et un/des
                    %reponse(s) au m�me point
                    plot(sampling(listMissBoth,1),sampling(listMissBoth,2),...
                        'd','LineWidth',2,'MarkerEdgeColor','k',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',15);
                    
                end
                %affichage des gradients
                if dispData.actualGrad&&availGrad
                    hold on;
                    %remise a� l'echelle
                    if dispData.scale
                        quiver(sampling(:,1),sampling(:,2),...
                            ech(1)*grad(:,1),ech(2)*grad(:,2),...
                            'Color','g','LineWidth',2,'AutoScale','off','MaxHeadSize',0);
                        
                    else
                        quiver(sampling(:,1),sampling(:,2),...
                            grad(:,1),grad(:,2),...
                            'Color','g','LineWidth',2,'AutoScale','off');
                    end
                    
                end
                
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %rendu
        if dispData.render
            hlight=light;               % activ. eclairage
            lighting('gouraud')         % type de rendu
            lightangle(hlight,48,70)    % dir. eclairage
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % affichage label
        title(dispData.title);
        xlabel(dispData.xlabel);
        ylabel(dispData.ylabel);
        if dispData.d3
            zlabel(dispData.zlabel);
            view(3)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %affichage 1D
    elseif spa1D
        if dispData.metaGrad&&isfield(Z,'GZ')
            if ~isempty(dispData.color)
                if ~isempty(dispData.opt)
                    plot(gridXY,Z.GZ,dispData.opt,'Color',dispData.color);
                else
                    plot(gridXY,Z.GZ,'Color',dispData.color);
                end
            else
                if ~isempty(dispData.opt)
                    plot(gridXY,Z.GZ,dispData.opt);
                else
                    plot(gridXY,Z.GZ);
                end
            end
        else
            if ~isempty(dispData.color)
                if ~isempty(dispData.opt)
                    plot(gridXY,vZ,dispData.opt,'Color',dispData.color);
                else
                    plot(gridXY,vZ,'Color',dispData.color);
                end
            else
                if ~isempty(dispData.opt)
                    plot(gridXY,vZ,dispData.opt);
                else
                    plot(gridXY,vZ);
                end
            end
        end
        %affichage des points d'evaluation
        if dispData.samplePts
            hold on
            if dispData.actualGrad;val_trac=grad;else val_trac=resp;end
            %affichage points ou toutes les infos sont connues
            plot(sampling(listPtsOk),val_trac(listPtsOk),...
                '.','MarkerEdgeColor','k',...
                'MarkerFaceColor','k',...
                'MarkerSize',15);
            %affichage points il manque une/des reponse(s)
            plot(sampling(listMissResp),val_trac(listMissResp),...
                'rs','MarkerEdgeColor','r',...
                'MarkerFaceColor','r',...
                'MarkerSize',7);
            %affichage points il manque un/des gradient(s)
            plot(sampling(listMissGrad),val_trac(listMissGrad),...
                'v','MarkerEdgeColor','r',...
                'MarkerFaceColor','r',...
                'MarkerSize',7);
            %affichage points il manque un/des gradient(s) et un/des
            %reponse(s) au m�me point
            plot(sampling(listMissBoth),val_trac(listMissBoth),...
                'd','MarkerEdgeColor','r',...
                'MarkerFaceColor','r',...
                'MarkerSize',7);
        end
        title(dispData.title);
        xlabel(dispData.xlabel);
        ylabel(dispData.ylabel);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %sauvegarde traces figure
    if dispData.save
        global num
        if isempty(num); num=1; else num=num+1; end
        fich=save_aff(num,dispData.directory);
        if dispData.tex
            fid=fopen([dispData.directory '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,dispData.title,fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Trace r�ponse nD
    if dispData.bar
        Zs=vZ(:);
        nb_eval=numel(Zs);
        if ~isempty(dispData.color)
            plot(1:nb_eval,Zs,'o','MarkerEdgeColor',dispData.color,'MarkerFaceColor',dispData.color,'Markersize',5);
            %line([1:nb_eval;1:nb_eval],[zeros(1,nb_eval);Zs'],'LineWidth',1,'Color',dispData.color,'lineStyle','--')
        else
            plot(1:nb_eval,Zs,'o','MarkerEdgeColor','k','MarkerFaceColor','k','Markersize',5);
            %line([1:nb_eval;1:nb_eval],[zeros(1,nb_eval);Zs'],'LineWidth',1,'Color',[0. 0. .8],'lineStyle','--')
        end
        title(dispData.title);
        xlabel(dispData.xlabel);
        ylabel(dispData.ylabel);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %exportation tikz
    if dispData.tikz
        nomfig=[dispData.directory '/fig_' num2str(dispData.num,'%04.0f') '.tex'];
        matlab2tikz(nomfig);
    end
    
    
    hold off
end

