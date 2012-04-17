%%Etude enrichissement
%%L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

%effacement du Workspace
clear all
global aff

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

%fonction etudiee
fct='peaks';
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
aff.nbele=200;

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace
%(sfill)/LHS_R/IHS_R
doe.type='LHS_R';

%nb d'echantillons
doe.nb_samples=3;

% Parametrage du metamodele
data.para.deg=0;
data.para.long=[10^-4 20];
data.para.swf_para=4;
data.para.rbf_para=1;
%long=3;
data.corr='matern32';
data.rbf='gauss';
data.type='KRG';
data.grad=true;

meta=init_meta(data);


%affichage de l'intervalle de confiance
aff.ic.on=true;
aff.ic.type='68'; %('0','68','95','99')

%sauvegarde dans un dossier active ou non
meta.save=false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creation du dossier de travail
[aff.doss,aff.date]=init_dossier(meta,doe,'_2D');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction metamodele=======');
disp('=====================================');
disp('=====================================');

%realisation des tirages
tirages=gene_doe(doe);
%load('cm2011_27eval.mat')
%tirages=tir_ckrg_9;

%Trace de la fonction de la fonction etudiee et des gradients
[grid_XY,aff]=gene_aff(doe,aff);
[Z.Z,Z.GZ]=gene_eval(doe.fct,grid_XY,'aff');

%nombre total de points ajoutés
nbs_max=30;
approx_stock=cell(nbs_max-doe.nb_samples,1);
meta_stock=cell(nbs_max-doe.nb_samples,1);
err=cell(nbs_max-doe.nb_samples,1);


ite=1;
for ii=doe.nb_samples:nbs_max
    %evaluations de la fonction aux points
    [eval,grad]=gene_eval(doe.fct,tirages,'eval');
    
    %procédure d'enrichissement
    meta.cv_aff=false;
    [approx_stock{ite}]=const_meta(tirages,eval,grad,meta);
    [meta_stock{ite}]=eval_meta(grid_XY,approx_stock{ite},meta);
    %calcul et affichage des criteres d'erreur
    err{ite}=crit_err(meta_stock{ite}.Z,Z.Z,approx_stock{ite});
    
    %ajout de nouveaux points par LHS enrichi
    new_tirages=ajout_tir_doe(doe,tirages);
    
    tirages=[tirages;new_tirages];
    
    ite=ite+1;
end

cv_bm=zeros(size(approx_stock));
cv_msep=cv_bm;
cv_press=cv_bm;
cv_adequ=cv_bm;
emse=cv_bm;
r2=cv_bm;
eraae=cv_bm;
ermae=cv_bm;
eq1=cv_bm;
eq2=cv_bm;
eq3=cv_bm;

for ii=1:numel(approx_stock)
    cv_bm(ii)=approx_stock{ii}.cv.bm;
    cv_msep(ii)=approx_stock{ii}.cv.msep;
    cv_press(ii)=approx_stock{ii}.cv.press;
    cv_adequ(ii)=approx_stock{ii}.cv.adequ;
    emse(ii)=err{ii}.emse;
    r2(ii)=err{ii}.emse;
    eraae(ii)=err{ii}.eraae;
    ermae(ii)=err{ii}.ermae;
    eq1(ii)=err{ii}.eq1;
    eq2(ii)=err{ii}.eq2;
    eq3(ii)=err{ii}.eq3;
end

figure
subplot(4,3,1)
semilogy(doe.nb_samples:nbs_max,cv_bm)
subplot(4,3,2)
semilogy(doe.nb_samples:nbs_max,cv_msep)

subplot(4,3,3)
semilogy(doe.nb_samples:nbs_max,cv_press)

subplot(4,3,4)
semilogy(doe.nb_samples:nbs_max,cv_adequ)

subplot(4,3,5)
semilogy(doe.nb_samples:nbs_max,emse)

subplot(4,3,6)
semilogy(doe.nb_samples:nbs_max,r2)

subplot(4,3,7)
semilogy(doe.nb_samples:nbs_max,eraae)

subplot(4,3,8)
semilogy(doe.nb_samples:nbs_max,ermae)

subplot(4,3,9)
semilogy(doe.nb_samples:nbs_max,eq1)
subplot(4,3,10)
semilogy(doe.nb_samples:nbs_max,eq2)
subplot(4,3,11)
semilogy(doe.nb_samples:nbs_max,eq3)


