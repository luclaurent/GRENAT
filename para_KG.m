%%%Etude de l'influence du param�tre de la fonction de corr�lation
%%%gaussienne sur la qualit� du m�tamod�le de Krigeage construit
%% 21/10/2010


clf;clc;close all; clear all;
addpath('doe/LHS');addpath('meta/dace');addpath('doe');addpath('fct');addpath('meta');
addpath('crit');global cofast;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
day=clock;
fprintf('Date: %d/%d/%d   Time: %02.0f:%02.0f:%02.0f\n', day(3), day(2), day(1), day(4), day(5), day(6))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aff.scale=false;aff.tikz=false;
aff.num=0; %itérateur numéros figures
aff.doss=[num2str(day(1),'%4.0f') '-' num2str(day(2),'%02.0f') '-' num2str(day(3),'%02.0f')...
    '_' num2str(day(4),'%02.0f') '-' num2str(day(5),'%02.0f') '-' num2str(day(6),'%02.0f')]; %dossier de travail (pour sauvegarde figure)
unix(['mkdir ' aff.doss]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Définition de l'espace de conception
esp.type='auto';   %gestion automatique de l'espace de conception pour fonction étudiée standards
xmin=-2;
xmax=2;
ymin=-1;
ymax=3;

%Fonction utilisée
fct='rosen';    %fonction utilisée (rosenbrock: 'rosen' / peaks: 'peaks')
%pas du tracé
pas=0.8;

%calcul des gradients des fonctions initiales
calc_grad=false;

%%DOE
%type  LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
meta.doe='ffact';

%nb d'échantillons
nb_samples=3;

%%Métamodèle
%type d'interpolation
%PRG: regression polynomiale
%DACE: krigeage (utilisation de la toolbox DACE)
%KRG: krigeage
%CKRG: CoKrigeage (nécessite le calcul des gradients)
%RBF: fonctions à base radiale
%POD: décomposition en valeurs singulières
meta.type='KRG';
%degré de linterpolation/regression (si nécessaire)
meta.deg=2;   %cas KRG/CKRG compris (mais pas DACE)
%paramètre Krigeage
%meta.theta=5;  %variation du param�tre theta
theta=linspace(1,7,50);
meta.regr='regpoly2';  % toolbox DACE
meta.corr='corr_gauss';
%paramètre RBF
meta.para=1.5;
meta.fct='gauss';     %fonction à base radiale: 'gauss', 'multiqua', 'invmultiqua' et 'cauchy'
%paramètre POD
meta.nb_vs=3;        %nombre de valeurs singulières à prendre en compte
%normalisation
meta.norm=true;


%affichage actif ou non
aff.on=false;
aff.d3=true;
aff.d2=true;
aff.contour3=true;
aff.contour2=true;
aff.save=true; %sauvegarde de ts les tracés

%affichage des gradients
aff.grad=false;
cofast.grad=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction métamodèle=======');
disp('=====================================');
disp('=====================================');
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



%Tracé de la fonction de la fonction étudiée et des gradients
x=xmin:pas:xmax;
y=ymin:pas:ymax;
[X,Y]=meshgrid(x,y);

switch fct
    case 'rosen'
        if calc_grad
            [Z.Z,Z.GR1,Z.GR2]=fct_rosenbrock(X,Y);
        else
            Z.Z=fct_rosenbrock(X,Y);
        end
    case 'peaks'
        if calc_grad
           [Z.Z,Z.GR1,Z.GR2]=fct_peaks(X,Y);
        else
            Z.Z=fct_peaks(X,Y);
        end
end

%% Tirages: plan d'expérience
fprintf('\n===== DOE =====\n');

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
        if calc_grad
            [eval,grad(:,1),grad(:,2)]=fct_rosenbrock(tirages(:,1),tirages(:,2));
        else
            [eval]=fct_rosenbrock(tirages(:,1),tirages(:,2));
        end
    case 'peaks'
        if calc_grad
            [eval,grad(:,1),grad(:,2)]=fct_peaks(tirages(:,1),tirages(:,2));
        else
            [eval]=fct_peaks(tirages(:,1),tirages(:,2));
        end
end


%%Affichage courbe initiale
%paramètrage options
aff.on=true;
aff.newfig=true;
aff.contour=true;
aff.rendu=true;
aff.uni=false;
aff.pts=true;
aff.titre='Surface de la fonction objectif';
aff.xlabel='x_{1}';
aff.ylabel='x_{2}';
aff.zlabel='F';
aff.grad=false;
aff.pas=pas;
aff.contour2=false;
aff.contour3=false;

aff.num=aff.num+1;
 affichage(X,Y,Z,tirages,eval,aff);
 aff.newfig=true;
 aff.d3=false;
 aff.d2=true;
 aff.contour2=true;
global resultats
resultats.tirages=tirages;

aff.num=aff.num+1;
affichage(X,Y,Z,tirages,eval,aff);
aff.grad=false;

emse=zeros(size(theta));
err=zeros(size(theta));
eraae=zeros(size(theta));
ermae=zeros(size(theta));
eq1=zeros(size(theta));
eq2=zeros(size(theta));
eq3=zeros(size(theta));
condr=zeros(size(theta));
li=zeros(size(theta));
logli=zeros(size(theta));
sig=zeros(size(theta));
            
for i=1:length(theta)
    meta.theta=theta(i);

%% Génération du métamodèle
fprintf('\n===== METAMODELE de Krigeage =====\n');
disp(' ')

        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krg]=meta_krg(tirages,eval,meta);
        ZZ=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)
             for jj=1:size(X,2)
                 [ZZ(ii,jj),GZ] =eval_krg([X(ii,jj) Y(ii,jj)],tirages,krg);
                 GK1(ii,jj)=GZ(1);
                 GK2(ii,jj)=GZ(2);
             end
         end
         ZK.Z=ZZ;
        
            %%%affichage de la surface obtenue par KRG
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{KRG}';
            aff.grad=false;
            aff.num=aff.num+1;
            aff.d3=true;
            affichage(X,Y,ZK,tirages,eval,aff);

           
            
            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=false;
            aff.grad=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            aff.save=false;
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.save=true;
            aff.color='red';
            aff.num=aff.num+1;
            affichage(X,Y,ZK,tirages,eval,aff);
            
            
            %Vraisemblance
            li(i)=krg.li;
            logli(i)=krg.lilog;
            
            
            condr(i)=krg.cond;
            sig(i)=krg.sig;
            emse(i)=mse_p(Z.Z,ZK.Z);
            err(i)=r_square(Z.Z,ZK.Z);
            eraae(i)=raae(Z.Z,ZK.Z);
            ermae(i)=rmae(Z.Z,ZK.Z);
            [eq1(i),eq2(i),eq3(i)]=qual(Z.Z,ZK.Z);
            fprintf('\nMSE= %6.4d\n',emse(i));
            fprintf('R2= %6.4d\n',err(i));
            fprintf('RAAE= %6.4d\n',eraae(i));
            fprintf('RMAE= %6.4d\n',ermae(i));
            fprintf('Q1= %6.4d,  Q2= %6.4d,  Q3= %6.4d\n\n',eq1(i),eq2(i),eq3(i));
            fprintf('Likelihood= %6.4d, Log-Likelihood= %6.4d \n\n',li(i),logli(i));

        disp('=====================================');
        disp('=====================================');

   close all
