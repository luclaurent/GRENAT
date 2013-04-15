%test PSOT
close all 
clear all
nb_para=2;
fun=@(X)fct_rastrigin(X,nb_para);
fct='rastrigin';
%fun=['fct_' fct];
nbPopInit=20;
popManu='IHS';

doe.dim_pb=nb_para;
%%Definition de l'espace de conception

[doe]=init_doe(fct,doe.dim_pb);

%options algo PSO de la toolbox PSOt
ac      = [2.1,2.1];% acceleration constants, only used for modl=0
Iwt     = [0.9,0.6];  % intertia weights, only used for modl=0
epoch   = 2000; % max iterations
wt_end  = 100; % iterations it takes to go from Iwt(1) to Iwt(2), only for modl=0
errgrad = 1e-99;   % lowest error gradient tolerance
errgraditer=150; % max # of epochs without error change >= errgrad
PSOseed = 0;    % if=1 then can input particle starting positions, if= 0 then all random
% starting particle positions (first 20 at zero, just for an example)
PSOT_plot=[];
PSOT_tirage = [];
PSOT_mv=4; %vitesse maxi des particules (=4 def)
shw=1;      %MAJ affichage a chque iteration (0 sinon)
ps=10*nb_para; %nb de particules
errgoal=NaN;    %cible minimisation
modl=2;         %type de PSO
%                   0 = Common PSO w/intertia (default)
%                 1,2 = Trelea types 1,2
%                 3   = Clerc's Constricted PSO, Type 1"
mvden=2;


PSOT_options= [shw epoch ps ac(1) ac(2) Iwt(1) Iwt(2) ...
    wt_end errgrad errgraditer errgoal modl PSOseed];


PSOT_plot='goplotpso_perso';


%specification manuelle de la population initiale (Ga)

    doePop.Xmin=doe.Xmin;doePop.Xmax=doe.Xmax;doePop.nb_samples=nbPopInit;doePop.aff=false;doePop.type=popManu;
    tir_pop=gene_doe(doePop);
    PSOT_tirage=tir_pop;
    %PSOT_options(13)=1;

%variation des parametres
PSOT_varrange=[doe.Xmin doe.Xmax ];
%minimisation
PSOT_minmax=0;

PSOT_mv=(PSOT_varrange(:,2)-PSOT_varrange(:,1))./mvden;
disp('RUN') 
%PSOt version vectorisee
[pso_out,...    %pt minimum et reponse associee
    tr,...      %pt minimum a chaque iteration
    te...       %epoch? iterations
    ]=pso_Trelea_vectorized(...
    fun,...             %fonction
    nb_para,...         %nombre variables
    PSOT_mv,...         %vitesse maxi particules (def. 4)
    PSOT_varrange,...   %matrice des plages de variation des parametres
    PSOT_minmax,...     %minimisation (=0 def), maximisation (=1) ou autre (=2)
    PSOT_options,...    %vecteur options
    PSOT_plot);       %fonction de tracé (optionnelle)
    %PSOT_tirage);       %tirage initial aleatoire (=0) ou utilisateur (=1)