%%Fichier d'étude du CoKrigeage sur fonction 2D
%%L. LAURENT -- 19/05/2010 -- luc.laurent@ens-cachan.fr
clf;
%clc;
close all; 

%clear all;
addpath('doe/lhs');addpath('dace');addpath('doe');addpath('fct');
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
fct='fct_peaks';
%pas du tracé
pas=0.1;
nb=50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Type de tirage
meta.doe='ffact';

%nombre d'échantillons
nb_samples=5;
meta.ajout=true;
meta.dist=0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Type de métamodèle
meta.type=['KRG' 'DACE'];
%paramètre
meta.deg=0;
meta.theta=2;
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
Z.Z=feval(fct,X,Y);
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
        tirages=lhsu(xmin,xmax,nb_samples);
    otherwise
        error('le type de tirage nest pas défini');
end

%ajout de points à proximités des points existants
if meta.ajout
    %calcul de l'écartement autour du point initial
    dist=meta.dist*abs(xmax-xmin);
    %ajout de quatre points autour de chaque tirages
%     j=find(tirages==xmin);
%     k=find(tirages==xmax);
%     if isempty(j)&isempty(k)
%         tmp=zeros(size(tirages,1)+4*size(tirages,1),2);
%     elseif (~isempty(j)&isempty(k))|(~isempty(k)&isempty(j))
%         tmp=zeros(size(tirages,1)+4*size(tirages,1)-1,2);
%     elseif ~isempty(j)&~isempty(k)
%         tmp=zeros(size(tirages,1)+4*size(tirages,1)-2,2);
%     end
        tmp=zeros(size(tirages,1)+4*size(tirages,1),2);
    %calcul de l'écartement aux points
    %on parcours les tirages
    kk=1;
    for ii=1:size(tirages,1)
        tt1=tirages(ii,1);
        tt2=tirages(ii,2);
        tmp(kk,1)=tt1-dist;
        tmp(kk,2)=tt2;
        kk=kk+1;
        tmp(kk,1)=tt1;
        tmp(kk,2)=tt2-dist;
        kk=kk+1;
        tmp(kk,1)=tt1+dist;
        tmp(kk,2)=tt2;
        kk=kk+1;
        tmp(kk,1)=tt1;
        tmp(kk,2)=tt2+dist;
        kk=kk+1;
        tmp(kk,1)=tt1;
        tmp(kk,2)=tt2;
        kk=kk+1;
    end
    %sauvegarde des nouveaux tirages
    tirageso=tirages;
    clear tirages;
    tirages=tmp;
    size(tmp)
end

%évaluations aux points
eval=feval(fct,tirages(:,1),tirages(:,2));
evalo=feval(fct,tirageso(:,1),tirageso(:,2));
%grad=fctd(tirages);

%tracé courbes initiales
figure;
surf(X,Y,Z.Z,'LineWidth',2);
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
             for jj=1:size(X,2)
                 [ZZ.KRG(ii,jj)] =eval_krg([X(ii,jj) Y(ii,jj)],tirages,krg);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);
             end 
         end
        disp('>>> Interpolation par Krigeage sans ajout de point');
        disp(' ')
        [krgo]=meta_krg(tirageso,evalo,meta);
        ZZ.KRGo=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1) 
             for jj=1:size(X,2)
                 [ZZ.KRGo(ii,jj)] =eval_krg([X(ii,jj) Y(ii,jj)],tirageso,krgo);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);
             end 
         end
         
 %     case 'DACE' %utilisation de la Toolbox DACE
        disp('>>> Interpolation par Krigeage (Toolbox DACE)');
        disp(' ')
        [model,perf]=dacefit(tirages,eval,meta.regr,meta.corrd,meta.theta);
        ZZ.DACE=zeros(size(X));
        for ii=1:size(X,1)
           for jj=1:size(X,2)
                ZZ.DACE(ii,jj)=predictor([X(ii,jj) Y(ii,jj)],model);
           end
        end
        
        meta.norm=false;
        disp('>>> Interpolation par Krigeage sans normalisation');
        disp(' ')
        [krgs]=meta_krg(tirages,eval,meta);
        ZZ.KRGs=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1) 
             for jj=1:size(X,2)
                 [ZZ.KRGs(ii,jj)] =eval_krg([X(ii,jj) Y(ii,jj)],tirages,krgs);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);
             end 
         end
         
         
%end
       %tracé de la courbe d'interpolation par Krigeage
       figure
       hold on
         surf(X,Y,ZZ.KRG,'FaceColor','blue','EdgeColor','k');
         surf(X,Y,ZZ.KRGo,'FaceColor','yellow','EdgeColor','k');
         surf(X,Y,ZZ.KRGs,'FaceColor','green','EdgeColor','k');
         surf(X,Y,ZZ.DACE,'FaceColor','red','EdgeColor','k');
            %axis([xmin xmax -1 max(Z.Z)+1])
            %legend('fonction de référence','evaluation','gradient','KRG,','DACE');

%tracé de la différence
figure;
diff=abs(ZZ.KRG-ZZ.DACE);
surf(X,Y,diff); 
title('diff KRG DACE');
figure;
diff=abs(Z.Z-ZZ.KRG);
surf(X,Y,diff);
title('diff ref KRG');
figure;
diff=abs(ZZ.KRGo-ZZ.DACE);
surf(X,Y,diff);
title('diff KRGo DACE');
figure;
diff=abs(ZZ.KRGo-ZZ.DACE);
surf(X,Y,diff);
title('diff KRGo DACE');
            
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
disp(' ');
disp('KRGo');
fprintf('MSE=%g\n',mse(Z.Z,ZZ.KRGo));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRGo));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRGo));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRGo));
disp(' ');
disp('KRGs');
fprintf('MSE=%g\n',mse(Z.Z,ZZ.KRGs));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRGs));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRGs));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRGs));
