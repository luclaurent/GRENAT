%%Etude métamodèles en 2D
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

%effacement du Workspace
clear all

%chargement des répertoires de travail
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

%pas du trace
aff.pas=0.25;

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
doe.type='LHS';

%nb d'echantillons
doe.nb_samples=10;

% Parametrage du metamodele
deg=0;
theta=0.5;
corr='gauss';
mod='KRG';
meta=init_meta(mod,deg,theta,corr);

%affichage de l'intervalle de confiance
aff.ic.on=true;
aff.ic.type='68'; %('0','68','95','99')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Création du dossier de travail
aff.doss=init_dossier(meta,doe,'_2D');

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
grid_XY=gene_aff(doe,aff);
[Z.Z,Z.grad]=gene_eval(doe.fct,grid_XY);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construction et evaluation du metamodele aux points souhaites
[K.Z,K.GZ,var,krg]=gene_meta(tirages,eval,grad,grid_XY,meta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%generation des differents intervalles de confiance
[ic68,ic95,ic99]=const_ic(K.Z,var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%affichage
aff.on='true';
aff.newfig=true;
aff.ic.on=true;
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
    aff.titre='';
    aff.rendu=false;
end
            
%fonction de reference
aff.newfig=true;
aff.d3=true;
aff.pts=true;
aff.color='red';
affichage(grid_XY,Z,tirages,eval,aff);
aff.color='green';
affichage(grid_XY,K,tirages,eval,aff);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde image
aff.num=save_aff(aff.num,aff.doss);

%calcul et affichage des critères d'erreur
err=crit_err(K.Z,Z.Z,krg);

fprintf('=====================================\n');
fprintf('=====================================\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sauvegarde WorkSpace
save_WS(aff.doss);
