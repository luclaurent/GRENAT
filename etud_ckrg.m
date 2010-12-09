%%Fichier d'etude du CoKrigeage sur fonction 1D
%%L. LAURENT -- 19/05/2010 -- luc.laurent@ens-cachan.fr
clf;
%clc;
close all; 
clear all;
addpath('doe/lhs');addpath('dace');addpath('doe');addpath('fct');
addpath('crit');global cofast;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Definition de l'espace de conception
xmin=0;
xmax=15;



%fonction utilisee
%fct=@(x) 5;
%fctd=@(x) 0;

%pas du trace
pas=0.05;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Type de tirage
meta.doe='sfill';

%nombre d'echantillons
nb_samples=4;
%ajout de point
meta.ajout=false;
meta.dist=0.01;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Type de metamodele
meta.type=['KRG' 'DACE'];
%parametre
meta.deg=0;
meta.theta=20;
meta.corr='corr_gauss';
meta.corrd='corrgauss';
meta.regr='regpoly0';
meta.norm=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation de la fonction etudiee et des gradients
x=xmin:pas:xmax;X=x';

Z.Z=fct(X);
Z.grad=fctd(X);

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
        tirages=factorial_design(nb_samples,xmin,xmax);
    case 'sfill'
        xxx=linspace(xmin,xmax,nb_samples);
        tirages=xxx';
    case 'LHS'
        tirages=lhsu(xmin,xmax,nb_samples);
    otherwise
        error('le type de tirage nest pas defini');
end

%ajout de points à proximites des points existants
if meta.ajout
    %calcul de l'ecartement autour du point initial
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
        
    %calcul de l'ecartement aux points
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

%evaluations aux points
eval=fct(tirages);
if meta.ajout
    evalo=fct(tirageso);
end
grad=fctd(tirages);

%trace courbes initiales
figure;
plot(X,Z.Z,'LineWidth',2);
title('fonction de reference');
hold on;
plot(tirages,eval,'rs','Color','red','MarkerSize',10);
hold on
plot(tirages,grad,'.','Color','g','MarkerSize',50);

legend('fct ref','Evaluations','Gradients');
hold off


%% Generation du metamodele
disp('===== METAMODELE =====');
disp(' ')

% switch meta.type
%     

%       case 'KRG' 
        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krg]=meta_krg(tirages,eval,meta);
        ZZ.KRG=zeros(size(X));
        ZZ.GKRG=zeros(size(X));
        
         for ii=1:size(X,1)            
                 [ZZ.KRG(ii),ZZ.GKRG(ii)] =eval_krg(X(ii),tirages,krg);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);             
         end
         if meta.ajout
        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krgo]=meta_krg(tirageso,evalo,meta);
        ZZ.KRGo=zeros(size(X));
        ZZ.GKRGo=zeros(size(X));
         for ii=1:size(X,1)            
                 [ZZ.KRGo(ii),ZZ.GKRGo(ii)] =eval_krg(X(ii),tirageso,krgo);
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
%         for i=[0.5 1 2 5 10 20 200]
%             meta.theta=i;
        [ckrg]=meta_ckrg(tirages,eval,grad,meta);
        ZZ.CKRG=zeros(size(X));
        ZZ.GCKRG=zeros(size(X));
        
         for ii=1:size(X,1)
             [ZZ.CKRG(ii),ZZ.GCKRG(ii)] =eval_ckrg(X(ii),tirages,ckrg);
                
             
         end
         
         
        %end
       % matlab2tikz('ckrg_dtheta.tex')
         
         meta.norm=false;
         disp('>>> Interpolation par Krigeage (sans normalisation)');
        disp(' ')
        [krgs]=meta_krg(tirages,eval,meta);
        ZZ.KRGs=zeros(size(X));
        ZZ.GKRGs=zeros(size(X));
        
         for ii=1:size(X,1)            
                 [ZZ.KRGs(ii),ZZ.GKRGs(ii)] =eval_krg(X(ii),tirages,krgs);
                 %GK1(ii,jj)=GZ(1);
                 %GK2(ii,jj)=GZ(2);             
         end
         
         
