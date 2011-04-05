%% Initialisation bornes de l'espace d'etude
%% L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

function [esp,fun]=init_doe(fct,def)

%définition automatique
if nargin==1
    switch fct
        case 'rosenbrock'
            xmin=-2;xmax=2;ymin=-1;ymax=3;
            
        case 'branin'
            xmin=-5;xmax=10;ymin=0;ymax=15;            
        case 'gold'
            val=2;xmin=-val;xmax=val;ymin=-val;ymax=val;            
        case 'peaks'
            val=3;xmin=-val;xmax=val;ymin=-val;ymax=val;
        case 'sixhump'
            xmin=-2;xmax=2;ymin=-1;ymax=1; 
        case 'schwefel'
            val=500;xmin=-val;xmax=val;ymin=-val;ymax=val;
        case 'mystery'
            val=5;xmin=0;xmax=val;ymin=0;ymax=val;
    end
    esp=[xmin xmax;ymin ymax];
end

%définition manuelle
if nargin==2
    esp=def;
end

%nom de la fonction a appeler
fun=['fct_' fct];

