%%Fichier d'étude du CoKrigeage sur fonction 1D
%%L. LAURENT -- 19/05/2010 -- luc.laurent@ens-cachan.fr
clf;
clc;
close all; 
hold off
clear all;
addpath('doe/lhs');addpath('dace');addpath('doe');addpath('fct');
addpath('crit');global cofast;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Définition de l'espace de conception
xmin=0;
xmax=10;



%fonction utilisée
%fct=@(x) 5;
%fctd=@(x) 0;

%pas du tracé
pas=0.1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Type de tirage
meta.doe='sfill';

%nombre d'échantillons
nb_samples=10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Type de métamodèle
meta.type=['KRG' 'DACE'];;
%paramètre
meta.deg=0;
meta.theta=0.5;
meta.corr='corr_gauss';
meta.corrd='corrgauss';
meta.regr='regpoly0';
meta.norm=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation de la fonction étudiée et des gradients
x=xmin:pas:xmax;X=x';

Z.Z=fct(X);
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
eval=fct(tirages);
grad=fctd(tirages);

%tracé courbes initiales
figure;
plot(X,Z.Z,'LineWidth',2);
title('fonction de référence');
hold on;
plot(tirages,eval,'.','Color','red','LineWidth',3);
hold on
plot(tirages,grad,'.','Color','g','LineWidth',3);
%% Génération du métamodèle
disp('===== METAMODELE =====');
disp(' ')

% switch meta.type
%     
%     case 'CKRG' 
%         disp('>>> Interpolation par CoKrigeage');
%         disp(' ')
%         [krg]=meta_ckrg(tirages,eval,grad,meta);
%         ZZ=zeros(size(X));
%         GK1=zeros(size(X));
%         GK2=zeros(size(X));
%          for ii=1:size(X,1)
%              [ZZ(ii)] =eval_ckrg(X(ii),tirages,krg);
%                  %GK1(ii,jj)=GZ(1);
%                  %GK2(ii,jj)=GZ(2);
%              
%          end
%       case 'KRG' 
        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krg]=meta_krg(tirages,eval,meta);
        ZZ.KRG=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)            
                 [ZZ.KRG(ii)] =eval_krg(X(ii),tirages,krg);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);             
         end
        
         
 %     case 'DACE' %utilisation de la Toolbox DACE
        disp('>>> Interpolation par Krigeage (Toolbox DACE)');
        disp(' ')
        [model,perf]=dacefit(tirages,eval,meta.regr,meta.corrd,meta.theta);
        ZZ.DACE=zeros(size(X));
        for ii=1:size(X,1)
           
                ZZ.DACE(ii)=predictor(X(ii),model);
            
        end
         
         
%end
       %tracé de la courbe d'interpolation par Krigeage
       hold on
         plot(X,ZZ.KRG,'Color','k','LineWidth',2); 
         plot(X,ZZ.DACE,'Color','g','LineWidth',2);
            axis([xmin xmax -1 max(Z.Z)+1])
            legend('fonction de référence','evaluation','gradient','KRG,','DACE');

%tracé de la différence
figure;
diff=abs(ZZ.KRG-ZZ.DACE);
plot(X,diff,'Color','k','LineWidth',2);  
            
%calcul des erreurs
disp('DACE');
fprintf('MSE=%g\n',mse(Z.Z,ZZ.DACE));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.DACE));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.DACE));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.DACE));
disp(' ');
disp('KRG');
fprintf('MSE=%g\n',mse(Z.Z,ZZ.KRG));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRG));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRG));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRG));