%% Generation de l'espace de trace de la fonction 2D
%% L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

function [XY,aff]=gene_aff(doe,aff)

%dimension de l'espace
dim_esp=size(doe.bornes,1);

% on genere la grille d'étude du métamodèle en fonction du nb de variables
% prises en compte.

if dim_esp==1
    XY=linspace(doe.bornes(1),doe.bornes(2),aff.nbele);
    
    % en 2D on définit une grille à partir de meshgrid
elseif dim_esp==2
    x=linspace(doe.bornes(1,1),doe.bornes(1,2),aff.nbele);
    y=linspace(doe.bornes(2,1),doe.bornes(2,2),aff.nbele);
    [grid_X,grid_Y]=meshgrid(x,y);
    
    XY=zeros(size(grid_X,1),size(grid_X,2),2);
    XY(:,:,1)=grid_X;
    XY(:,:,2)=grid_Y;
    
else
    % en nD on utilise la fonction de génération de factoriel complet
    grid=factorial_design(aff.nbele,doe.bornes);
    
    %reorganisation grille
    XY=zeros(size(grid,1),1,dim_esp);
    size(XY)
    size(grid)
    
    for ii=1:dim_esp
        XY(:,:,ii)=grid(:,ii);
    end
    
    
end

%pas de la grille d'affichage selon les deux variables
aff.pas=abs(doe.bornes(:,2)-doe.bornes(:,1))./aff.nbele;
