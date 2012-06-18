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
doe.nb_samples=10;

% Parametrage du metamodele
data.para.long=[10^-3 30];
data.para.swf_para=4;
data.para.rbf_para=1;
%long=3;
data.corr='sexp';
data.rbf='sexp';
data.type='GRBF';
data.grad=false;
if strcmp(data.type,'CKRG')||strcmp(data.type,'GRBF')||strcmp(data.type,'InKRG')||strcmp(data.type,'InRBF')
    data.grad=true;
end
data.deg=0;

meta=init_meta(data);

meta.para.estim=false;
meta.cv=true;
meta.norm=false;
meta.recond=false;
meta.para.type='Manu'; %Franke/Hardy
meta.para.method='fmincon';
meta.para.val=3.4736;%1/sqrt(2);%2;
meta.para.pas_tayl=10^-2;
meta.para.aniso=true;
meta.para.aff_estim=true;
meta.para.aff_iter_cmd=true;
meta.para.aff_iter_graph=true;
meta.para.aff_plot_algo=false;
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%etude CV 
paramin=10^-4;
paramax=30;
nbpara=500;
valpara=linspace(paramin,paramax,nbpara);
meta.cv_aff=false;
for ii=1:nbpara
%Construction et evaluation du metamodele aux points souhaites
fprintf('%4.2f ',ii/nbpara*100)
meta.para.val=valpara(ii);
[approx]=const_meta(tirages,eval,grad,meta);
[K]=eval_meta(grid_XY,approx,meta);
cond_mat(ii)=approx.build.cond;
rippa(ii)=approx.cv.eloot;
perso(ii)=approx.cv.perso.eloot;
%calcul et affichage des criteres d'erreur
err=crit_err(K.Z,Z.Z,approx);
emse(ii)=err.emse;
rmse(ii)=err.rmse;
eq3(ii)=err.eq3;
r2(ii)=err.r2;
r2adj(ii)=err.r2adj;
end
figure
semilogy(valpara,rippa,'r')
hold on
semilogy(valpara,perso,'b')
semilogy(valpara,emse,'g')
semilogy(valpara,rmse,'k')
semilogy(valpara,eq3,'m')
semilogy(valpara,r2,'-.r')
semilogy(valpara,r2adj,'-.k')
legend('Rippa/Bomp (CV)','Moi (CV)','MSE','RMSE','eq3','r2','R2adj');

PP=[valpara' cond_mat'];
save('1D_para_cond.dat','PP','-ascii')
PP=[valpara' rippa'];
save('1D_para_rippa.dat','PP','-ascii')
PP=[valpara' perso'];
save('1D_para_perso.dat','PP','-ascii')
PP=[valpara' rmse'];
save('1D_para_rmse.dat','PP','-ascii')
PP=[valpara' eq3'];
save('1D_para_eq3.dat','PP','-ascii')
PP=[valpara' r2'];
save('1D_para_r2.dat','PP','-ascii')




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
