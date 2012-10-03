%% Fonction assurant le calcul/la determination du nombre de points pour déterminer la grille du metamodele (pour affichage ou vérification)
%% L.LAURENT -- 15/05/2012 -- laurent@lmt.ens-cachan.fr

function nb_ele=gene_nbele(dim)

if dim==1
    nb_ele=200;
elseif dim==2
    nb_ele=30;
elseif dim==3
    nb_ele=10;
elseif dim==4
    nb_ele=6;
elseif dim==5;
    nb_ele=4;
elseif dim==6
    nb_ele=3;
else 
    fprintf('##############################\n');
    fprintf('### Dimension du pb ne permettant pas la creation \n de la grille d''affichage ou de verification ####\n');
    fprintf('##############################\n');
end