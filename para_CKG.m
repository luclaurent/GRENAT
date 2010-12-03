%%%Etude de l'influence du parametre de la fonction de correlation
%%%gaussienne sur la qualite du metamodele de coKrigeage
%% 22/10/2010


clf;clc;close all; clear all;
addpath('doe/LHS');addpath('meta/dace');addpath('doe');addpath('fct');addpath('meta');
addpath('crit');global cofast;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
day=clock;
fprintf('Date: %d/%d/%d   Time: %02.0f:%02.0f:%02.0f\n', day(3), day(2), day(1), day(4), day(5), day(6))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aff.scale=true;aff.tikz=false;
aff.num=0; %iterateur numeros figures
aff.doss=[num2str(day(1),'%4.0f') '-' num2str(day(2),'%02.0f') '-' num2str(day(3),'%02.0f')...
    '_' num2str(day(4),'%02.0f') '-' num2str(day(5),'%02.0f') '-' num2str(day(6),'%02.0f')]; %dossier de travail (pour sauvegarde figure)
unix(['mkdir ' aff.doss]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Definition de l'espace de conception
esp.type='auto';   %gestion automatique de l'espace de conception pour fonction etudiee standards
xmin=-2;
xmax=2;
ymin=-1;
ymax=3;

%Fonction utilisee
fct='peaks';    %fonction utilisee (rosenbrock: 'rosen' / peaks: 'peaks')
%pas du trace
pas=0.1;

%calcul des gradients des fonctions initiales
calc_grad=true;

%%DOE
%type  LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
meta.doe='ffact';

%nb d'echantillons
nb_samples=6;

%%Metamodele
%type d'interpolation
%PRG: regression polynomiale
%DACE: krigeage (utilisation de la toolbox DACE)
%KRG: krigeage
%CKRG: CoKrigeage (necessite le calcul des gradients)
%RBF: fonctions à base radiale
%POD: decomposition en valeurs singulieres
meta.type='CKRG';
%degre de linterpolation/regression (si necessaire)
meta.deg=0;   %cas KRG/CKRG compris (mais pas DACE)
%parametre Krigeage
%meta.theta=5;  %variation du parametre theta
theta=linspace(0.4,5,10);
meta.regr='regpoly2';  % toolbox DACE
meta.corr='corr_gauss';
%parametre RBF
meta.para=1.5;
meta.fct='gauss';     %fonction à base radiale: 'gauss', 'multiqua', 'invmultiqua' et 'cauchy'
%parametre POD
meta.nb_vs=3;        %nombre de valeurs singulieres à prendre en compte
%normalisation
meta.norm=true;


%affichage actif ou non
aff.on=false;
aff.d3=true;
aff.d2=true;
aff.contour3=true;
aff.contour2=true;
aff.save=true; %sauvegarde de ts les traces

%affichage des gradients
aff.grad=false;
cofast.grad=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction metamodele=======');
disp('=====================================');
disp('=====================================');
%definition du domaine d'etude
switch esp.type
    case 'auto'
        disp('Definition auto du domaine de conception');
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
        disp('Definition manu du domaine de conception');
end



%Trace de la fonction de la fonction etudiee et des gradients
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

%% Tirages: plan d'experience
sprintf('\n===== DOE =====\n');

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
        error('le type de tirage nest pas defini');
end

%evaluations aux points
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
%parametrage options
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

            
for i=1:length(theta)
    meta.theta=theta(i);

%% Generation du metamodele
sprintf('\n===== METAMODELE de Krigeage =====\n');
disp(' ')

               disp('>>> Interpolation par CoKrigeage');
        disp(' ')
        [krg]=meta_ckrg(tirages,eval,grad,meta);
        ZZ=zeros(size(X));
        GCKRG1=zeros(size(X));
        GCKRG2=zeros(size(X));
         for ii=1:size(X,1)
             for jj=1:size(X,2)
                 [ZZ(ii,jj),GZ] =eval_ckrg([X(ii,jj) Y(ii,jj)],krg);
                 GCKRG1(ii,jj)=GZ(1);
                 GCKRG2(ii,jj)=GZ(2);
             end
         end
         ZK.Z=ZZ;
         ZK.GR1=GCKRG1;
         ZK.GR2=GCKRG2;
        
            %%%affichage de la surface obtenue par KRG
            %parametrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.d3=true;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=true;
            aff.titre=['Surface obtenue par CoKrigeage: theta ',...
                num2str(meta.theta),' degre regression ',meta.deg,' correlation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{KRG}';
            aff.grad=false;
            cofast.grad=false;
            aff.num=aff.num+1;
            affichage(X,Y,ZK,tirages,eval,aff);
            aff.grad=true;
            cofast.grad=false;
            aff.newfig=true;
            aff.contour2=true;
            aff.contour3=false;
            aff.d3=false;
            aff.d2=true;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=true;
            aff.num=aff.num+1;
    affichage(X,Y,ZK,tirages,eval,aff)
%              %%affichage du gradient de la fonction
%             aff.titre=['Gradient de linterpolation par Krigeage'];
%             aff.xlabel='x_{1}';
%             aff.ylabel='x_{2}';
%             aff.zlabel='dF_{KRG}/dx';
%             aff.grad=true;
%             affichage_gr(X,Y,ZK.Z,GK1,GK2,aff);
%             
%              figure;
%             quiver3(X,Y,ZK.Z,GK1,GK2,-ones(size(GK1)),0.5)
%             hold on;
%             surf(X,Y,ZK.Z)
            
            
            %%%affichage de l'ecart entre la fonction objectif et la fonction
            %%%approchee
            %parametrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.d3=true;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=true;
            aff.grad=false;
            aff.titre=['Surface obtenue par CoKrigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' correlation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            aff.num=aff.num+1;
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            aff.num=aff.num+1;
            affichage(X,Y,ZK,tirages,eval,aff);
            
            %Vraisemblance
            li(i)=krg.li;
            logli(i)=krg.lilog;
            
            
            condr(i)=krg.cond;
            emse(i)=mse(Z.Z,ZK.Z);
            err(i)=r_square(Z.Z,ZK.Z);
            eraae(i)=raae(Z.Z,ZK.Z);
            ermae(i)=rmae(Z.Z,ZK.Z);
            [eq1(i),eq2(i),eq3(i)]=qual(Z.Z,ZK.Z);
            sprintf('\nMSE= %6.4d\n',emse(i));
            sprintf('R2= %6.4d\n',err(i));
            sprintf('RAAE= %6.4d\n',eraae(i));
            sprintf('RMAE= %6.4d\n',ermae(i));
            sprintf('Q1= %6.4d,  Q2= %6.4d,  Q3= %6.4d\n\n',eq1(i),eq2(i),eq3(i));

        disp('=====================================');
        disp('=====================================');

   close all
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
%subplot(3,4,10);
%plot(theta,sig);
%xlabel('\theta');
%ylabel('Ecart type')
subplot(3,4,11:12);
plot(theta,condr);
xlabel('\theta');
title('Conditionnement matrice de correlation')
saveas(gcf,[aff.doss '/bilan.eps'],'eps')
saveas(gcf,[aff.doss '/bilan.fig'],'fig')

%sauvegarde workspace
nomfich=[aff.doss '/para_KG.mat'];
save(nomfich)
%diary([aff.doss '/log.txt'])