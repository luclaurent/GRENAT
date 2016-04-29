% Exemple d'utilisation de la Toolbox GRENAT couplee avec LMTir
% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

initDirGRENAT([],'LMTir');
clean;

%affichage de la date
aff_date;

%initialisation des variables d'affichage
global aff
aff=init_aff();

fprintf('=========================================\n')
fprintf('  >>> PROCEDURE ETUDE METAMODELES  <<<\n');
[tMesu,tInit]=mesu_time;

%execution parallele (option et lancement des workers)
parallel.on=false;
parallel.workers='auto';
exec_parallel('start',parallel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fonction etudiee
fct='mystery';
%beale(2),bohachevky1/2/3(2),booth(2),branin(2),coleville(4)
%dixon(n),gold(2),michalewicz(n),mystery(2),peaks(2),rosenbrock(n)
%sixhump(2),schwefel(n),sphere(n),sumsquare(n),AHE(n),cste(n),dejong(n)
%rastrigin(n),RHE(n)
% dimension du pb (nb de variables)
dim_pb=2;
%esp=[0 15];
esp=[];
%%Definition de l'espace de conception
[doe]=init_doe(dim_pb,esp,fct);
%nombre d'element pas dimension (pour le trace)
aff.nbele=gene_nbele(doe.dim_pb);%max([3 floor((30^2)^(1/doe.dim_pb))]);
%type de tirage
doe.type='IHS';
%nb d'echantillons
doe.nb_samples=35;
%execution tirages
tir=gene_doe(doe);
tirages=tir.tri;
%evaluations de la fonction aux points
[eval,grad]=gene_eval(doe.fct,tirages,'eval');
%Trace de la fonction de la fonction etudiee et des gradients
[grid_ref,aff]=gene_aff(doe,aff);
[eval_ref,grad_ref]=gene_eval(doe.fct,grid_ref,'aff');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement des parametres metamodele
data.type='GRBF';
data.rbf='matern32';
meta=init_meta(data);
meta.cv_aff=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construction et evaluation du metamodele aux points souhaites
[approx]=const_meta(tirages,eval,grad,meta);
%evaluation du metamodele aux points de la grille
[K]=eval_meta(grid_ref,approx,meta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%generation des differents intervalles de confiance
if isfield(K,'var');[ic68,ic95,ic99]=const_ic(K.Z,K.var);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%affichage
%valeur par defaut
aff.on=true;
aff.newfig=false;
aff.ic.on=true;
%affichage de l'intervalle de confiance
aff.rendu=true;
aff.d3=true;
aff.xlabel='x_1';
aff.ylabel='x_2';

figure
subplot(2,3,1)
aff.titre='Fonction de reference';
affichage(grid_ref,eval_ref,tirages,eval,grad,aff);
subplot(2,3,2)
aff.titre='Fonction approchee';
affichage(grid_ref,K.Z,tirages,eval,grad,aff);
subplot(2,3,4)
aff.titre='';
aff.rendu=false;
aff.d3=false;
aff.d2=true;
aff.contour=true;
aff.grad_eval=true;
aff.grad_meta=true;
ref.Z=eval_ref;ref.GZ=grad_ref;
affichage(grid_ref,ref,tirages,eval,grad,aff);
subplot(2,3,5)
affichage(grid_ref,K,tirages,eval,grad,aff);
subplot(2,3,3)
aff.d3=true;
aff.d2=false;
aff.contour=false;
aff.grad_meta=false;
aff.grad_eval=false;
aff.rendu=true;
aff.titre='Variance';
affichage(grid_ref,K.var,tirages,eval,grad,aff);
subplot(2,3,6)
aff.titre='Intervalle de confiance a 95%';
aff.trans=true;
aff.uni=true;
 affichage_ic(grid_ref,ic95,aff,K.Z);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%calcul et affichage des criteres d'erreur
err=crit_err(K.Z,eval_ref,approx);
fprintf('=====================================\n');
fprintf('=====================================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%arret workers
exec_parallel('stop',parallel)

mesu_time(tMesu,tInit);
fprintf('=========================================\n')
