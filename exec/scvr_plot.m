%% Trace SCVR plot (pour cross validation)
%L. LAURENT -- 16/02/2012 -- laurent@lmt.ens-cachan.fr
% cf. Jones 1998

function scvr_plot(Zap,scvr,opt)

%% bornes visées SVCR
bornes=3;

% init
scvr=scvr(:);Zap=Zap(:);
%bornes graph
xmin=min(Zap);
xmax=max(Zap);
ymin=min([-bornes-1;scvr]);
ymax=max([bornes+1;scvr]);


% points en dehors des bornes et dans les bornes
ind_out=find(abs(scvr)>bornes);
ind_in=find(abs(scvr)<bornes);

%remplissage
Xp=[xmin;xmax;xmax;xmin;xmin];
Yp=[bornes;bornes;-bornes;-bornes;bornes];

%si options
new_fig=true;
def_title='SCVR plot';
def_x='Predicted responses';
def_y='SCVR';
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
plot([xmin xmax],[0 0],'r','LineWidth',1.5)

plot([xmin xmax],[bornes bornes],'b','LineWidth',1.5,'lineStyle','--')
plot([xmin xmax],[-bornes -bornes],'b','LineWidth',1.5,'lineStyle','--')
% dans les bornes
plot(Zap(ind_in),scvr(ind_in),'o','MarkerEdgeColor','k','MarkerFaceColor','k','Markersize',10)
% hors des bornes
plot(Zap(ind_out),scvr(ind_out),'o','MarkerEdgeColor','r','MarkerFaceColor','r','Markersize',10)
title(def_title)
xlabel(def_x)
ylabel(def_y)
axis([xmin xmax ymin ymax])
hold off

end