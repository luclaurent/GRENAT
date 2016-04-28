%%fonction permettant le calcul de l'erreur R2
%%L. LAURENT   --  22/03/2010   --  luc.laurent@lecnam.net
%% Correction 20/03/2012 
% -- Calcul du coefficient de correlation de Pearson et correlation ajustée
% -- et coefficient de détermination et détermination ajustée

%%Zex: correspond a l'ensemble des valeurs obtenues par evalutions de la
%%fonction objectif
%%Zap: correspond a l'ensemble des valeurs

function [r,radj,r2,r2adj]=fact_corr(Zex,Zap)

Zex=Zex(:);Zap=Zap(:);
nbs=length(Zex);
%calcul des moyenn empirique
moyZex=mean(Zex);
moyZap=mean(Zap);

%calcul covariance empirique
covZexZap=sum(Zex.*Zap)-nbs*moyZex*moyZap;

%calcul variances empiriques
VZex=sum(Zex.^2)-nbs*moyZex^2;
VZap=sum(Zap.^2)-nbs*moyZap^2;

%coefficient de corrélation de Pearson
r=covZexZap/sqrt(VZex*VZap);
%coefficient de détermination
r2=r^2;
%coefficient de correlation ajusté
radj=sqrt(1-(nbs-1)/(nbs-2)*(1-r2));
%coefficient de détermination ajusté
r2adj=radj^2;
end