%% Generation de l'espace de trace de la fonction 2D
%% L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

function [XY,aff]=gene_aff(doe,aff)

fprintf('=========================================\n')
fprintf('     >>> GENERATION AFFICHAGE <<<\n');
[tMesu,tInit]=mesu_time;
%dimension de l'espace
dim_esp=numel(doe.Xmin);

% on genere la grille d'etude du metamodele en fonction du nb de variables
% prises en compte.

if dim_esp==1
    XY=linspace(doe.Xmin,doe.Xmax,aff.nbele);
    
    % en 2D on definit une grille a partir de meshgrid
elseif dim_esp==2
    x=linspace(doe.Xmin(1),doe.Xmax(1),aff.nbele);
    y=linspace(doe.Xmin(2),doe.Xmax(2),aff.nbele);
    [grid_X,grid_Y]=meshgrid(x,y);
    
    XY=zeros(size(grid_X,1),size(grid_X,2),2);
    XY(:,:,1)=grid_X;
    XY(:,:,2)=grid_Y;
    
else
    % en nD on utilise la fonction de generation de factoriel complet
    grid=factorial_design(aff.nbele,doe.bornes);
    
    %reorganisation grille
    XY=zeros(size(grid,1),1,dim_esp);
    for ii=1:dim_esp
        XY(:,:,ii)=grid(:,ii);
    end
    
    
end

%pas de la grille d'affichage selon les deux variables
aff.pas=abs(doe.Xmax-doe.Xmin)./aff.nbele;

fprintf('++ Nombre de points de la grille %i (%i',aff.nbele^dim_esp,aff.nbele);
fprintf('x%i',aff.nbele*ones(1,dim_esp-1));fprintf(')\n');

mesu_time(tMesu,tInit);
fprintf('=========================================\n')
