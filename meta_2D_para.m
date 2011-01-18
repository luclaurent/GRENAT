%%Etude metamodeles en 2D
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

%effacement du Workspace
clear all

%chargement des repertoires de travail
init_rep;
%initialisation de l'espace de travail
init_esp;
%affichage de la date et de l'heure


aff_date;
%initialisation des variables d'affichage
aff=init_aff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fonction etudiee
fct='branin'; %branin,gold,peaks,rosenbrock,sixhump

%%Definition de l'espace de conception
[doe.bornes,doe.fct]=init_doe(fct);

%nombre d'element pas dimension (pour le trace)
aff.nbele=30;

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
doe.type='ffact';

donnees=zeros(15,8);
nbb=0;
for nb=3:10
%nb d'echantillons
doe.nb_samples=nb;

% Parametrage du metamodele
deg=0;
theta=[0 20];
corr='gauss';
mod='KRG';
meta=init_meta(mod,deg,theta,corr);

%affichage de l'intervalle de confiance
aff.ic.on=true;
aff.ic.type='68'; %('0','68','95','99')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creation du dossier de travail
aff.doss=['results/para_' fct '_' doe.type '_' mod];
cmd=['mkdir ' aff.doss];unix(cmd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction metamodele=======');
disp('=====================================');
disp('=====================================');

%realisation des tirages
tirages=gene_doe(doe);

%evaluations de la fonction aux points
[eval,grad]=gene_eval(doe.fct,tirages);

%Trace de la fonction de la fonction etudiee et des gradients
[grid_XY,aff]=gene_aff(doe,aff);
Z=gene_eval(doe.fct,grid_XY);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construction et evaluation du metamodele aux points souhaites
[K,krg]=gene_meta(tirages,eval,grad,grid_XY,meta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%generation des differents intervalles de confiance
[ic68,ic95,ic99]=const_ic(K.Z,K.var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%affichage
aff.on='true';
aff.num=aff.num+1;
aff.newfig=false;
aff.ic.on=true;
figure;
subplot(3,3,1)
if aff.ic.on
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
    subplot(3,3,2)
    aff.titre='Variance de prediction';
    aff.d3=true;
    v.Z=K.var;
    affichage(grid_XY,v,tirages,eval,grad,aff);
    camlight; lighting gouraud; 
    aff.titre='';
    aff.rendu=false;
end
            
%fonction de reference
aff.newfig=false;
aff.d3=true;
aff.contour3=true;
aff.pts=true;
aff.titre='Fonction de reference';
subplot(3,3,4)
affichage(grid_XY,Z,tirages,eval,grad,aff);
aff.titre='Metamodele';
subplot(3,3,5)
affichage(grid_XY,K,tirages,eval,grad,aff);

aff.titre='Fonction de reference';
aff.d3=false;
aff.d2=true;
aff.grad_eval=true;
aff.grad_meta=true;
aff.contour2=true;
subplot(3,3,7)
affichage(grid_XY,Z,tirages,eval,grad,aff);
aff.titre='Metamodele';
subplot(3,3,8)
affichage(grid_XY,K,tirages,eval,grad,aff);
aff.titre=[];
aff.grad_eval=false;
aff.grad_meta=false;
aff.contour2=false;
aff.d2=false;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde image
aff.num=save_aff(aff.num,aff.doss);

%calcul et affichage des criteres d'erreur
err=crit_err(K.Z,Z.Z,krg);

fprintf('=====================================\n');
fprintf('=====================================\n');


%enregistrement données en vue de leur sauvegarde
nbb=nbb+1;
donnees(1,nbb)=nb^2;
donnees(2,nbb)=krg.tps;
donnees(3,nbb)=krg.estim_para.iterations;
donnees(4,nbb)=err.emse;
donnees(5,nbb)=err.r2;
donnees(6,nbb)=err.eraae;
donnees(7,nbb)=err.ermae;
donnees(8,nbb)=err.eq1;
donnees(9,nbb)=err.eq2;
donnees(10,nbb)=err.eq3;
donnees(11,nbb)=krg.cv.bm;
donnees(12,nbb)=krg.cv.msep;
donnees(13,nbb)=krg.cv.adequ;
donnees(14,nbb)=krg.cv.press;
donnees(15,nbb)=krg.estim_para.theta;
clear krg

end

%extraction des données
extract_caract(meta,donnees,aff,fct);