%    if i==2
%      break
%     end
end

%affichage des resultats
figure;
subplot(3,4,1);
plot(theta,emse);
xlabel('\theta');
ylabel('MSE')
subplot(3,4,2);
plot(theta,eraae);
xlabel('\theta');
ylabel('RAAE')
subplot(3,4,3);
plot(theta,ermae);
xlabel('\theta');
ylabel('RMAE')
subplot(3,4,4);
plot(theta,err);
xlabel('\theta');
ylabel('R^2')
subplot(3,4,5);
plot(theta,eq1);
xlabel('\theta');
ylabel('Q1')
subplot(3,4,6);
plot(theta,eq2);
xlabel('\theta');
ylabel('Q2')
subplot(3,4,7);
plot(theta,eq3);
xlabel('\theta');
ylabel('Q3')
subplot(3,4,8);
plot(theta,li);
xlabel('\theta');
ylabel('Likelihood')
subplot(3,4,9);
plot(theta,logli);
xlabel('\theta');
ylabel('Log-Likelihood')
subplot(3,4,10);
plot(theta,sig);
xlabel('\theta');
ylabel('Ecart type')
subplot(3,4,11:12);
plot(theta,condr);
xlabel('\theta');
title('Conditionnement matrice de corrélation')
saveas(gcf,[aff.doss '/bilan.eps'],'eps')
saveas(gcf,[aff.doss '/bilan.fig'],'fig')


%sauvegarde workspace
nomfich=[aff.doss '/para_KG.mat'];
save(nomfich)
%diary([aff.doss '/log.txt'])