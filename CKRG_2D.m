%%Fichier d'étude du CoKrigeage sur fonction 2D
%%L. LAURENT -- 19/05/2010 -- luc.laurent@ens-cachan.fr
clf;
%clc;
close all; 

clear all;
addpath('doe/lhs');addpath('meta/dace');addpath('meta');addpath('doe');addpath('fct');
addpath('crit');global cofast;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Définition de l'espace de conception
val=4;
xmin=-val;
xmax=val;
ymin=-val;
ymax=val;


%fonction utilisée
%fct=@(x) 5;
%fctd=@(x) 0;
fctt='fct_peaks';
%pas du tracé
nb=50;
pas=2*val/nb;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Type de tirage
meta.doe='ffact';

%nombre d'échantillons
nb_samples=3;
meta.ajout=false;
meta.dist=0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Type de métamodèle

%paramètre
meta.deg=0;
meta.theta=1;
meta.corr='corr_gauss';
meta.corrd='corrgauss';
meta.regr='regpoly0';
meta.norm=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation de la fonction étudiée et des gradients
x=linspace(xmin,xmax,nb);
y=linspace(ymin,ymax,nb);
[X,Y]=meshgrid(x,y);
[Z.Z,Z.gr1,Z.gr2]=feval(fctt,X,Y);
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
        tirages=factorial_design(nb_samples,nb_samples,xmin,xmax,ymin,ymax);
    case 'sfill'
        xxx=linspace(xmin,xmax,nb_samples);
        tirages=xxx';
    case 'LHS'
        Xmin=[xmin,ymin];
        Xmax=[xmax,ymax];
        tirages=lhsu(Xmin,Xmax,nb_samples);
    otherwise
        error('le type de tirage nest pas défini');
end



%évaluations aux points
grad=zeros(size(tirages));
[eval,grad(:,1),grad(:,2)]=feval(fctt,tirages(:,1),tirages(:,2));

%tracé courbes initiales
figure;
        
surf(X,Y,Z.Z,'LineWidth',1);
hlight=light;               % activ. éclairage
        lighting('gouraud')         % type de rendu
        lightangle(hlight,48,70)    % dir. éclairage
title('fonction de référence');
hold on;

plot3(tirages(:,1),tirages(:,2),eval,'.','Color','red','LineWidth',3);
%hold on
%plot(tirages,grad,'.','Color','g','LineWidth',3);
%% Génération du métamodèle
disp('===== METAMODELE =====');
disp(' ')

% switch meta.type
%     
%     case 'CKRG' 
         disp('>>> Interpolation par CoKrigeage');
        disp(' ')
         [ckrg]=meta_ckrg(tirages,eval,grad,meta);
         ZZ.CKRG=zeros(size(X));
         GCKRG1=zeros(size(X));
         GCKRG2=zeros(size(X));
          for ii=1:size(X,1)*size(X,2)
              [ZZ.CKRG(ii),GZ] =eval_ckrg([X(ii) Y(ii)],tirages,ckrg);
                  GCKRG1(ii)=GZ(1);
                  GCKRG2(ii)=GZ(2);
          end

%       
          
          %affichage des gradients
          aff.save=false;
          aff.tikz=false;
          aff.pas=pas;
          aff.on=true;
          aff.newfig=true;
          aff.d2=true;
          aff.d3=false;
          aff.titre='CKRG';
          aff.xlabel=' ';
          aff.ylabel=' ';
          cofast.grad=true;
          aff.contour2=true;
          aff.grad=true;
          out.Z=ZZ.CKRG;
          out.GR1=GCKRG1;
          out.GR2=GCKRG2;
          aff.pts=true;
          aff.rendu=false;
          aff.scale=true;
          global resultats
          resultats.tirages=tirages;
          resultats.grad.gradients=grad;
          affichage(X,Y,out,tirages,eval,aff);
          aff.contour2=false;
          aff.d2=false;
          aff.d3=true;
          aff.contour3=true;
          aff.uni=false;
          aff.zlabel=' ';
         aff.grad=false;
          affichage(X,Y,out,tirages,eval,aff);
          


disp('CKRG');
fprintf('MSE=%g\n',mse_p(Z.Z,ZZ.CKRG));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.CKRG));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.CKRG));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.CKRG));
