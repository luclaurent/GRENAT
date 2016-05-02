%% Fonction: constante
%% L. LAURENT --  31/08/2015 -- luc.laurent@cnam.fr

function [G,dG,ddG]=constant(xx,long)
%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;

%calcul de la valeur de la fonction au point xx
ev=1+0.*sum(xx,2);

%Evaluation ou derivee
if nb_out==1
    G=ev;
elseif nb_out==2
    G=ev;
elseif nb_out==3
    G=ev;
else
    error('Mauvais argument de la fonction constant.m');
end
end