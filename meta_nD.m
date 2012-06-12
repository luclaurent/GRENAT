%%Etude metamodeles en nD
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
fct='rosenbrock'; 
%beale(2),bohachevky1/2/3(2),booth(2),branin(2),coleville(4)
%dixon(n),gold(2),michalewicz(n),mystery(2),peaks(2),rosenbrock(n)
%sixhump(2),schwefel(n),sphere(n),sumsquare(n),AHE(n),cste(n),dejong(n)
%rastrigin(n),RHE(n)
% dimension du pb (nb de variables)
doe.dim_pb=2;
%esp=[0 15];
esp=[];

%%Definition de l'espace de conception
[doe]=init_doe(fct,doe.dim_pb,esp);

%nombre d'element pas dimension (pour le trace)
aff.nbele=gene_nbele(doe.dim_pb);%max([3 floor((30^2)^(1/doe.dim_pb))]);

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace
%(sfill)/LHS_R/IHS_R/LHS_manu/LHS_R_manu/IHS_R_manu
doe.type='IHS_R_manu';

%nb d'echantillons
doe.nb_samples=3;

% Parametrage du metamodele
data.para.long=[10^-3 30];
data.para.swf_para=4;
data.para.rbf_para=1;
%long=3;
data.corr='sexp';
data.rbf='matern32';
data.type='CKRG';
data.grad=false;
if strcmp(data.type,'CKRG')||strcmp(data.type,'GRBF')||strcmp(data.type,'InKRG')||strcmp(data.type,'InRBF')
    data.grad=true;
end
data.deg=2;

meta=init_meta(data);

meta.para.estim=false;
meta.cv=true;
meta.norm=true;
meta.recond=false;
meta.para.type='Manu'; %Franke/Hardy
meta.para.method='ga';
meta.para.val=1/sqrt(2);%2;
meta.para.pas_tayl=10^-2;
meta.para.aniso=true;
meta.para.aff_estim=false;
meta.para.aff_iter_cmd=true;
meta.para.aff_iter_graph=false;
meta.para.aff_plot_algo=true;
meta.enrich.para_wei=0.5;
meta.enrich.para_lcb=0.5;

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
%realisation des tirages
tirages=gene_doe(doe);
%tirages=[0.25;1.5;3.5;5;5.5;14.5];
%tirages=[-0.5;0;1.5];
%load('cm2011_27eval.mat')
%tirages=tir_ckrg_9;

%evaluations de la fonction aux points
[eval,grad]=gene_eval(doe.fct,tirages,'eval');

%Trace de la fonction de la fonction etudiee et des gradients
[grid_XY,aff]=gene_aff(doe,aff);
[Z.Z,Z.GZ]=gene_eval(doe.fct,grid_XY,'aff');

 grad(2)=NaN;
 grad(6)=NaN;
 eval(3)=NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construction et evaluation du metamodele aux points souhaites
[approx]=const_meta(tirages,eval,grad,meta);
[K]=eval_meta(grid_XY,approx,meta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%generation des differents intervalles de confiance
if isfield(K,'var');[ic68,ic95,ic99]=const_ic(K.Z,K.var);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%affichage
%valeur par d�faut
aff.on=true;
aff.newfig=false;
aff.ic.on=true;
%valeurs chargees
%if doe.dim_pb>2
 %   aff.on=false;
  %  aff.ic.on=false;
%end

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
if aff.on 
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
end

%% affichage des r�ponses sous forme d'un diagramme bar
%figure;
%bar([Z.Z(:) K.Z(:)])

if doe.dim_pb==1
figure
subplot(1,3,1)
plot(grid_XY,Z.Z(:),'r','LineWidth',2)
hold on
plot(grid_XY,K.Z(:),'b','LineWidth',2)
plot(tirages,eval,'ok')
legend('Ref','Approx','Eval');
subplot(1,3,2)
plot(grid_XY,Z.GZ(:),'r','LineWidth',2)
hold on
plot(grid_XY,K.GZ(:),'b','LineWidth',2)
plot(tirages,grad,'ok')
legend('Ref','Approx','Eval');
subplot(1,3,3)
plot(grid_XY,Z.Z(:),'r','LineWidth',2)
hold on
plot(grid_XY,K.Z(:),'b','LineWidth',2)
plot(tirages,eval,'ok')
plot(grid_XY,Z.GZ(:),'--r','LineWidth',2)
plot(grid_XY,K.GZ(:),'--b','LineWidth',2)
plot(tirages,grad,'ok')
legend('Ref','Approx','Eval','dRef','dApprox','dEval');
end

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
%extract_nD

%extract_aff_nD


