%% Initialisation bornes de l'espace d'etude
%% L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

function [doe]=init_doe(fct,dim,def)


fprintf('=========================================\n')
fprintf('      >>> INITIALISATION DOE <<<\n');
[tMesu,tInit]=mesu_time;

%definition automatique
switch fct
    case 'manu'
        esp=[-1 15];
        dim=1;
    case 'ackley'
        val=1.5;
        esp=val*[-ones(dim,1),ones(dim,1)];
    case {'rosenbrock','rosenbrockM'}
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
        val=500;
        esp=val*[-ones(dim,1),ones(dim,1)];
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

%recuperation informations fonction (minima locaux et globaux)
[~,~,doe.infos]=feval(doe.fct,[],dim);

%tri par rapport à un variable
doe.tri=1;

%affichage tirages
doe.aff=true;


%definition manuelle
if nargin==3&&~isempty(def)
    doe.Xmin=def(:,1);
    doe.Xmax=def(:,2);
else
    doe.Xmin=esp(:,1);
    doe.Xmax=esp(:,2);
end
doe.bornes=[doe.Xmin,doe.Xmax];

%nom de la fonction a appeler
fun=['fct_' fct];

fprintf('++ Fonction prise en compte: %s (%iD)\n',fct,dim);
fprintf('++ Espace etude:\n');
fprintf('   Min  |');
fprintf('%+4.2f|',doe.Xmin);fprintf('\n');
fprintf('   Max  |');
fprintf('%+4.2f|',doe.Xmax);fprintf('\n');
fprintf('++ Tri variable par rapport à la %i variable\n',doe.tri);
fprintf('++ Affichage tirages: ');
if doe.aff; fprintf('Oui\n');else fprintf('Non\n');end

mesu_time(tMesu,tInit);
fprintf('=========================================\n')