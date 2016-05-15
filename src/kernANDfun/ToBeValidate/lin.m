%% Fonction: lineaire
%% L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@cnam.fr

function [G,dG,ddG]=lin(xx,long)

%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;

%Le parametre interne est defini pour toutes les composantes de xx
if lt(1)*lt(2)==1
    long = long*ones(nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = long(ones(nb_pt,1),:);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension du parametre interne');
end

%calcul de la valeur de la fonction au point xx
td=max(0,1-long.*abs(xx));
ev=prod(td,2);

%Evaluation ou derivee
if nb_out==1
    G=ev;
elseif nb_out==2
    G=ev;
elseif nb_out==3
    G=ev;
else
    error('Mauvais argument de la fonction lin.m');
end  
end
