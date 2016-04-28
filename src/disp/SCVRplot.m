%% Plot SCVR (for cross validation)
%L. LAURENT -- 16/02/2012 -- luc.laurent@lecnam.net
% cf. Jones 1998

function SCVRplot(Zap,scvr,opt)

%% chosen bounds of the SCVR
boundSCVR=3;

% initialization
scvr=scvr(:);Zap=Zap(:);
%bound of the graph
xMin=min(Zap);
xMax=max(Zap);
yMin=min([-boundSCVR-1;scvr]);
yMax=max([boundSCVR+1;scvr]);


% points inside and outside the bounds
ixOut=find(abs(scvr)>boundSCVR);
ixIn=find(abs(scvr)<boundSCVR);

%build vector for displaying bounds
Xp=[xMin;xMax;xMax;xMin;xMin];
Yp=[boundSCVR;boundSCVR;-boundSCVR;-boundSCVR;boundSCVR];

%if options
newFig=true;
defTitle='SCVR plot';
defX='Predicted responses';
defY='SCVR';
if nargin==3
    if isfield(opt,'newfig')
        newFig=opt.newfig;
    end
    if isfield(opt,'title')
        defTitle=opt.title;
    end
    if isfield(opt,'xlabel')
        defX=opt.xlabel;
    end
    if isfield(opt,'ylabel')
        defY=opt.ylabel;
    end
    
end

%graph
if newFig
    figure;
end
hold on
fill(Xp,Yp,[0 0.9 0.99])
plot([xMin xMax],[0 0],'r','LineWidth',1.5)

plot([xMin xMax],[boundSCVR boundSCVR],'b','LineWidth',1.5,'lineStyle','--')
plot([xMin xMax],[-boundSCVR -boundSCVR],'b','LineWidth',1.5,'lineStyle','--')
% inside the bounds
plot(Zap(ixIn),scvr(ixIn),'o','MarkerEdgeColor','k','MarkerFaceColor','k','Markersize',10)
% outside the bounds
plot(Zap(ixOut),scvr(ixOut),'o','MarkerEdgeColor','r','MarkerFaceColor','r','Markersize',10)
title(defTitle)
xlabel(defX)
ylabel(defY)
axis([xMin xMax yMin yMax])
hold off

end