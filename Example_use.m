% Example of use of GRENAT without the sampling toolbox
% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

init_rep_GRENAT();
clean;

%display the date
disp_date;

%initialization of display variables
aff=init_aff();

fprintf('=========================================\n')
fprintf('  >>>   Building surrogate model    <<<\n');
[tMesu,tInit]=mesu_time;

%parallel execution (options and starting of the workers)
parallel.on=false;
parallel.workers='auto';
exec_parallel('start',parallel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Load of a set of 2D data
C=load('src/various/example_doe.mat');
%sampling points
sampling=C.samples.sampling;
%responses at sample points
resp=C.samples.resp;
%gradients at sample points
grad=C.samples.grad;

%pour affichage et comparaison avec la vraie fonction
%grille reguliere
grid_ref=C.ref.grid;
%valeurs aux points de la grille
eval_ref=C.ref.eval;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement des parametres metamodele
meta=init_meta;
meta.type='CKRG';
meta.cv_aff=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construction et evaluation du metamodele aux points souhaites
[approx]=const_meta(tirages,resp,grad,meta);
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
affichage(grid_ref,eval_ref,tirages,resp,grad,aff);
subplot(2,3,2)
aff.titre='Fonction approchee';
affichage(grid_ref,K.Z,tirages,resp,grad,aff);
subplot(2,3,4)
aff.titre='';
aff.rendu=false;
aff.d3=false;
aff.d2=true;
aff.contour=true;
aff.grad_eval=true;
ref.Z=eval_ref;
affichage(grid_ref,ref,tirages,resp,grad,aff);
subplot(2,3,5)
affichage(grid_ref,K,tirages,resp,grad,aff);
subplot(2,3,3)
aff.d3=true;
aff.d2=false;
aff.contour=false;
aff.grad_eval=false;
aff.rendu=true;
aff.titre='Variance';
affichage(grid_ref,K.var,tirages,resp,grad,aff);
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
