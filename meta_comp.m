%%Comparaison métamodèles
%%L. LAURENT -- 16/09/2011 -- laurent@lmt.ens-cachan.fr

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
fct='manu';
%beale(2),bohachevky1/2/3(2),booth(2),branin(2),coleville(4)
%dixon(n),gold(2),michalewicz(n),mystery(2),peaks(2),rosenbrock(n)
%sixhump(2),schwefel(n),sphere(n),sumsquare(n),AHE(n),cste(n),dejong(n)
%rastrigin(n),RHE(n)
% dimension du pb (nb de variables)
doe.dim_pb=1;
%esp=[0 15];
esp=[];

%%Definition de l'espace de conception
[doe]=init_doe(fct,doe.dim_pb,esp);

%nombre d'element pas dimension (pour le trace)
aff.nbele=gene_nbele(doe.dim_pb);%max([3 floor((30^2)^(1/doe.dim_pb))]);

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace
%(sfill)/LHS_R/IHS_R/LHS_manu/LHS_R_manu/IHS_R_manu
doe.type='LHS_manu';

%nb d'echantillons
doe.nb_samples=5;

% Parametrage du metamodele
data.para.long=[10^-3 30];
data.para.swf_para=4;
data.para.rbf_para=1;
%long=3;
data.corr='matern32';
data.rbf='matern32';

meta_com={'RBF','GRBF','InRBF','KRG','CKRG','InKRG'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%realisation des tirages
tirages=gene_doe(doe);
%tirages=[0.25;1.5;3.5;5;5.5;14.5];
%load('cm2011_27eval.mat')
%tirages=tir_ckrg_9;

%evaluations de la fonction aux points
[eval,grad]=gene_eval(doe.fct,tirages,'eval');

%Trace de la fonction de la fonction etudiee et des gradients
[grid_XY,aff]=gene_aff(doe,aff);
[Z.Z,Z.GZ]=gene_eval(doe.fct,grid_XY,'aff');

Zm=cell(size(meta_com));

for meta_type=1:numel(meta_com);
    data.type=meta_com{meta_type};
    data.grad=false;
    if strcmp(data.type,'CKRG')||strcmp(data.type,'GRBF')||strcmp(data.type,'InKRG')||strcmp(data.type,'InRBF')
        data.grad=true;
    end
    data.deg=0;
    
    meta=init_meta(data);
    
    meta.para.estim=true;
    meta.cv=true;
    meta.norm=false;
    meta.recond=false;
    meta.para.type='Manu'; %Franke/Hardy
    meta.para.val=0.5;
    meta.para.pas_tayl=10^-2;
    meta.para.aniso=true;
    meta.para.aff_estim=false;
    meta.para.aff_iter_cmd=true;
    meta.para.aff_iter_graph=false;
    meta.enrich.para_wei=0.5;
    meta.enrich.para_lcb=0.5;
    
    %affichage de l'intervalle de confiance
    aff.ic.on=true;
    aff.ic.type='68'; %('0','68','95','99')
    
    %sauvegarde dans un dossier active ou non
    meta.save=false;
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Construction et evaluation du metamodele aux points souhaites
    [approx]=const_meta(tirages,eval,grad,meta);
    [K]=eval_meta(grid_XY,approx,meta);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%generation des differents intervalles de confiance
    if isfield(K,'var');[ic68,ic95,ic99]=const_ic(K.Z,K.var);end
    
    
    %calcul et affichage des criteres d'erreur
    err=crit_err(K.Z,Z.Z,approx);
    Zm{meta_type}=K.Z;
end


color={'r','--r','.r','b','--b','.b'};

figure
plot(grid_XY,Z.Z,'k','LineWidth',2);
hold on
for iii=1:numel(meta_com);
    plot(grid_XY,Zm{iii},color{iii},'LineWidth',2);    
end
tt={'Ref',meta_com{:}};
legend(tt);



