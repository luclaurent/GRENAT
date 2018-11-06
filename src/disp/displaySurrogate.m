%% function for displaying response surfaces
%L. LAURENT   --  22/03/2010   --  luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
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

function figHandle=displaySurrogate(gridXY,Z,GZ,sampling,resp,grad,dispData)

%% input parameters:
%       - gridXY: grid used for plotting the responses surface,
%       gridXY(:,:,1) and gridXY(:,:,2) in 2D. In 1D, gridXY is only a
%       vector of reals obtained for instance using linspace
%       - Z: value of the function at the grid points
%       - GZ (nd-array): value of the gradients at the grid points
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
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Load default options
% dispDef=initDisp;
% %deal with missing options (added to the options structure)
% fDef=fieldnames(dispDef);
% fAvail=fieldnames(dispData);
% fMiss=setxor(fDef,fAvail);
% %adding missing options
% if ~isempty(fMiss)
%     Gfprintf('Some display options are missing (add its)\n');
%     for ii=1:numel(fMiss)
%         Gfprintf('%s ',fMiss{ii});
%         dispData.(fMiss{ii})=dispDef.(fMiss{ii});
%     end
%     Gfprintf('\n');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figHandle=[];

%load default
if isempty(dispData.view)
    dispData.view=3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%deal with gradients
if ~isempty(GZ)&&spa2D
    GR1=GZ(:,:,1);
    GR2=GZ(:,:,2);
end
if ~isempty(grad)&&spa2D
    sampGR1=grad(:,1);
    sampGR2=grad(:,2);
end

