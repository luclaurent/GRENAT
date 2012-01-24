%%Etude parametres metamodele nD
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
fct='rosenbrock'; 
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
aff.nbele=30;

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace
%(sfill)/LHS_R/IHS_R
doe.type='LHS';

%nb d'echantillons
doe.nb_samples=50;

% Parametrage du metamodele
data.para.deg=0;
data.para.long=[0.5 1];
data.para.swf_para=4;
data.para.rbf_para=1;
%long=3;
data.corr='matern32';
data.rbf='gauss';
data.type='HBRBF';
data.grad=true;

meta=init_meta(data);
meta.para.estim=false;

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

%evaluations de la fonction aux points
[eval,grad]=gene_eval(doe.fct,tirages,'eval');

%Trace de la fonction de la fonction etudiee et des gradients
[grid_XY,aff]=gene_aff(doe,aff);
[Z.Z,Z.GZ]=gene_eval(doe.fct,grid_XY,'aff');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%etude CV 
paramin=10^-4;
paramax=5;
nbpara=100;
valpara=linspace(paramin,paramax,nbpara);
meta.cv_aff=false;
for ii=1:nbpara
%Construction et evaluation du metamodele aux points souhaites
fprintf('%4.2f ',ii/nbpara*100)
meta.para.val=valpara(ii);
[approx]=const_meta(tirages,eval,grad,meta);

bm(ii)=approx.cv.bm;
msep(ii)=approx.cv.msep;
press(ii)=approx.cv.press;
end
figure
subplot(1,3,1)
plot(valpara,bm)
subplot(1,3,2)
plot(valpara,msep);
subplot(1,3,3)
plot(valpara,press);




% [K]=eval_meta(grid_XY,approx,meta);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%generation des differents intervalles de confiance
% [ic68,ic95,ic99]=const_ic(K.Z,K.var);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%affichage
% %valeur par défaut
% aff.on=true;
% aff.newfig=false;
% aff.ic.on=true;
% %valeurs chargees
% if doe.dim_pb>2
%     aff.on=false;
%     aff.ic.on=false;
% end
% 
% if aff.ic.on 
%     figure
% subplot(1,2,1)
%     aff.rendu=true;
%     aff.titre=['Intervalle de confiance IC' aff.ic.type]; 
%     switch aff.ic.type
%         case '68'
%             affichage_ic(grid_XY,ic68,aff);
%         case '95'
%             affichage_ic(grid_XY,ic95,aff);
%         case '99'
%             affichage_ic(grid_XY,ic99,aff);
%     end
%     %subplot(3,3,2)
%     aff.titre='Variance de prediction';
%     aff.d3=true;
%     v.Z=K.var;
%     subplot(1,2,2)
%     affichage(grid_XY,v,tirages,eval,grad,aff);
%     camlight; lighting gouraud; 
%     aff.titre='Metamodele';
%     aff.rendu=false;
% end
%             
% %fonction de reference
% aff.newfig=false;
% aff.d3=true;
% aff.contour3=true;
% aff.pts=true;
% aff.titre='Fonction de reference';
% figure
% subplot(2,2,1)
% affichage(grid_XY,Z,tirages,eval,grad,aff);
% aff.titre='';
% subplot(2,2,2)
% affichage(grid_XY,K,tirages,eval,grad,aff);
% 
% aff.titre='Fonction de reference';
% aff.d3=false;
% aff.d2=true;
% aff.grad_eval=true;
% aff.grad_meta=true;
% aff.contour2=true;
% subplot(2,2,3)
% affichage(grid_XY,Z,tirages,eval,grad,aff);
% aff.titre='';
% aff.color='r';
% subplot(2,2,4)
% affichage(grid_XY,K,tirages,eval,grad,aff);
% aff.titre=[];
% 
% 
% 
% %calcul et affichage des criteres d'erreur
% err=crit_err(K.Z,Z.Z,approx);
% 
% fprintf('=====================================\n');
% fprintf('=====================================\n');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Sauvegarde des infos dans un fichier tex
% sauv_tex(meta,doe,aff,err,approx);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Sauvegarde WorkSpace
% if meta.save
% save([aff.doss '/WS.mat']);
% end
