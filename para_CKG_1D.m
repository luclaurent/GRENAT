%%%Etude de l'influence du parametre de la fonction de correlation
%%%gaussienne sur la qualite du metamodele de Krigeage construit

%%fonction étudiée: fonction cosinus
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
aff.num=0; %iterateur numeros figures
aff.doss=[num2str(day(1),'%4.0f') '-' num2str(day(2),'%02.0f') '-' num2str(day(3),'%02.0f')...
    '_' num2str(day(4),'%02.0f') '-' num2str(day(5),'%02.0f') '-' num2str(day(6),'%02.0f') '_1D']; %dossier de travail (pour sauvegarde figure)
unix(['mkdir ' aff.doss]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Definition de l'espace de conception
xmin=0;
xmax=15;

%pas du trace
pas=0.05;


%%DOE
%type  LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
meta.doe='sfill';

%nb d'echantillons
nb_samples=5;

%%Metamodele
meta.type='CKRG';
%degre de linterpolation/regression (si necessaire)
meta.deg=0;   %cas KRG/CKRG compris (mais pas DACE)
%parametre Krigeage
%meta.theta=5;  %variation du parametre theta
theta=linspace(0.11,100,20);
meta.regr='regpoly0';
meta.corr='corr_gauss';
%normalisation
meta.norm=true;


%affichage actif ou non
aff.on=false;
aff.d3=false;
aff.d2=true;
aff.contour3=false;
aff.contour2=true;
aff.save=true; %sauvegarde de ts les traces

%affichage des gradients
aff.grad=false;
cofast.grad=false;

%affichage de l'intervalle de confiance
aff.ic='68'; %('68','95','99')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%evaluations aux points
eval=fct(tirages);
grad=fctd(tirages);


%Trace de la fonction de la fonction etudiee et des gradients
X=xmin:pas:xmax;

Z.Z=fct(X);
Z.grad=fctd(X);

%trace courbes initiales
figure;
plot(X,Z.Z,'LineWidth',2);
title('fonction de reference');
hold on;
plot(tirages,eval,'rs','Color','red','MarkerSize',10);

legend('fct ref','Evaluations');
hold off

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

aff.on='true';
            
for i=1:length(theta)
    meta.theta=theta(i);

%% Generation du metamodele
fprintf('\n===== METAMODELE de CoKrigeage =====\n');
disp(' ')

        disp('>>> Interpolation par CoKrigeage');
        disp(' ')
        [krg]=meta_ckrg(tirages,eval,grad,meta);
        ZZ=zeros(size(X));
        GK1=zeros(size(X));
        mse=GK1;
         for ii=1:length(X)
                 [ZZ(ii),GZ,mse(ii)] =eval_ckrg(X(ii),tirages,krg);
                 GK1(ii)=GZ;
                
         end
         ZK.Z=ZZ;
         %%%génération des différents intervalles de confiance
         %a 68%
         ic68.sup=ZZ+mse;
         ic68.inf=ZZ-mse;
         %a 95%
         ic95.sup=ZZ+2*mse;
         ic95.inf=ZZ-2*mse;
         %a 99,7%
         ic99.sup=ZZ+3*mse;
         ic99.inf=ZZ-3*mse;
        
            %%%affichage de la surface obtenue par KRG
            figure;
            hold on;
            %IC99
            switch aff.ic
                case '99'
                    h99s=area(X,ic99.sup,min(ic99.inf));
                    h99i=area(X,ic99.inf,min(ic99.inf));
                    set(h99s(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
                    set(h99i(1),'FaceColor',[1 1 1],'EdgeColor','none')
                    ic='IC99';
                case '95'
                    disp('95')
                    %IC95
                    h95s=area(X,ic95.sup,min(ic95.inf));
                    h95i=area(X,ic95.inf,min(ic95.inf));
                    set(h95s(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
                    set(h95i(1),'FaceColor',[1 1 1],'EdgeColor','none')
                    ic='IC95';
                case '68'
                    %IC68
                    h68s=area(X,ic68.sup,min(ic68.inf));
                    h68i=area(X,ic68.inf,min(ic68.inf));
                    set(h68s(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
                    set(h68i(1),'FaceColor',[1 1 1],'EdgeColor','none')
                    ic='IC68';
            end
            plot(X,Z.Z,'LineWidth',2);
            title('fonction de reference');
            hold on;
            plot(tirages,eval,'rs','Color','red','MarkerSize',10);
            plot(X,ZK.Z,'Color','green');
            plot(X,GK1,'Color','yellow');
            legend(ic,' ','fct ref','Evaluations','Krigeage','Derivee KRG');
            hold off
            aff.num=aff.num+1;
            set(gcf,'Renderer','painters')      %pour sauvegarde image en -nodisplay
            nomfig=[aff.doss '/fig_' num2str(aff.num,'%04.0f') '.eps']; 
            nomfigm=[aff.doss '/fig_' num2str(aff.num,'%04.0f') '.fig'];
            fprintf('>>Sauvegarde figure: \n fichier %s\n',nomfig)
            saveas(gcf, nomfig,'psc2');
            saveas(gcf, nomfigm,'fig');
            
            
            %Vraisemblance
            li(i)=krg.li;
            logli(i)=krg.lilog;
            
            
            condr(i)=krg.cond;
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

subplot(3,4,10:12);
plot(theta,condr);
xlabel('\theta');
title('Conditionnement matrice de correlation')
saveas(gcf,[aff.doss '/bilan.eps'],'eps')
saveas(gcf,[aff.doss '/bilan.fig'],'fig')


%sauvegarde workspace
nomfich=[aff.doss '/para_KG.mat'];
save(nomfich)
%diary([aff.doss '/log.txt'])