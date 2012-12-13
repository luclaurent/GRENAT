%%Etude qualite prediction en dimension elevee par approche moyennee
%%L. LAURENT -- 14/05/2012 -- laurent@lmt.ens-cachan.fr

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
%execution parallele (option et lancement des workers)
parallel.on=true;
parallel.workers='manu';
parallel.num_workers=8;
exec_parallel('start',parallel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nombre tirages mini et maxi
nb_tir_mini=5;
nb_tir_maxi=200;
pas_tir=5;
list_nb_tir=nb_tir_mini:pas_tir:nb_tir_maxi;
num_tir_list=numel(list_nb_tir);

algo_estim='ga';

%nb de tentative (pour approche moyenne)
nb_tent=1;

%construction des mï¿½tamodï¿½les
type_conf={'KRG','CKRG','RBF','GRBF','InKRG','InRBF'};
nb_conf=numel(type_conf);

%nombre échantillons pour vérification
nb_tir_verif=3000;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fonction etudiee
fct='rosenbrock';
%beale(2),bohachevky1/2/3(2),booth(2),branin(2),coleville(4)
%dixon(n),gold(2),michalewicz(n),mystery(2),peaks(2),rosenbrock(n)
%sixhump(2),schwefel(n),sphere(n),sumsquare(n),AHE(n),cste(n),dejong(n)
%rastrigin(n),RHE(n)
% dimension du pb (nb de variables)
doe.dim_pb=4;
%esp=[0 15];
esp=[];

%%Definition de l'espace de conception
[doe]=init_doe(fct,doe.dim_pb,esp);

%nombre d'element pas dimension (pour le trace)
aff.nbele=30;%max([3 floor((30^2)^(1/doe.dim_pb))]);

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace
%(sfill)/LHS/IHS_R/LHS_manu/LHS_manu/IHS_R_manu
doe.type='LHS';

%nb d'echantillons
doe.nb_samples=15;
doe.aff=false;

% Parametrage du metamodele
data.para.long=[10^-3 30];
data.para.swf_para=4;
data.para.rbf_para=1;
%long=3;
data.corr='matern32';
data.rbf='matern32';
data.type='CKRG';
data.grad=false;
if strcmp(data.type,'CKRG')||strcmp(data.type,'GRBF')||strcmp(data.type,'InKRG')||strcmp(data.type,'InRBF')
    data.grad=true;
end
data.deg=0;

meta=init_meta(data);

meta.rbf=['rf_' data.rbf];

meta.para.estim=true;
meta.cv=true;
meta.cv_aff=false;
meta.norm=true;
meta.recond=true;
meta.para.type='Manu'; %Franke/Hardy
meta.para.val=0.5;
meta.para.pas_tayl=10^-4;
meta.para.aniso=true;
meta.para.estim=true;
meta.para.method=algo_estim;
meta.para.aff_estim=false;
meta.para.aff_iter_cmd=true;
meta.para.aff_iter_graph=false;
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


%%% Evalution de la fonction de rï¿½fï¿½rences
%Trace de la fonction de la fonction etudiee et des gradients
[grid_XY]=lhsu(doe.Xmin,doe.Xmax,nb_tir_verif);
[Z.Z,Z.GZ]=gene_eval(doe.fct,grid_XY,'eval');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% boucle sur les tentatives

for iter_tent=1:nb_tent
    %boucles sur les tirages
    for jj=1:num_tir_list
        doe.nb_samples=list_nb_tir(jj);
        
        %realisation des tirages
        tirages=gene_doe(doe);
        %tirages=[0.25;1.5;3.5;5;5.5;14.5];
        %load('cm2011_27eval.mat')
        %tirages=tir_ckrg_9;
        
        %evaluations de la fonction aux points
        [eval,grad]=gene_eval(doe.fct,tirages,'eval');
        
        %boucle sur les type de mï¿½tamodeles
                for ll=1:numel(type_conf)
			
			if jj>=21
				meta.para.estim=false;
				meta.para.val=val_extr{ll};
			end  
            meta.type=type_conf{ll};
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Construction et evaluation du metamodele aux points souhaites
            [approx{ll}{iter_tent,jj}]=const_meta(tirages,eval,grad,meta);
                        [K{ll}{iter_tent,jj}]=eval_meta(grid_XY,approx{ll}{iter_tent,jj},meta);
            
            if jj==20
            	app=approx{ll}{iter_tent,jj};
				val_extr{ll}=app.build.para.val;
			end 
            
            
            %calcul et affichage des criteres d'erreur
            err=crit_err(K{ll}{iter_tent,jj}.Z,Z.Z,approx{ll}{iter_tent,jj});
            mse{ll}(iter_tent,jj)=err.emse;
            rmse{ll}(iter_tent,jj)=err.rmse;
            r2{ll}(iter_tent,jj)=err.r2;
            r2adj{ll}(iter_tent,jj)=err.r2adj;
            r{ll}(iter_tent,jj)=err.r;
            radj{ll}(iter_tent,jj)=err.radj;
            eraae{ll}(iter_tent,jj)=err.eraae;
            ermae{ll}(iter_tent,jj)=err.ermae;
            eq1{ll}(iter_tent,jj)=err.eq1;
            eq2{ll}(iter_tent,jj)=err.eq2;
            eq3{ll}(iter_tent,jj)=err.eq3;
            if strcmp(type_conf{ll},'KRG')||strcmp(type_conf{ll},'CKRG')
                scvr_mean{ll}(iter_tent,jj)=err.cv.scvr_mean;
                scvr_max{ll}(iter_tent,jj)=err.cv.scvr_max;
                scvr_min{ll}(iter_tent,jj)=err.cv.scvr_min;
            end
            cvbm{ll}(iter_tent,jj)=err.cv.bm;
            cveloot{ll}(iter_tent,jj)=err.cv.eloot;
            cvpress{ll}(iter_tent,jj)=err.cv.press;
cond_new{ll}(iter_tent,jj)=approx{ll}{iter_tent,jj}.build.cond_new;
approx{ll}{iter_tent,jj}=rmfield(approx{ll}{iter_tent,jj},'build');

            %cverrp{ll}(iter_tent,jj)=err.cv.errp;
    %sauvegarde
fichier=['MOY_QUAL_' doe.fct '_' algo_estim '_' num2str(doe.dim_pb) 'DlBB.mat'];
fichierB=['MOY_QUAL_' doe.fct '_' algo_estim '_' num2str(doe.dim_pb) 'DlB.mat'];
save(fichierB,'-v7.3')
unix(['rm ' fichier]);
unix(['cp ' fichierB ' ' fichier]);
unix(['rm ' fichierB]);
      
        end
    end
end
    %sauvegarde
fichier=['MOY_QUAL_' doe.fct '_' algo_estim '_' num2str(doe.dim_pb) 'DlBB.mat'];
fichierB=['MOY_QUAL_' doe.fct '_' algo_estim '_' num2str(doe.dim_pb) 'DlB.mat'];
save(fichierB,'-v7.3')
unix(['rm ' fichier]);
unix(['cp ' fichierB ' ' fichier]);
unix(['rm ' fichierB]);

%traitement
moy_r2=zeros(nb_conf,num_tir_list);
moy_r2adj=moy_r2;
moy_mse=moy_r2;
moy_rmse=moy_r2;
moy_r=moy_r2;
moy_radj=moy_r2;
moy_eraae=moy_r2;
moy_ermae=moy_r2;
moy_eq1=moy_r2;
moy_eq2=moy_r2;
moy_eq3=moy_r2;
moy_cvbm=moy_r2;
moy_cveloot=moy_r2;
moy_cvpress=moy_r2;
%moy_cverrp=moy_r2;


for ii=1:nb_conf
    moy_r2adj(ii,:)=mean(r2adj{ii});
    moy_r2(ii,:)=mean(r2{ii});
    moy_mse(ii,:)=mean(mse{ii});
    moy_rmse(ii,:)=mean(rmse{ii});
    moy_r(ii,:)=mean(r{ii});
    moy_radj(ii,:)=mean(radj{ii});
    moy_eraae(ii,:)=mean(eraae{ii});
    moy_ermae(ii,:)=mean(ermae{ii});
    moy_eq1(ii,:)=mean(eq1{ii});
    moy_eq2(ii,:)=mean(eq2{ii});
    moy_eq3(ii,:)=mean(eq2{ii});
    moy_cvbm(ii,:)=mean(cvbm{ii});
    moy_cveloot(ii,:)=mean(cveloot{ii});
    moy_cvpress(ii,:)=mean(cvpress{ii});
    %moy_cverrp(ii,:)=mean(cverrp{ii});
end


%sauvegarde
fichier=['MOY_QUAL_' doe.fct '_' algo_estim '_' num2str(doe.dim_pb) 'DlBB.mat'];
fichierB=['MOY_QUAL_' doe.fct '_' algo_estim '_' num2str(doe.dim_pb) 'DlB.mat'];
save(fichierB,'-v7.3')
unix(['rm ' fichier]);
unix(['cp ' fichierB ' ' fichier]);
unix(['rm ' fichierB]);

%arret workers
exec_parallel('stop',parallel)

