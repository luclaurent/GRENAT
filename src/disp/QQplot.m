%% Plot QQ plot (for cross validation)
%L. LAURENT -- 21/01/2012 -- luc.laurent@lecnam.net

function QQplot(Zref,Zap,opt)

% initialization
Zref=Zref(:);
Zap=Zap(:);
% bounds of the graph
xmin=min([Zref;Zap]);
xmax=max([Zref;Zap]);

% ideal line
li=linspace(xmin,xmax,30);

% orthogonal projection
projX=(Zref+Zap)/2;
projY=projX;
%plot(projX,projY,'o','MarkerEdgeColor','b','MarkerFaceColor','b','Markersize',10)
%lines of projection

%seek for extremums
vecX=projX-Zref;
vecY=projY-Zap;
dist=sqrt(vecX.^2+vecY.^2);
% points above
ind=find(Zap>=Zref);
[~,ptup]=max(dist(ind));
ptup=ind(ptup);
coef=Zap(ptup)-Zref(ptup);
if isempty(coef)
    coef=0;
end
liup=li+coef;

% points below
ind=find(Zap<Zref);
[~,ptdown]=max(dist(ind));
ptdown=ind(ptdown);
coef=Zap(ptdown)-Zref(ptdown);
if isempty(coef)
    coef=0;
end
lidown=li+coef;

%lines of the bounds
Xp=[li(1);li(1);li(1);li(end);li(end);li(end)];
Yp=[lidown(1);li(1);liup(1);liup(end);li(end);lidown(end)];

%if options
newFig=true;
defTitle='QQ plot';
defX='Real';
defY='Predicted';
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
plot(li,li,'r','LineWidth',1.5)
axis equal
line([Zref';projX'],[Zap';projY'],'LineWidth',1,'Color',[0. 0. .8],'lineStyle','--')
plot(li,liup,'b','LineWidth',1.5,'lineStyle','--')
plot(li,lidown,'b','LineWidth',1.5,'lineStyle','--')
plot(Zref,Zap,'o','MarkerEdgeColor','k','MarkerFaceColor','k','Markersize',10)
title(defTitle)
xlabel(defX)
ylabel(defY)
axis([xmin xmax xmin xmax])
hold off

end