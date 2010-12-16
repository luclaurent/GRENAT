%%Fichier d'etude du CoKrigeage sur fonction 2D
%%L. LAURENT -- 19/05/2010 -- luc.laurent@ens-cachan.fr
clf;
%clc;
close all; 

clear all;
addpath('doe/lhs');addpath('meta/dace');addpath('meta');addpath('doe');addpath('fct');
addpath('crit');global cofast;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Definition de l'espace de conception
val=4;
xmin=-val;
xmax=val;
ymin=-val;
ymax=val;

% %branin
 xmin=-5;
 xmax=10;
ymin=0;
 ymax=15;
%Goldstein
val=2;
xmin=-val;
xmax=val;
ymin=-val;
ymax=val;
%SixHump
xmin=-2;
xmax=2;
ymin=-1;
ymax=1;

%fonction utilisee
%fct=@(x) 5;
%fctd=@(x) 0;
fctt='fct_sixhump';
%pas du trace
nb=50;
pas=2*val/nb;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Type de tirage
meta.doe='ffact';

%nombre d'echantillons
nb_samples=3;
meta.ajout=false;
meta.dist=0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Type de metamodele

%parametre
meta.deg=0;
meta.theta=1;
meta.corr='corr_gauss';
meta.corrd='corrgauss';
meta.regr='regpoly0';
meta.norm=true;
meta.cv=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation de la fonction etudiee et des gradients
x=linspace(xmin,xmax,nb);
y=linspace(ymin,ymax,nb);
[X,Y]=meshgrid(x,y);
[Z.Z,Z.gr1,Z.gr2]=feval(fctt,X,Y);
%grad=feval(fctd,X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction metamodele=======');
disp('=====================================');
disp('=====================================');

%% Tirages: plan d'experience
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
        error('le type de tirage nest pas defini');
end



%evaluations aux points
grad=zeros(size(tirages));
[eval,grad(:,1),grad(:,2)]=feval(fctt,tirages(:,1),tirages(:,2));

%trace courbes initiales
figure;
        
surf(X,Y,Z.Z,'LineWidth',1);
hlight=light;               % activ. eclairage
        lighting('gouraud')         % type de rendu
        lightangle(hlight,48,70)    % dir. eclairage
title('fonction de reference');
hold on;

plot3(tirages(:,1),tirages(:,2),eval,'.','Color','red','LineWidth',3);
%hold on
%plot(tirages,grad,'.','Color','g','LineWidth',3);
%% Generation du metamodele
disp('===== METAMODELE =====');
disp(' ')

% switch meta.type
%     
%     case 'CKRG' 
         disp('>>> Interpolation par Krigeage');
        disp(' ')
         [krg]=meta_krg(tirages,eval,meta);
         ZZ.KRG=zeros(size(X));
         GKRG1=zeros(size(X));
         GKRG2=zeros(size(X));
         var=zeros(size(X));
          for ii=1:size(X,1)*size(X,2)
              [ZZ.KRG(ii),GZ,var(ii)] =eval_krg([X(ii) Y(ii)],tirages,krg);
                  GKRG1(ii)=GZ(1);
                  GKRG2(ii)=GZ(2);
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
          aff.titre='KRG';
          aff.xlabel=' ';
          aff.ylabel=' ';
          cofast.grad=true;
          aff.contour2=true;
          aff.grad=true;
          out.Z=ZZ.KRG;
          out.GR1=GKRG1;
          out.GR2=GKRG2;
          aff.pts=true;
          aff.rendu=false;
          aff.scale=true;
          global resultats
          resultats.tirages=tirages;
          resultats.grad.gradients=grad;
          
          affichage(X,Y,out,tirages,eval,aff);
          aff.d2=false;
          aff.d3=true;
          aff.contour3=false;
          aff.uni=false;
          aff.zlabel='';
          aff.grad=false;
          affichage(X,Y,out,tirages,eval,aff);
          


disp('KRG');
fprintf('MSE=%g\n',mse_p(Z.Z,ZZ.KRG));
fprintf('R2=%g\n',r_square(Z.Z,ZZ.KRG));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRG));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRG));
