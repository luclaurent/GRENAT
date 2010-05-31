%%Fichier d'étude du CoKrigeage sur fonction 1D
%%L. LAURENT -- 19/05/2010 -- luc.laurent@ens-cachan.fr
clf;
%clc;
close all; 
clear all;
addpath('doe/lhs');addpath('dace');addpath('doe');addpath('fct');
addpath('crit');global cofast;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Définition de l'espace de conception
xmin=0;
xmax=15;



%fonction utilisée
%fct=@(x) 5;
%fctd=@(x) 0;

%pas du tracé
pas=0.05;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Type de tirage
meta.doe='sfill';

%nombre d'échantillons
nb_samples=5;
%ajout de point
meta.ajout=false;
meta.dist=0.01;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Type de métamodèle
meta.type=['KRG' 'DACE'];
%paramètre
meta.deg=0;
meta.theta=0.1;
meta.corr='corr_gauss';
meta.corrd='corrgauss';
meta.regr='regpoly0';
meta.norm=true;

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

%ajout de points à proximités des points existants
if meta.ajout
    %calcul de l'écartement autour du point initial
    dist=meta.dist*abs(xmax-xmin);
    %ajout de deux points autour de chaque tirages
    j=find(tirages==xmin);
    k=find(tirages==xmax);
    if isempty(j)&isempty(k)
        tmp=zeros(size(tirages,1)+2*size(tirages,1),1);
    elseif (~isempty(j)&isempty(k))|(~isempty(k)&isempty(j))
        tmp=zeros(size(tirages,1)+2*size(tirages,1)-1,1);
    elseif ~isempty(j)&~isempty(k)
        tmp=zeros(size(tirages,1)+2*size(tirages,1)-2,1);
    end
        
    %calcul de l'écartement aux points
    %on parcours les tirages
    kk=1;
    for ii=1:size(tirages,1)
        tt=tirages(ii);
        if tt==xmin
            tmp(kk)=tt;
            kk=kk+1;
            tmp(kk)=tt+dist;
            kk=kk+1;
        elseif tt==xmax
            tmp(kk)=tt-dist;
            kk=kk+1;
            tmp(kk)=tt;
            kk=kk+1;
        else                
            tmp(kk)=tt-dist;
            kk=kk+1;
            tmp(kk)=tt;
            kk=kk+1;
            tmp(kk)=tt+dist;
            kk=kk+1;
        end
    end
    %sauvegarde des nouveaux tirages
    tirageso=tirages;
    clear tirages;
    tirages=tmp;
 end

%évaluations aux points
eval=fct(tirages);
if meta.ajout
    evalo=fct(tirageso);
end
grad=fctd(tirages);

%tracé courbes initiales
figure;
plot(X,Z.Z,'LineWidth',2);
title('fonction de référence');
hold on;
plot(tirages,eval,'rs','Color','red','MarkerSize',10);
hold on
plot(tirages,grad,'.','Color','g','MarkerSize',50);
%% Génération du métamodèle
disp('===== METAMODELE =====');
disp(' ')

% switch meta.type
%     

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
         if meta.ajout
        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krgo]=meta_krg(tirageso,evalo,meta);
        ZZ.KRGo=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)            
                 [ZZ.KRGo(ii)] =eval_krg(X(ii),tirageso,krgo);
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
           
                ZZ.DACE(ii)=predictor(X(ii),model);
            
        end
        %     case 'CKRG' 
        disp('>>> Interpolation par CoKrigeage');
        disp(' ')
        [ckrg]=meta_ckrg(tirages,eval,grad,meta);
        ZZ.CKRG=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)
             [ZZ.CKRG(ii)] =eval_ckrg(X(ii),tirages,ckrg);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);
             
         end
         meta.norm=false;
         disp('>>> Interpolation par Krigeage (sans normalisation)');
        disp(' ')
        [krgs]=meta_krg(tirages,eval,meta);
        ZZ.KRGs=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)            
                 [ZZ.KRGs(ii)] =eval_krg(X(ii),tirages,krgs);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);             
         end
         
         
%end
       %tracé de la courbe d'interpolation par Krigeage
       hold on
         plot(X,ZZ.KRG,'Color','k','LineWidth',2); 
         if meta.ajout
         plot(X,ZZ.KRGo,'--','Color','r','LineWidth',2);
         end
         plot(X,ZZ.KRGs,'--','Color','k','LineWidth',2); 
         plot(X,ZZ.DACE,'Color','g','LineWidth',2);
         plot(X,ZZ.CKRG,'Color','r','LineWidth',2);
            axis([xmin xmax min(Z.Z)-1 max(Z.Z)+1])
            if meta.ajout
            legend('fonction de référence','evaluation','gradient','KRG','KRG sans ajout de point','KRG sans normalisation','DACE','CKRG');
            else
                legend('fonction de référence','evaluation','gradient','KRG','KRG sans normalisation','DACE','CKRG');
            end
        hold off
%tracé de la différence
figure;
subplot(3,2,1);
diff=abs(ZZ.KRG-ZZ.DACE);
plot(X,diff,'Color','k','LineWidth',2);  
title('différence KRG-DACE');
subplot(3,2,2);
diff=abs(ZZ.CKRG-ZZ.DACE);
plot(X,diff,'Color','k','LineWidth',2);  
title('différence CKRG-DACE');
subplot(3,2,3);
diff=abs(Z.Z-ZZ.DACE);
plot(X,diff,'Color','k','LineWidth',2);  
title('différence reférence-DACE');
subplot(3,2,4);
diff=abs(Z.Z-ZZ.KRG);
plot(X,diff,'Color','k','LineWidth',2);  
title('différence reférence-KRG');
subplot(3,2,5);
diff=abs(Z.Z-ZZ.CKRG);
plot(X,diff,'Color','k','LineWidth',2);  
title('différence reférence-CKRG');
if meta.ajout
subplot(3,2,6);
diff=abs(Z.Z-ZZ.KRGo);
plot(X,diff,'Color','k','LineWidth',2);  
title('différence reférence-KRG sans ajout de point');
end
            
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
if meta.ajout
disp(' ');
disp('KRG sans ajout de point');
fprintf('MSE=%g\n',mse(Z.Z,ZZ.KRGo));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRGo));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRGo));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRGo));
end
disp(' ');
disp('KRGs');
fprintf('MSE=%g\n',mse(Z.Z,ZZ.KRGs));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRGs));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRGs));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRGs));
disp(' ');
disp('CKRG');
fprintf('MSE=%g\n',mse(Z.Z,ZZ.CKRG));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.CKRG));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.CKRG));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.CKRG));