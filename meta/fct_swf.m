%%% Calcul des fonctions de ponderation au point considere et ses gradients
%% L. LAURENT -- 23/11/2011 -- laurent@lmt.ens-cachan.fr

function [W,Wm,dW,dWm]=fct_swf(point,tirages,para)

%% OUT: Wm >> fonctions de ponderation moyennees
%%		dWm >> derivees des fonctions de ponderation moyennees
%%		Wm >> fonctions de ponderation
%%		dWm >> derivees des fonctions de ponderation

%type de norme utilisé
type_norm='L2';	%L1,L2,Linf,Lp
p=1.99; %si 'Lp'

%% calcul de la distance aux tirages
ecart=point-tirages;
switch type_norm
    case 'L1'
        d=sum(abs(ecart),2);
    case 'L2'
        d=sqrt(sum(ecart.^2,2));
        %case 'Linf'
        %d=max(ecart,[],2);
    case 'Lp'
        d=sum(ecart.^p,2);
    otherwise
        error('mauvaise norme selectionnee (cf.fct_swf.m)')
end

%% calcul distance au centre de la zone d'influence
dist=para-d;

%% extraction valeurs dans la zone d'influence (construction fonctions chapeau)
[ind]=find(dist>0);
val_influ=zeros(size(dist));
val_influ(ind)=dist(ind);
%val_influ=dist;

%% fonctions de ponderation
W=(val_influ./(para.*d)).^2;

Wmm=zeros(size(W));
hh=val_influ./d;

%for ii=1:size(tirages,1)
%	hd=val_influ([1:ii-1 ii+1:end])./d([1:ii-1 ii+1:end]);
%	Wmm(ii)=val_influ(ii).^2./(val_influ(ii).^2+(d(ii)^2.*sum(hd.^2)));
%end	

Wm=val_influ.^2./(d.^2.*sum(hh.^2));

%% fonctions de ponderation moyennees
sW=sum(W);
%if sW==Inf
%Wm=zeros(size(W));
%else
%Wm=W./sW;
%end
%Wm
%sW


%% Calcul des derivees des fonctions de ponderation
if nargout>=3
    switch type_norm
        case 'L2'
            dW=-2*W./(para*d.^4).*ecart;
    end
    
    %% derivees fonctions de ponderation moyennees
    dWm=(dW.*sW-W.*sum(dW,2))./sW^2;
end
