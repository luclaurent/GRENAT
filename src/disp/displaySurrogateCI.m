%% Display confidence intervals
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function displaySurrogateIC(Xpts,ic,aff,Z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load default configuration for display
dispDef=initDisp;
%deal with missing data 
fDef=fieldnames(dispDef);
fAvail=fieldnames(aff);
fMiss=setxor(fDef,fAvail);
%add missing options
if ~isempty(fMiss)
    fprintf('Missing display options (add)\n');
    for ii=1:numel(fMiss)
        fprintf('%s ',fMiss{ii});
        aff.(fMiss{ii})=dispDef.(fMiss{ii});
    end
    fprintf('\n')
end

%new figure or not
if aff.newFig
    figure;
end

%depending on the dimension
d1=false;d2=false;
sX=size(Xpts);
if numel(sX)==3
    d2=true;
elseif numel(sX)==2
    if sX(1)==1||sX(2)==1
        d1=true;
    end
end

%dimension 1
if d1
    hold on;
    hs=area(Xpts,ic.sup,min(ic.inf));
    hi=area(Xpts,ic.inf,min(ic.inf));
    set(hs(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
    set(hi(1),'FaceColor',[1 1 1],'EdgeColor','none')
    hold off
    %dimension 2
elseif d2
    XX=Xpts(:,:,1);
    YY=Xpts(:,:,2);
    hs=surf(XX,YY,ic.sup);
    hold on
    hi=surf(XX,YY,ic.inf);
    %display surface if available
    if nargin==4
        if isa(Z,'struct');vZ=Z.Z;else vZ=Z;end
        surf(XX,YY,vZ)
    end    
    hold off
    title(aff.titre)
    xlabel(aff.xlabel)
    ylabel(aff.ylabel)
    zlabel(aff.zlabel)
    
    %unique color
    if aff.uni
        set(hs,'FaceColor','red');
        set(hi,'FaceColor','blue');
    end
    %opacity
    if aff.opacity
        set(hs,'FaceAlpha',0.5);
        set(hi,'FaceAlpha',0.5);
    end
    %rendering
    if aff.render
        hlight=light;               % light on
        lighting('gouraud')         % type of rendering
        lightangle(hlight,48,70)    % direction of the light
    end
else
    nbs=size(Xpts,2);
    plot(1:nbs,ic.sup,'o','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6)
    hold on
    plot(1:nbs,ic.inf,'o','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6)
end
