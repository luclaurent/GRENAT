%%Fichier d'étude du CoKrigeage sur fonction 1D
%%L. LAURENT -- 19/05/2010 -- luc.laurent@ens-cachan.fr
clf;clc;close all; clear all;
addpath('doe/lhs');addpath('dace');addpath('doe');addpath('fct');
addpath('crit');global cofast;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Définition de l'espce de conception
xmin=0;
xmax=10;

%fonction utilisée
fct='sin';
fctd='cos';
%pas du tracé
pas=0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Type de tirage
meta.doe='sfill';

%nombre d'échantillons
nb_samples=10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Type de métamodèle
meta.type='KRG';
%paramètre
meta.deg=0;
meta.theta=1;
meta.corr='corr_exp';
meta.regr='regpoly0';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation de la fonction étudiée et des gradients
x=xmin:pas:xmax;X=x';

Z.Z=feval(fct,X);
%grad=feval(fctd,X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction métamodèle=======');
disp('=====================================');
disp('=====================================');

%% Tirages: plan d'expérience
disp('===== DOE =====');
switch meta.doe
    case 'ffact'
        tirages=factorial_design(nb_samples,xmin,xmax);
    case 'sfill'
        xxx=linspace(xmin,xmax,nb_samples);
        tirages=xxx';
    case 'LHS'
        tirages=lhsu(xmin,xmax,nb_samples);
    otherwise
        error('le type de tirage nest pas défini');
end

%évaluations aux points
eval=feval(fct,tirages);
grad=feval(fctd,tirages);

%tracé courbes initiales
figure;
plot(X,Z.Z,'LineWidth',2);
title('fonction de référence');
hold on;
plot(tirages,eval,'.','Color','red','LineWidth',2);
hold on
plot(tirages,grad,'.','Color','g','LineWidth',2);
%% Génération du métamodèle
disp('===== METAMODELE =====');
disp(' ')

switch meta.type
    
    case 'CKRG' 
        disp('>>> Interpolation par CoKrigeage');
        disp(' ')
        [krg]=meta_ckrg(tirages,eval,grad,meta);
        ZZ=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)
             [ZZ(ii)] =eval_ckrg(X(ii),tirages,krg);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);
             
         end
      case 'KRG' 
        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krg]=meta_krg(tirages,eval,meta);
        ZZ=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)            
                 [ZZ(ii)] =eval_krg(X(ii),tirages,krg);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);             
         end
        
         
      case 'DACE' %utilisation de la Toolbox DACE
        disp('>>> Interpolation par Krigeage (Toolbox DACE)');
        disp(' ')
        [model,perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.theta);
        ZZ=zeros(size(X));
        for ii=1:size(X,1)
           
                ZZ(ii)=predictor(X(ii),model);
            
        end
         
         
end
       %tracé de la courbe d'interpolation par Krigeage
         plot(X,ZZ,'Color','k','LineWidth',2); 