%end
       %trace de la courbe d'interpolation par Krigeage
       
       figure;
       hold on
         plot(X,Z.Z,'Color','k','LineWidth',2); 
         plot(tirages,eval,'rs','Color','red','MarkerSize',10);
        plot(tirages,grad,'.','Color','g','MarkerSize',50);
         plot(X,ZZ.KRG,'Color','y','LineWidth',2); 
         
         if meta.ajout
         plot(X,ZZ.KRGo,'--','Color','r','LineWidth',2);
         end
         %plot(X,ZZ.KRGs,'--','Color','y','LineWidth',2); 
         %plot(X,ZZ.DACE,'Color','g','LineWidth',2);
         plot(X,ZZ.CKRG,'Color','r','LineWidth',2);
          plot(X,ZZ.GCKRG,'--','Color','r','LineWidth',2);
%          plot(X,ZZ.GKRG,'--','Color','k','LineWidth',2); 
%          plot(X,ZZ.GKRGs,'--','Color','g','LineWidth',2); 
            %axis([xmin xmax min(min(Z.Z),min(Z.grad))-1 max(max(Z.Z),max(Z.grad))+1])
            legend('fonction de reference','eval','deriv','KRG','CKRG','deriv CKRG');
%             legend('fonction de reference','eval','deriv','KRG',...
%                 'KRGs','DACE','CKRG',...
%                 'deriv CKRG','deriv KRG','deriv CKRGs');
%             if meta.ajout
%             legend('fonction de reference','KRG',...
%                 'KRGs','DACE','CKRG',...
%                 'deriv CKRG','deriv KRG','deriv CKRGs');
%             else
%                 legend('fonction de reference','evaluation',...
%                     'gradient','KRG','KRG sans normalisation','DACE',...
%                     'CKRG','Gradients CKRG','Gradients KRG','Gradients KRG sans norm');
%             end
        hold off
%trace de la difference
% figure;
% subplot(3,2,1);
% diff=abs(ZZ.KRG-ZZ.DACE);
% plot(X,diff,'Color','k','LineWidth',2);  
% title('difference KRG-DACE');
% subplot(3,2,2);
% diff=abs(ZZ.CKRG-ZZ.DACE);
% plot(X,diff,'Color','k','LineWidth',2);  
% title('difference CKRG-DACE');
% subplot(3,2,3);
% diff=abs(Z.Z-ZZ.DACE);
% plot(X,diff,'Color','k','LineWidth',2);  
% title('difference reference-DACE');
% subplot(3,2,4);
% diff=abs(Z.Z-ZZ.KRG);
% plot(X,diff,'Color','k','LineWidth',2);  
% title('difference reference-KRG');
% subplot(3,2,5);
% diff=abs(Z.Z-ZZ.CKRG);
% plot(X,diff,'Color','k','LineWidth',2);  
% title('difference reference-CKRG');
% if meta.ajout
% subplot(3,2,6);
% diff=abs(Z.Z-ZZ.KRGo);
% plot(X,diff,'Color','k','LineWidth',2);  
% title('difference reference-KRG sans ajout de point');
% end
            
%calcul des erreurs
disp('DACE');
fprintf('MSE=%g\n',mse_p(Z.Z,ZZ.DACE));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.DACE));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.DACE));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.DACE));
disp(' ');
disp('KRG');
fprintf('MSE=%g\n',mse_p(Z.Z,ZZ.KRG));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRG));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRG));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRG));
if meta.ajout
disp(' ');
disp('KRG sans ajout de point');
fprintf('MSE=%g\n',mse_p(Z.Z,ZZ.KRGo));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRGo));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRGo));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRGo));
end
disp(' ');
disp('KRGs');
fprintf('MSE=%g\n',mse_p(Z.Z,ZZ.KRGs));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.KRGs));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.KRGs));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.KRGs));
disp(' ');
disp('CKRG');
fprintf('MSE=%g\n',mse_p(Z.Z,ZZ.CKRG));
fprintf('R²=%g\n',r_square(Z.Z,ZZ.CKRG));
fprintf('RAAE=%g\n',raae(Z.Z,ZZ.CKRG));
fprintf('RMAE=%g\n',rmae(Z.Z,ZZ.CKRG));