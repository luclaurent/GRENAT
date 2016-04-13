%% Affichage des intervalles de confiance
%% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function affichage_ic(X,ic,aff,Z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement des options par défaut
aff_def=init_aff;
%on traite les options manquantes (en les ajoutant)
f_def=fieldnames(aff_def);
f_dispo=fieldnames(aff);
f_manq=setxor(f_def,f_dispo);
%on ajoute les valeurs par défaut manquantes
if ~isempty(f_manq)
    fprintf('Qques options affichage manquantes (ajout)\n');
    for ii=1:numel(f_manq)
        fprintf('%s ',f_manq{ii});
        aff.(f_manq{ii})=aff_def.(f_manq{ii});
    end
    fprintf('\n')
end

%nouvelle figure ou pas
if aff.newfig
    figure;
end

%en fonction de la dimension
d1=false;d2=false;
sX=size(X);
if numel(sX)==3
    d2=true;
elseif numel(sX)==2
    if sX(1)==1||sX(2)==1
        d1=true;
    end
end

%en dimension 1
if d1
    hold on;
    hs=area(X,ic.sup,min(ic.inf));
    hi=area(X,ic.inf,min(ic.inf));
    set(hs(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
    set(hi(1),'FaceColor',[1 1 1],'EdgeColor','none')
    hold off
elseif d2
    XX=X(:,:,1);
    YY=X(:,:,2);
    hs=surf(XX,YY,ic.sup);
    hold on
    hi=surf(XX,YY,ic.inf);
    %affichage surface si dispo
    if nargin==4
        if isa(Z,'struct');vZ=Z.Z;else vZ=Z;end
        surf(XX,YY,vZ)
    end    
    hold off
    title(aff.titre)
    xlabel(aff.xlabel)
    ylabel(aff.ylabel)
    zlabel(aff.zlabel)
    
    %couleur uniforme
    if aff.uni
        set(hs,'FaceColor','red');
        set(hi,'FaceColor','blue');
    end
    %transparence
    if aff.trans
        set(hs,'FaceAlpha',0.5);
        set(hi,'FaceAlpha',0.5);
    end
    %rendu
    if aff.rendu
        hlight=light;               % activ. eclairage
        lighting('gouraud')         % type de rendu
        lightangle(hlight,48,70)    % dir. eclairage
    end
else
    nbs=size(X,2);
    plot(1:nbs,ic.sup,'o','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6)
    hold on
    plot(1:nbs,ic.inf,'o','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6)
end
