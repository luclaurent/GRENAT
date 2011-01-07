%% Génération de l'espace de tracé de la fonction 2D
%% L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

function [XY,aff]=gene_aff(doe,aff)

x=linspace(doe.bornes(1,1),doe.bornes(1,2),aff.nbele);
y=linspace(doe.bornes(2,1),doe.bornes(2,2),aff.nbele);
[grid_X,grid_Y]=meshgrid(x,y);

XY=zeros(size(grid_X,1),size(grid_X,2),2);
XY(:,:,1)=grid_X;
XY(:,:,2)=grid_Y;

%pas de la grille d'affichage selon les deux variables
aff.pas(1)=abs(doe.bornes(1,2)-doe.bornes(1,1))/aff.nbele;
aff.pas(2)=abs(doe.bornes(2,1)-doe.bornes(2,2))/aff.nbele;