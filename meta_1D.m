%%Etude métamodèles en 1D
%%L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

%effacement du Workspace
clear all

global aff

%chargement des répertoires de travail
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
fct='fct';

%%Definition de l'espace de conception
xmin=0;xmax=15;
doe.bornes=[xmin xmax]';

%pas du trace
aff.pas=0.05;

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
doe.type='sfill';

%nb d'echantillons
doe.nb_samples=6;

% Parametrage du metamodele
deg=0;
long=[0.1 100];
%long=1;
corr='matern52';
mod='ILAG';
meta=init_meta(mod,deg,long,corr);


%affichage de l'intervalle de confiance
aff.ic.on=true;
aff.ic.type='95'; %('0','68','95','99')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Création du dossier de travail
aff.doss=init_dossier(meta,doe,'_1D');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction metamodele=======');
disp('=====================================');
disp('=====================================');

%realisation des tirages
tirages=gene_doe(doe);
%tirages=[0.5 2 2.5 5 11 14.5];
tirages=linspace(0,15,40);
tirages=transpose(tirages);

%evaluations de la fonction aux points
[eval,grad]=gene_eval(fct,tirages);

%Trace de la fonction de la fonction etudiee et des gradients
X=[xmin:aff.pas:xmax]';
[Z.Z,Z.grad]=gene_eval(fct,X);

aff.on=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construction et evaluation du metamodele aux points souhaites
[K,krg]=gene_meta(tirages,eval,grad,X,meta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%generation des differents intervalles de confiance
[ic68,ic95,ic99]=const_ic(K.Z,K.var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%affichage
aff.newfig=true;
if aff.ic.on
switch aff.ic.type
    case '68'
        affichage_ic(X,ic68,aff);
    case '95'
        affichage_ic(X,ic95,aff);
    case '99'
        affichage_ic(X,ic99,aff);
end
end
            
%fonction de reference
aff.newfig=false;
aff.color='red';
affichage(X,Z.Z,tirages,eval,[],aff);
aff.newfig=false;
aff.color='blue';
aff.opt='--';
affichage(X,Z.grad,tirages,eval,[],aff);
aff.color='red';
aff.opt='rs';
affichage(tirages,eval,tirages,eval,[],aff);
aff.opt='o';
affichage(tirages,grad,tirages,eval,[],aff);
aff.opt=[];
aff.color='green';
affichage(X,K.Z,tirages,eval,[],aff);
aff.color='blue';
aff.opt='-.';
affichage(X,K.GZ,tirages,eval,[],aff);
aff.color='red';
affichage(X,K.var,tirages,eval,[],aff);

if aff.ic.on
    legend(['IC' aff.ic.type],' ','fct ref','deriv fct ref','Evaluations','derivees','Metamodele','Derivee Metamodele','MSE');
else
    legend('fct ref','deriv fct ref','Evaluations','derivees','Metamodele','Derivee Metamodele','MSE');
end

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
