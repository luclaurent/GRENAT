%% Initialisation bornes de l'espace d'etude
%% L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

function [doe]=init_doe(fct,dim,def)

%definition automatique
switch fct
    case 'manu'
        esp=[0 15];
    case 'rosenbrock'
        val=2.048;
        esp=val*[-ones(dim,1),ones(dim,1)];
    case 'branin'
        xmin=-5;xmax=10;ymin=0;ymax=15;
        esp=[xmin xmax;ymin ymax];
    case 'gold'
        val=2;xmin=-val;xmax=val;ymin=-val;ymax=val;
        esp=[xmin xmax;ymin ymax];
    case 'peaks'
        val=3;xmin=-val;xmax=val;ymin=-val;ymax=val;
        esp=[xmin xmax;ymin ymax];
    case 'sixhump'
        xmin=-2;xmax=2;ymin=-1;ymax=1;
        esp=[xmin xmax;ymin ymax];
    case 'schwefel'
        val=500;xmin=-val;xmax=val;ymin=-val;ymax=val;
        esp=[xmin xmax;ymin ymax];
    case 'mystery'
        val=5;xmin=0;xmax=val;ymin=0;ymax=val;
        esp=[xmin xmax;ymin ymax];
    case {'bohachevsky1','bohachevsky2','bohachevsky3'}
        val=100;
        esp=[-val,val;-val,val];
    case 'booth'
        val=10;
        esp=[-val,val;-val,val];
    case 'colville'
        val=10;
        esp=val*[-1,1;-1,1;-1,1;-1,1];
    case {'dixon','sphere','sumsquare'}
        val=10;
        esp=val*[-ones(dim,1),ones(dim,1)];
    case 'michalewicz'
        val=pi;
        esp=val*[zeros(dim,1),ones(dim,1)];
    case {'null','cste','pente'}
        val=5;
        esp=val*[-ones(dim,1),ones(dim,1)];
    case {'dejong','AHE','rastrigin'}
        val=5.12;
        esp=val*[-ones(dim,1),ones(dim,1)];
    case 'RHE'
        val=65.536;
        esp=val*[-ones(dim,1),ones(dim,1)];
end

doe.dim_pb=dim;

%sauvegarde nom fonction
doe.fct=['fct_' fct];

%tri par rapport à un variable
doe.tri=1;

%affichage tirages
doe.aff=true;

%definition manuelle
if nargin==3&&~isempty(def)
    doe.bornes=def;
else
    doe.bornes=esp;
end

%nom de la fonction a appeler
fun=['fct_' fct];

