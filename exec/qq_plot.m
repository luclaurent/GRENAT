%% Trace QQ plot (pour cross validation)
%L. LAURENT -- 21/01/2012 -- laurent@lmt.ens-cachan.fr

function qq_plot(Zref,Zap,opt)

% init
Zref=Zref(:);Zap=Zap(:);
%bornes graph
xmin=min([Zref;Zap]);
xmax=max([Zref;Zap]);

%axe ideal
li=linspace(xmin,xmax,30);

%Projection orthogonal
projX=(Zref+Zap)/2;
projY=projX;
%plot(projX,projY,'o','MarkerEdgeColor','b','MarkerFaceColor','b','Markersize',10)
%lignes projection

%recherche des extremum
vecX=projX-Zref;
vecY=projY-Zap;
dist=sqrt(vecX.^2+vecY.^2);
% points au dessus
ind=find(Zap>=Zref);
[~,ptup]=max(dist(ind));
ptup=ind(ptup);
coef=Zap(ptup)-Zref(ptup);
liup=li+coef;

% points en dessous
ind=find(Zap<Zref);
[~,ptdown]=max(dist(ind));
ptdown=ind(ptdown);
coef=Zap(ptdown)-Zref(ptdown);
lidown=li+coef;



%remplissage
Xp=[li(1);li(1);li(1);li(end);li(end);li(end)];
Yp=[lidown(1);li(1);liup(1);liup(end);li(end);lidown(end)];

%si options
new_fig=true;
def_title='QQ plot';
def_x='Real';
def_y='Predicted';
if nargin==3
    if isfield(opt,'newfig')
        new_fig=opt.newfig;
    end
    if isfield(opt,'title')
        def_title=opt.title;
    end
    if isfield(opt,'xlabel')
        def_x=opt.xlabel;
    end
    if isfield(opt,'ylabel')
        def_y=opt.ylabel;
    end
    
end

%graphe
if new_fig
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
title(def_title)
xlabel(def_x)
ylabel(def_y)
axis([xmin xmax xmin xmax])
hold off

end