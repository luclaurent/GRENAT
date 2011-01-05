%% Génération de l'espace de tracé de la fonction 2D
%% L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

function XY=gene_aff(doe,aff)
x=doe.bornes(1,1):aff.pas:doe.bornes(1,2);
y=doe.bornes(2,1):aff.pas:doe.bornes(2,2);
[grid_X,grid_Y]=meshgrid(x,y);

XY=zeros(size(grid_X,1),size(grid_X,2),2);
XY(:,:,1)=grid_X;
XY(:,:,2)=grid_Y;