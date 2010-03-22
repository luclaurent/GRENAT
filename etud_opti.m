%Fichier d'étude et de mise en oeuvre des démarche de la biblio
%L LAURENT   --  31/01/2010   --  luc.laurent@ens-cachan.fr
clf;clc;close all; clear all;
addpath('doe/lhs');addpath('dace');addpath('doe');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Définition de l'espace de conception
esp.type='auto';   %gestion automatique de l'espace de conception pour fonction étudiée standards
xmin=-2;
xmax=2;
ymin=-1;
ymax=3;
%Fonction utilisée
fct='peaks';    %fonction utilisée (rosenbrock: 'rosen' / peaks: 'peaks')
%pas du tracé
pas=0.1;

%%DOE
%type  LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
meta.doe='ffact';

%nb d'échantillons
nb_samples=9;

%%Métamodèle
%type d'interpolation
%PRG: regression polynomiale
%KRG: krigeage (utilisation de la toolbox DACE)
%RBF: fonctions à base radiale
%POD: décomposition en valeurs singulières
meta.type='RBF';
%degré de linterpolation/regression (si nécessaire)
meta.deg=[2 3 4];
%paramètre Krigeage
meta.theta=0.5;
meta.regr='regpoly2';
meta.corr='correxp';
%paramètre RBF
meta.para=0.8;
meta.fct='gauss';     %fonction à base radiale: 'gauss', 'multiqua', 'invmultiqua' et 'Cauchy'
%paramètre POD
meta.nb_vs=3;        %nombre de valeurs singulières à prendre en compte

%affichage actif ou non
aff.on=true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%définition du domaine d'étude
switch esp.type
    case 'auto'
        disp('Définition auto du domaine de conception');
        switch fct
            case 'rosen'
                xmin=-2;
                xmax=2;
                ymin=-1;
                ymax=3;
            case 'peaks'
                xmin=-3;
                xmax=3;
                ymin=-3;
                ymax=3;
        end
    case 'manu'
        disp('Définition manu du domaine de conception');
end



%Tracé de la fonction de la fonction étudiée
x=xmin:pas:xmax;
y=ymin:pas:ymax;
[X,Y]=meshgrid(x,y);

switch fct
    case 'rosen'
        Z=rosenbrock(X,Y);
    case 'peaks'
        Z=peaks(X,Y);
end


%% Tirages: plan d'expérience
disp('===== DOE =====');

%LHS uniform
Xmin=[xmin,ymin];
Xmax=[xmax,ymax];
switch meta.doe
    case 'ffact'
        tirages=factorial_design(nb_samples,nb_samples,xmin,xmax,ymin,ymax);
    case 'sfill'
        xxx=linspace(xmin,xmax,nb_samples);
        yyy=linspace(ymin,ymax,nb_samples);
        tirages=zeros(size(xxx,2)^2,2);
        for ii=1:size(xxx,2)
            for jj=1:size(xxx,2)
                tirages(size(xxx,2)*(ii-1)+jj,1)=xxx(ii);
                tirages(size(xxx,2)*(ii-1)+jj,2)=yyy(jj);
            end
        end
    case 'LHS'
        tirages=lhsu(Xmin,Xmax,nb_samples);
    otherwise
        error('le type de tirage nest pas défini');
end

%évaluations aux points
switch fct
    case 'rosen'
        eval=rosenbrock(tirages(:,1),tirages(:,2));
    case 'peaks'
        eval=peaks(tirages(:,1),tirages(:,2));
end


%%Affichage courbe initiale
%paramètrage options
aff.newfig=true;
aff.contour=true;
aff.rendu=true;
aff.uni=false;
aff.pts=true;
aff.titre='Surface de la fonction objectif';
aff.xlabel='x_{1}';
aff.ylabel='x_{2}';
aff.zlabel='F';
affichage(X,Y,Z,tirages,eval,aff);

%% Génération du métamodèle
disp('===== METAMODELE =====');


switch meta.type
    case 'PRG'
        for degre=meta.deg
            disp('>>> Régression polynomiale');
            [coef,MSE]=meta_prg(tirages,eval,degre);
            disp(MSE)
            ZRG=polyrg(coef,X,Y,degre);

            %%%affichage de la surface obtenue par PRG
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.titre=['Surface obtenue par régression polynômiale de degré ',num2str(degre)];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{PRG}';
            affichage(X,Y,ZRG,tirages,eval,aff);

            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=false;
            aff.titre=['Surface obtenue par régression polynômiale de degré ',num2str(degre)];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,ZRG,tirages,eval,aff);
        end



    case 'KRG' %utilisation de la Toolbox DACE
        disp('>>> Interpolation par Krigeage');
        [model,perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.theta);
        Zk=zeros(size(X));
        for ii=1:size(X,1)
            for jj=1:size(X,2)
                ZK(ii,jj)=predictor([X(ii,jj) Y(ii,jj)],model);
            end
        end
        
            %%%affichage de la surface obtenue par KRG
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{KRG}';
            affichage(X,Y,ZK,tirages,eval,aff);

            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,ZK,tirages,eval,aff);
        


    case 'RBF'  %fonctions à base radiale
        disp('>>> Interpolation par fonctions à base radiale');
        w=meta_rbf(tirages,eval,meta.para,meta.fct);
        ZRBF=eval_rbf(X,Y,tirages,w,meta.para,meta.fct);
        
        
            %%%affichage de la surface obtenue par RBF
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.titre=['Surface obtenue par interpolation par fonctions à base radiale: r=',num2str(meta.para),' fonction  ',meta.fct];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{RBF}';
            affichage(X,Y,ZRBF,tirages,eval,aff);

            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=false;
            aff.titre=['Surface obtenue par interpolation par fonctions à base radiale: r=',num2str(meta.para),' fonction  ',meta.fct];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,ZRBF,tirages,eval,aff);
        
        
        

        
    case 'POD'  %décomposition en valeurs singulières
        disp('>>> décomposition en valeurs singulières');
        S=meta_pod(tirages,xxx,yyy,eval,meta.nb_vs);
        extr_vs=zeros(size(S,1),2);
        for ii=1:size(S,1)
            extr_vs(ii,1)=ii;
            extr_vs(ii,2)=S(ii,ii);
        end
end
        

   