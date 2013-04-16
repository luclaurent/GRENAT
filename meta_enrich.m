%% Enrichissement avec crit�res
%%L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

%effacement du Workspace
clear all
global aff doe

%chargement des repertoires de travail
init_rep;
%initialisation de l'espace de travail
init_esp;
%affichage de la date et de l'heure
aff_date;
%initialisation des variables d'affichage
init_aff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%execution parallele (option et lancement des workers)
parallel.on=true;
parallel.workers='auto';
exec_parallel('start',parallel);
%fonction etudiee
fct='rastrigin'; 
%beale(2),bohachevky1/2/3(2),booth(2),branin(2),coleville(4)
%dixon(n),gold(2),michalewicz(n),mystery(2),peaks(2),rosenbrock(n)
%sixhump(2),schwefel(n),sphere(n),sumsquare(n)
% dimension du pb (nb de variables)
doe.dim_pb=2;
%esp=[-5 5];
esp=[];

%%Definition de l'espace de conception
[doe]=init_doe(fct,doe.dim_pb,esp);

%nombre d'element pas dimension (pour le trace)
aff.nbele=gene_nbele(doe.dim_pb);

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace
%(sfill)/LHS_R/IHS_R
doe.type='LHS';

%nb d'echantillons
doe.nb_samples=20;

% Parametrage du metamodele
data.deg=0;
data.para.long=[0.5 20];
data.para.swf_para=4;
data.para.rbf_para=1;
%long=3;
data.corr='matern32_m';
data.rbf='matern32_m';
data.type='KRG';
data.grad=true;

meta=init_meta(data);
meta.para.estim=true;

%parametrage enrichissement
meta.enrich.para_wei=0.5;
meta.enrich.para_gei=5;
meta.enrich.para_lcb=0.5;
%enrich.crit_type={'NB_PTS','CONV_REP','CONV_LOC','CV_MSE','HIST_R2','HIST_Q3'};% CV_MSE CONV_REP CONV_LOC
%enrich.val_crit={30,10^-6,10^-6,10^-4,1.,10^-6};%,10^-4};
%'CONV_VAR';'CONV_VARR';'CONV_LCB';...
%    'CONV_LCBR';'CONV_WEI';'CONV_WEIR';...
%    'CONV_EIRb';'CONV_GEIR';'CONV_GEI';...
%    'CONV_EI';'CONV_EIR';'HIST_R2';...
%    'HIST_Q3';'CONV_R2_EX';'CONV_Q3_EX';...
%    'NB_PTS';'CV_MSE';'CONV_REP_EX';...
%    'CONV_LOC_EX';'CONV_REP';'CONV_LOC'
enrich.crit_type={'NB_PTS','CONV_R2_EX','CONV_Q3_EX','HIST_R2',...
    'HIST_Q3','CONV_REP','CONV_LOC',...
    'CONV_LOC_EX','CONV_REP_EX','CV_MSE',...
    'CONV_VAR','CONV_VARR','CONV_LCB',...
    'CONV_LCBR','CONV_WEI','CONV_WEIR',...
    'CONV_EIRb','CONV_WEIRb','CONV_GEIRb',...
    'CONV_GEIR','CONV_GEI','CONV_EI',...
    'CONV_EIRn','CONV_WEIRn','CONV_GEIRn',...
    'CONV_EIR'};
enrich.val_crit={30,1,10^-6,1,...
    10^-6,1e-6,1e-8,...
    1e-6,1e-6,1e-6,...
    1e-6,1e-6,1e-6,...
    1e-6,1e-6,1e-6,...
    1e-3,1e-6,1e-6,...
    1e-6,1e-6,1e-6,...
    1e-6,1e-6,1e-6,...
    1e-6};
enrich.min_glob=doe.infos.min_glob;
enrich.min_loc=doe.infos.min_loc;
enrich.type='EI';
enrich.on=true;
enrich.algo='pso';
enrich.aff_iter_cmd=true;
enrich.aff_evol=true;
enrich.aff_ref=true;