% gradients at grid points available
dispData.gridGrad=~isempty(GZ)&&dispData.gridGrad;
% gradients at sample points available
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        GZmax=0;sampGZmax=0;
        if dispData.gridGrad
            [GZvec,GZmax]=analyzeGrad(GR1,GR2);
        end
        if dispData.sampleGrad
            [sampGZvec,sampGZmax]=analyzeGrad(sampGR1,sampGR2);
        end
        nMax=max([GZmax sampGZmax]);
        %%compute scale factor
        if dispData.gridGrad||dispData.sampleGrad
            [scaleFactor,gridDim,rDim]=analyseGrid(Z,gridX,gridY);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %show 3D surface
        if dispData.d3
            %show contour
            if dispData.contour
                h=surfc(gridX,gridY,Z);
            else
                h=surf(gridX,gridY,Z);
            end
            %
            if dispData.uni
                %show surface with unique color
                set(h,'FaceColor',dispData.color,'EdgeColor',dispData.color);
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
            
            %show gradients at sample points
            if dispData.sampleGrad
                quiver3(sampling(:,1),...
                    sampling(:,2),...
                    resp,...
                    scaleFactor(1)*sampGZvec.X/nMax,...
                    scaleFactor(2)*sampGZvec.Y/nMax,...
                    sampGZvec.Z/nMax,...
                    'r',...
                    'AutoScale','off','MaxHeadSize',0.1/nMax);
                %
                if dispData.contour
                    quiver3(sampling(:,1),...
                        sampling(:,2),...
                        0.*resp,...
                        scaleFactor(1)*sampGZvec.X/nMax,...
                        scaleFactor(2)*sampGZvec.Y/nMax,...
                        0.*sampGZvec.Z,...
                        'r',...
                        'MaxHeadSize',0.1/nMax,...
                        'AutoScale','off');
                end
            end
            %show gradients at grid points
            if dispData.gridGrad
                quiver3(gridX,...
                    gridY,...
                    Z,...
                    scaleFactor(1)*GZvec.X/nMax,...
                    scaleFactor(2)*GZvec.Y/nMax,...
                    GZvec.Z/nMax,...
                    'b',...
                    'AutoScale','off','MaxHeadSize',0.1/nMax);
                %
                if dispData.contour
                    quiver3(gridX,...
                        gridY,...
                        0.*Z,...
                        scaleFactor(1)*GZvec.X/nMax,...
                        scaleFactor(2)*GZvec.Y/nMax,...
                        0.*GZvec.Z,...
                        'b',...
                        'MaxHeadSize',0.1/nMax,...
                        'AutoScale','off');
                end
            end
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
                        quiver(gridX,gridY,...
                            scaleFactor(1)*GR1,...
                            scaleFactor(2)*GR2,...
                            'Color','b',...
                            'AutoScale','off',...
                            'MaxHeadSize',0);
                    else
                        quiver(gridX,gridY,...
                            GR1,...
                            GR2,...
                            'Color','b',...
                            'AutoScale','off');
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
                            'Color','g',...
                            'LineWidth',2,...
                            'AutoScale','off',...
                            'MaxHeadSize',0);
                    else
                        quiver(sampling(:,1),sampling(:,2),...
                            grad(:,1),grad(:,2),...
                            'Color','g',...
                            'LineWidth',2,...
                            'AutoScale','off');
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
            view(dispData.view);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %display 1D
    elseif spa1D
        if dispData.gridGrad
            if ~isempty(dispData.color)
                if ~isempty(dispData.opt)
                    plot(gridXY,GR1,...
                        dispData.opt,...
                        'Color',dispData.color,...
                        'LineWidth',2);
                else
                    plot(gridXY,GR1,...
                        'Color',dispData.color,...
                        'LineWidth',2);
                end
            else
                if ~isempty(dispData.opt)
                    plot(gridXY,GR1,...
                        dispData.opt,...
                        'LineWidth',2);
                else
                    plot(gridXY,GR1,...
                        'LineWidth',2);
                end
            end
        else
            if ~isempty(dispData.color)
                if ~isempty(dispData.opt)
                    plot(gridXY,Z,...
                        dispData.opt,...
                        'Color',dispData.color,...
                        'LineWidth',2);
                else
                    plot(gridXY,Z,...
                        'Color',dispData.color,...
                        'LineWidth',2);
                end
            else
                if ~isempty(dispData.opt)
                    plot(gridXY,Z,...
                        dispData.opt,...
                        'LineWidth',2);
                else
                    plot(gridXY,Z,...
                        'LineWidth',2);
                end
            end
        end
        %show sample points
        if dispData.samplePts
            hold on;
            if dispData.sampleGrad;valPlot=sampGR1;else, valPlot=resp;end
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
        fileName=saveDisp(numPlot,dispData.directory);
        if dispData.tex
            fid=fopen([dispData.directory '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fileName,dispData.title,fileName);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plot responses in nD
    if dispData.bar
        Zs=Z(:);
        nbv=numel(Zs);
        if ~isempty(dispData.color)
            plot(1:nbv,Zs,'o',...
                'MarkerEdgeColor',dispData.color,...
                'MarkerFaceColor',dispData.color,...
                'Markersize',5);
            %line([1:nb_eval;1:nb_eval],[zeros(1,nb_eval);Zs'],'LineWidth',1,'Color',dispData.color,'lineStyle','--')
        else
            plot(1:nbv,Zs,'o',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','k',...
                'Markersize',5);
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
        nameFig=[dispData.directory '/fig_' num2str(dispData.num,'%04.0f') '.tex'];
        matlab2tikz(nameFig);
    end
    
    hold off;
end
end

%% compute data for gradients if plotted with quiver
function [vec,nMax]=analyzeGrad(GR1,GR2)
if nargin>1
    %define vector of gradients
    vec.X=-GR1;
    vec.Y=-GR2;
    vec.Z=-(GR1.^2+GR2.^2);
    %compute norm of the gradients
    vec.N=sqrt(-vec.Z);
    %maximal norm of the gradients
    nMax=max(vec.N(:));
else
    
end
end

%% Analyze the grid
function [scaleFactor,gridDim,rDim]=analyseGrid(vZ,gridX,gridY)
%size of the response space
rDim=abs(max(vZ(:))-min(vZ(:)));
%
if nargin>2    
    %minimal size of the display grid
    gx=abs(gridX-gridX(1));
    gx(gx==0)=Inf;
    gridDim(1)=min(gx(:));
    gy=abs(gridY-gridY(1));
    gy(gy==0)=Inf;
    gridDim(2)=min(gy(:));
    %size of the biggest arrow  (used for displaying gradients)
    paraAr=0.9;
    sizeGfinal=paraAr*gridDim*0.5;    
    %scale factor
    scaleFactor=sizeGfinal;%./[n1 n2];
else
    
end


end

