%% function for displaying response surfaces
%L. LAURENT   --  22/03/2010   --  luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
%           * dispData.gridGrad=false: display gradients at the points of the grid
%           * dispData.sampleGrad=false: display gradients at sample points
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
    fprintf('\n');
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

if ~isfield(Z,'GZ');dispData.gridGrad=false;end

%available gradients at sample points
dispData.sampleGrad=~isempty(grad)&&dispData.sampleGrad;
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

%active display
if dispData.on
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %display graph in a new window
    if dispData.newFig
        figHandle=figure;
    else
        hold on;
    end
    
    %display in 2D (2 design parameters)
    if spa2D
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%scale gradients
        if dispData.gridGrad
            %compute norm of the gradients
            ngr=zeros(size(GR1));
            for ii=1:size(GR1,1)*size(GR1,2)
                ngr(ii)=norm([GR1(ii) GR2(ii)],2);
            end
            %seek maximum norm of the gradients
            nm=max(max(ngr));
            n1=max(max(abs(GR1)));
            n2=max(max(abs(GR2)));
            
            %minimal size of the display grid
            gx=gridX-gridX(1);
            ixG= gx>0;
            sizeG(1)=min(min(gx(ixG)));
            gy=gridY-gridY(1);
            ixG= gy>0;
            sizeG(2)=min(min(gy(ixG)));
            
            %size of the biggest arrow  (used for displaying gradients)
            paraAr=0.9;
            sizeGfinal=paraAr*sizeG;
            
            %scale factor
            scaleFactor=sizeGfinal./[n1 n2];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %show 3D surface
        if dispData.d3
            %shwo contour
            if dispData.contour
                surfc(gridX,gridY,vZ);
                if dispData.uni
                    %show surface with unique color
                    set(h,'FaceColor',dispData.color,'EdgeColor',dispData.color);
                end
            else
                h=surf(gridX,gridY,vZ);
                if dispData.uni
                    %show surface with unique color
                    set(h,'FaceColor',dispData.color,'EdgeColor',dispData.color);
                end
            end
            
            %show sample points
            if dispData.samplePts
                hold on;
                
                %show sample points on which all information is known
                plot3(sampling(listPtsOk,1),sampling(listPtsOk,2),resp(listPtsOk),...
                    '.',...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor','k',...
                    'MarkerSize',15);
                %show sample points on which response is missing
                plot3(sampling(listMissResp,1),sampling(listMissResp,2),resp(listMissResp),...
                    'rs',...
                    'MarkerEdgeColor','r',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',7);
                %show sample points on which gradient(s) is missing
                plot3(sampling(listMissGrad,1),sampling(listMissGrad,2),resp(listMissGrad),...
                    'v',...
                    'MarkerEdgeColor','g',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',15);
                %show sample points on which gradient(s) and response are missing
                plot3(sampling(listMissBoth,1),sampling(listMissBoth,2),resp(listMissBoth),...
                    'd',...
                    'MarkerEdgeColor','r',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',15);
            end
            
            %show gradients
            if dispData.sampleGrad
                %find vectors with biggest slopes (in the direction of
                %descent of the gradient
                
                %%TO BE CHECK
                vec.X=-GR1;
                vec.Y=-GR2;
                vec.Z=-GR1.^2-GR2.^2;
                %normalization of the gradient with the biggest slopes
                vec.N=sqrt(vec.X.^2+vec.Y.^2+vec.Z.^2);
                vec.Xn=vec.X./vec.N;
                vec.Yn=vec.Y./vec.N;
                vec.Zn=vec.Z./vec.N;
                
                %%TO BE REMOVED IF OK
                %                 for ii=1:size(GR1,1)*size(GR1,2)
                %                     vec.X(ii)=-GR1(ii);
                %                     vec.Y(ii)=-GR2(ii);
                %                     vec.Z(ii)=-GR1(ii)^2-GR2(ii)^2;
                %                     %normalisation du vecteur de plus grande pente
                %                     vec.N(ii)=sqrt(vec.X(ii)^2+vec.Y(ii)^2+vec.Z(ii)^2);
                %                     vec.Xn(ii)=vec.X(ii)/vec.N(ii);
                %                     vec.Yn(ii)=vec.Y(ii)/vec.N(ii);
                %                     vec.Zn(ii)=vec.Z(ii)/vec.N(ii);
                %                 end
                %%%%%%%%%%%%%%%
                
                %maximal size of the design spacedimension maximale espace de conception
                dimm=max(abs(max(max(gridX))-min(min(gridX))),...
                    abs(max(max(gridY))-min(min(gridY))));
                %size of the response space
                dimr=abs(max(max(vZ))-min(min(vZ)));
                %maximal norm of the gradients
                nmax=max(max(vec.N));
                hold on;
                %hcones =coneplot(X,Y,vZ,vec.X,vec.Y,vec.Z,0.1,'nointerp');
                % hcones=coneplot(X,Y,vZ,GR1,GR2,-ones(size(GR1)),0.1,'nointerp');
                % set(hcones,'FaceColor','red','EdgeColor','none')
                quiver3(gridX,gridY,vZ,scaleFactor*vec.X,scaleFactor*vec.Y,scaleFactor*vec.Z,...
                    'b','MaxHeadSize',0.1*dimr/nmax,'AutoScale','off');
            end
            %axis([min(grille_X(:)) max(grille_X(:)) min(grille_Y(:)) max(grille_Y(:)) min(vZ(:)) max(vZ(:))])
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %show 2D surfaces (using contours)
        if dispData.d2
            %display contours
            if dispData.contour
                [C,h]=contourf(gridX,gridY,vZ);
                clabel(C,h,'BackgroundColor',[1 1 .6],...
                    'Edgecolor',[.7 .7 .7]);
                set(h,'LineWidth',2);
                %display gradients
                if dispData.gridGrad
                    hold on;
                    %scaling the gradients
                    if dispData.scale
                        quiver(gridX,gridY,scaleFactor(1)*GR1,scaleFactor(2)*GR2,'Color','b','AutoScale','off','MaxHeadSize',0);
                    else
                        quiver(gridX,gridY,GR1,GR2,'Color','b','AutoScale','off');
                    end
                end
                %show sample points
                if dispData.samplePts
                    hold on;
                    %show sample points on which all information is known
                    plot(sampling(listPtsOk,1),sampling(listPtsOk,2),...
                        'o',...
                        'LineWidth',2,...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor','g',...
                        'MarkerSize',7);
                    %show sample points on which response is missing
                    plot(sampling(listMissResp,1),sampling(listMissResp,2),...
                        'rs',...
                        'LineWidth',2,...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',7);
                    %show sample points on which gradient(s) is missing
                    plot(sampling(listMissGrad,1),sampling(listMissGrad,2),...
                        'v',...
                        'LineWidth',2,...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',7);
                    %show sample points on which gradient(s) and response are missing
                    plot(sampling(listMissBoth,1),sampling(listMissBoth,2),...
                        'd',...
                        'LineWidth',2,...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',7);
                    
                end
                %shows gradients
                if dispData.sampleGrad
                    hold on;
                    %scaling gradients
                    if dispData.scale
                        quiver(sampling(:,1),sampling(:,2),...
                            scaleFactor(1)*grad(:,1),scaleFactor(2)*grad(:,2),...
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
        %rendering
        if dispData.render
            hlight=light;               % active light
            lighting('gouraud');         % type of rendering
            lightangle(hlight,48,70);    % direction of the light
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % show label
        title(dispData.title);
        xlabel(dispData.xlabel);
        ylabel(dispData.ylabel);
        if dispData.d3
            zlabel(dispData.zlabel);
            view(3);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %display 1D
    elseif spa1D
        if dispData.gridGrad&&isfield(Z,'GZ')
            if ~isempty(dispData.color)
                if ~isempty(dispData.opt)
                    plot(gridXY,Z.GZ,dispData.opt,'Color',dispData.color,'LineWidth',2);
                else
                    plot(gridXY,Z.GZ,'Color',dispData.color,'LineWidth',2);
                end
            else
                if ~isempty(dispData.opt)
                    plot(gridXY,Z.GZ,dispData.opt,'LineWidth',2);
                else
                    plot(gridXY,Z.GZ,'LineWidth',2);
                end
            end
        else
            if ~isempty(dispData.color)
                if ~isempty(dispData.opt)
                    plot(gridXY,vZ,dispData.opt,'Color',dispData.color,'LineWidth',2);
                else
                    plot(gridXY,vZ,'Color',dispData.color,'LineWidth',2);
                end
            else
                if ~isempty(dispData.opt)
                    plot(gridXY,vZ,dispData.opt,'LineWidth',2);
                else
                    plot(gridXY,vZ,'LineWidth',2);
                end
            end
        end
        %show sample points
        if dispData.samplePts
            hold on;
            if dispData.gridGrad&&isfield(Z,'GZ');valPlot=grad;else valPlot=resp;end
            %show sample points on which all information is known
            plot(sampling(listPtsOk),valPlot(listPtsOk),...
                'rs',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','w',...
                'MarkerSize',7);
            %show sample points on which response is missing
            plot(sampling(listMissResp),valPlot(listMissResp),...
                'o',...
                'MarkerEdgeColor','r',...
                'MarkerFaceColor','r',...
                'MarkerSize',7);
            %show sample points on which gradient(s) is missing
            plot(sampling(listMissGrad),valPlot(listMissGrad),...
                'v',...
                'MarkerEdgeColor','r',...
                'MarkerFaceColor','r',...
                'MarkerSize',7);
            %show sample points on which gradient(s) and response are missing
            plot(sampling(listMissBoth),valPlot(listMissBoth),...
                'd',...
                'MarkerEdgeColor','r',...
                'MarkerFaceColor','r',...
                'MarkerSize',7);
        end
        title(dispData.title);
        xlabel(dispData.xlabel);
        ylabel(dispData.ylabel);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %save figure and create
    if dispData.save
        global numPlot
        if isempty(numPlot); numPlot=1; else numPlot=numPlot+1; end
        fich=saveDisp(numPlot,dispData.directory);
        if dispData.tex
            fid=fopen([dispData.directory '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,dispData.title,fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plot responses in nD
    if dispData.bar
        Zs=vZ(:);
        nbv=numel(Zs);
        if ~isempty(dispData.color)
            plot(1:nbv,Zs,'o','MarkerEdgeColor',dispData.color,'MarkerFaceColor',dispData.color,'Markersize',5);
            %line([1:nb_eval;1:nb_eval],[zeros(1,nb_eval);Zs'],'LineWidth',1,'Color',dispData.color,'lineStyle','--')
        else
            plot(1:nbv,Zs,'o','MarkerEdgeColor','k','MarkerFaceColor','k','Markersize',5);
            %line([1:nb_eval;1:nb_eval],[zeros(1,nb_eval);Zs'],'LineWidth',1,'Color',[0. 0. .8],'lineStyle','--')
        end
        title(dispData.title);
        xlabel(dispData.xlabel);
        ylabel(dispData.ylabel);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %export using tikz
    if dispData.tikz
        nomfig=[dispData.directory '/fig_' num2str(dispData.num,'%04.0f') '.tex'];
        matlab2tikz(nomfig);
    end
    
    hold off;
end
end

