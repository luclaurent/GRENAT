%%% Calcul des fonctions de ponderation au point considere et ses gradients
%% L. LAURENT -- 23/11/2011 -- laurent@lmt.ens-cachan.fr

function [Wm,dWm,W,dW]=fct_swf(point,tirages,para)

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
d=sum(ecart.^2,2);
case 'Linf'
d=max(ecart,[],2);
case 'Lp'
d=sum(ecart.^p,2);
otherwise
	error('mauvaise norme selectionnee (cf.fct_swf.m)')
end

%% calcul distance au centre de la zone d'influence
dist=para-d;

%% extraction valeurs dans la zone d'influence (construction fonctions chapeau)
[ind]=find(dist<0);
val_influ=zeros(size(dist));
val_influ(ind)=dist(ind);


%% fonctions de ponderation
W=(val_influ./(para.*d)).^2;
%% fonctions de ponderations moyennees
Wm=W./sum(W);