enrich.aff_iter_graph=false;
enrich.aff_iter_cmd=false;
enrich.aff_plot_algo=true;

enrich.optim.algo='pso';
enrich.optim.popInitManu=true;
enrich.optim.aff_iter_graph=false;
enrich.optim.aff_iter_cmd=false;
enrich.optim.aff_plot_algo=true;
enrich.optim.aff_ref=true;
enrich.optim.popManu='IHS';     %strategie tirage population initiale algo GA '', 'LHS','IHS'...
enrich.optim.nbPopInit=20;       %population initiale algo GA
enrich.optim.crit_opti=10^-6;  %critere arret algo optimisation


%affichage de l'intervalle de confiance
aff.ic.on=true;
aff.ic.type='68'; %('0','68','95','99')

%sauvegarde dans un dossier active ou non
meta.save=true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creation du dossier de travail
[aff.doss,aff.date]=init_dossier(meta,doe,'_2D');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=========================================');
disp('=========CONSTRUCTION METAMODELE=========');
disp('=========================================');

%realisation des tirages
tirages=gene_doe(doe);
%load('cm2011_27eval.mat')
%tirages=tir_ckrg_9;

%Trace de la fonction de la fonction etudiee et des gradients
[grid_XY,aff]=gene_aff(doe,aff);
[Z.Z,Z.GZ]=gene_eval(doe.fct,grid_XY,'aff');

%proc�dure d'enrichissement
meta.cv_aff=false;
[approx,enrich,in]=enrich_meta(tirages,doe,meta,enrich);
%evaluation metamodele final
[K]=eval_meta(grid_XY,approx{end},meta);
%evaluation de ts les metamodeles
[Kautre]=eval_meta(grid_XY,approx,meta);
eval=in.eval;
tirages=in.tirages;
grad=in.grad;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%generation des differents intervalles de confiance
[ic68,ic95,ic99]=const_ic(K.Z,K.var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%affichage
%valeur par defaut
aff.on=true;
aff.newfig=false;
aff.ic.on=true;
%valeurs chargees
if doe.dim_pb>2
    aff.on=false;
    aff.ic.on=false;
end

if aff.ic.on 
    figure
subplot(1,2,1)
    aff.rendu=true;
    aff.titre=['Intervalle de confiance IC' aff.ic.type]; 
    switch aff.ic.type
        case '68'
            affichage_ic(grid_XY,ic68,aff);
        case '95'
            affichage_ic(grid_XY,ic95,aff);
        case '99'
            affichage_ic(grid_XY,ic99,aff);
    end
    %subplot(3,3,2)
    aff.titre='Variance de prediction';
    aff.d3=true;
    v.Z=K.var;
    subplot(1,2,2)
    affichage(grid_XY,v,tirages,eval,grad,aff);
    camlight; lighting gouraud; 
    aff.titre='Metamodele';
    aff.rendu=false;
end
            
%fonction de reference
aff.newfig=false;
aff.d3=true;
aff.contour3=true;
aff.pts=true;
aff.titre='Fonction de reference';
figure
subplot(2,2,1)
affichage(grid_XY,Z,tirages,eval,grad,aff);
aff.titre='';
subplot(2,2,2)
affichage(grid_XY,K,tirages,eval,grad,aff);

aff.titre='Fonction de reference';
aff.d3=false;
aff.d2=true;
aff.grad_eval=true;
aff.grad_meta=true;
aff.contour2=true;
subplot(2,2,3)
affichage(grid_XY,Z,tirages,eval,grad,aff);
aff.titre='';
aff.color='r';
subplot(2,2,4)
affichage(grid_XY,K,tirages,eval,grad,aff);
aff.titre=[];



%calcul et affichage des criteres d'erreur
err=crit_err(K.Z,Z.Z,approx);

fprintf('=====================================\n');
fprintf('=====================================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sauvegarde des infos dans un fichier tex
sauv_tex(meta,doe,aff,err,approx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sauvegarde WorkSpace
if meta.save
save([aff.doss '/WS.mat']);
end

extract_aff_nD
