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
nb_samples=7;

%%Métamodèle
%type d'interpolation
%PRG: regression polynomiale
%KRG: krigeage (utilisation de la toolbox DACE)
%RBF: fonctions à base radiale
%POD: décomposition en valeurs singulières
meta.type='PRG';
%degré de linterpolation/regression (si nécessaire)
meta.deg=2;
%paramètre Krigeage
meta.theta=0.5;
meta.regr='regpoly2';
meta.corr='correxp';
%paramètre RBF
meta.para=0.6;
meta.fct='gauss';     %fonction à base radiale: 'gauss', 'multiqua', 'invmultiqua' et 'Cauchy'
%paramètre POD
meta.nb_vs=3;        %nombre de valeurs singulières à prendre en compte


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

figure;
surfc(X,Y,Z)

hlight=light;              % activ. éclairage
lighting('gouraud')        % type de rendu
lightangle(hlight,48,70) % dir. éclairage
%shading interp


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


%% Génération du métamodèle
disp('===== METAMODELE =====');



switch meta.type
    case 'PRG'
disp('>>> Régression polynomiale');
[coef,MSE]=meta_prg(tirages,eval,meta.deg);
disp(MSE)
ZRG=polyrg(coef,X,Y,meta.deg);






%%%affichage des surfaces
figure;
hold on
surfc(X,Y,ZRG)
hlight=light;
lighting('gouraud')
lightangle(hlight,48,70) % dir. éclairage
hold on
plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                'MarkerFaceColor','g',...
                'MarkerSize',30)
title('Surface obtenue par regression polynomiale');
view(3)

figure;
hold on
surf(X,Y,Z,'FaceColor','white','EdgeColor','blue')
hold on
surf(X,Y,ZRG,'FaceColor','white','EdgeColor','red')
hlight=light;
lighting('gouraud')
lightangle(hlight,48,70) % dir. éclairage
view(3)


figure;
for ii=2
    meta.deg=ii;

[coef,MSE]=meta_prg(tirages,eval,meta.deg);
disp(MSE)
ZRG=polyrg(coef,X,Y,meta.deg);
plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                'MarkerFaceColor','g',...
                'MarkerSize',30)
hold on
surf(X,Y,ZRG)
%colormap hsv
end
%hlight=light;
%lighting('gouraud')
%lightangle(hlight,48,70) % dir. éclairage
%hold on
%plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
%                'MarkerFaceColor','g',...
%                'MarkerSize',30)
%title('Surface obtenue par regression polynomiale');
xlabel('x_{1}')
ylabel('x_{2}')
zlabel('F')

view(3)

figure;
for ii=4
    meta.deg=ii;

[coef,MSE]=meta_prg(tirages,eval,meta.deg);
disp(MSE)
ZRG=polyrg(coef,X,Y,meta.deg);
plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                'MarkerFaceColor','g',...
                'MarkerSize',30)
hold on
surf(X,Y,ZRG)
%colormap hsv
end
%hlight=light;
%lighting('gouraud')
%lightangle(hlight,48,70) % dir. éclairage
%hold on
%plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
%                'MarkerFaceColor','g',...
%                'MarkerSize',30)
%title('Surface obtenue par regression polynomiale');
xlabel('x_{1}')
ylabel('x_{2}')
zlabel('F')
view(3)

    case 'KRG' %utilisation de la Toolbox DACE
        disp('>>> Interpolation par Krigeage');
        [model,perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.theta);
        Zk=zeros(size(X));
        for ii=1:size(X,1)
            for jj=1:size(X,2)
                ZK(ii,jj)=predictor([X(ii,jj) Y(ii,jj)],model);
            end
        end
            %%%affichage des surfaces
        figure;
        hold on
        mesh(x,y,ZK)
        hlight=light;
        lighting('gouraud')
        lightangle(hlight,48,70) % dir. éclairage
        hold on
        plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                        'MarkerFaceColor','g',...
                        'MarkerSize',30)
        title('Surface obtenue par regression polynomiale');
        view(3)

        figure;
        hold on
        surf(X,Y,Z,'FaceColor','white','EdgeColor','blue')
        hold on
        surf(X,Y,ZK,'FaceColor','white','EdgeColor','red')
        hlight=light;
        lighting('gouraud')
        lightangle(hlight,48,70) % dir. éclairage
        view(3)
        
        figure;
        surf(X,Y,ZK)
        xlabel('x_{1}')
        ylabel('x_{2}')
        zlabel('F')
        view(3)

    case 'RBF'  %fonctions à base radiale
        disp('>>> Interpolation par fonctions à base radiale');
        w=meta_rbf(tirages,eval,meta.para,meta.fct);
        ZRBF=eval_rbf(X,Y,tirages,w,meta.para,meta.fct);
         %%%affichage des surfaces
        figure;
        hold on
        mesh(x,y,ZRBF);
        hlight=light;
        lighting('gouraud')
        lightangle(hlight,48,70) % dir. éclairage
        hold on
        plot3(tirages(:,1),tirages(:,2),eval,'.','MarkerEdgeColor','g',...
                        'MarkerFaceColor','g',...
                        'MarkerSize',30)
        title('Surface obtenue par regression polynomiale');
        view(3)

        figure;
        hold on
        surf(X,Y,Z,'FaceColor','white','EdgeColor','blue')
        hold on
        surf(X,Y,ZRBF,'FaceColor','white','EdgeColor','red')
        hlight=light;
        lighting('gouraud')
        lightangle(hlight,48,70) % dir. éclairage
        view(3)
        
        figure;
        surf(X,Y,ZRBF)
        xlabel('x_{1}')
        ylabel('x_{2}')
        zlabel('F')
        view(3)
        
    case 'POD'  %décomposition en valeurs singulières
        disp('>>> décomposition en valeurs singulières');
        S=meta_pod(tirages,xxx,yyy,eval,meta.nb_vs);
        extr_vs=zeros(size(S,1),2);
        for ii=1:size(S,1)
            extr_vs(ii,1)=ii;
            extr_vs(ii,2)=S(ii,ii);
        end
end
        

   