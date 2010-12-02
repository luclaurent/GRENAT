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
    '_' num2str(day(4),'%02.0f') '-' num2str(day(5),'%02.0f') '-' num2str(day(6),'%02.0f') '_KG_1D']; %dossier de travail (pour sauvegarde figure)
unix(['mkdir ' aff.doss]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Definition de l'espace de conception
xmin=0;
xmax=10;

%pas du trace
pas=0.01;


%%DOE
%type  LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
meta.doe='sfill';

%nb d'echantillons
nb_samples=4;

%%Metamodele
meta.type='KRG';
%degre de linterpolation/regression (si necessaire)
meta.deg=0;   %cas KRG/CKRG compris (mais pas DACE)
%parametre Krigeage
%meta.theta=5;  %variation du parametre theta
meta.theta=0.01;
meta.regr='regpoly0';
meta.corr='corr_gauss';
meta.corrd='corrgauss';
%normalisation
meta.norm=false;


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



%Trace de la fonction de la fonction etudiee et des gradients
X=xmin:pas:xmax;

Z.Z=fct(X);
Z.grad=fctd(X);




aff.on='true';
            


%% Generation du metamodele
fprintf('\n===== METAMODELE de Krigeage =====\n');
disp(' ')
switch meta.type
    case 'KRG'
        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krg]=meta_krg(tirages,eval,meta);
        ZZ=zeros(size(X));
        mse=zeros(size(X));
        GK1=zeros(size(X));
         for ii=1:length(X)
                 [ZZ(ii),GZ,mse(ii)] =eval_krg(X(ii),tirages,krg);
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
            %h99s=area(X,ic99.sup);
            %h99i=area(X,ic99.inf);
            %set(h99s(1),'Facecolor',[1 0.8 0.8],'EdgeColor','none')
            %set(h99i(1),'FaceColor',[1 1 1],'EdgeColor','none')
            %IC95
            h95s=area(X,ic95.sup,min(ic95.inf));
            h95i=area(X,ic95.inf,min(ic95.inf));
            set(h95s(1),'Facecolor',[0.8 1 0.8],'EdgeColor','none')
            set(h95i(1),'FaceColor',[1 1 1],'EdgeColor','none')
            legend(h95i,'hide')
            %fonction de référence
            plot(X,Z.Z,'LineWidth',2);
            %IC68
            %h68s=area(X,ic68.sup);
            %h68i=area(X,ic68.inf);
            %set(h68s(1),'Facecolor',[0.8 0.8 1],'EdgeColor','none')
            %set(h68i(1),'FaceColor',[1 1 1],'EdgeColor','none')
            
            %%%%%%%%%%
            plot(tirages,eval,'rs','Color','red','MarkerSize',10);
            plot(X,ZK.Z,'Color','green','LineWidth',1.5);
            plot(X,GK1,'Color','red');
            plot(X,mse,'Color','blue');
            legend('IC95',' ','Evaluations','Krigeage','Derivee KRG','MSE');
            hold off
            aff.num=aff.num+1;
            set(gcf,'Renderer','painters')      %pour sauvegarde image en -nodisplay
            nomfig=[aff.doss '/fig_' num2str(aff.num,'%04.0f') '.eps']; 
            nomfigm=[aff.doss '/fig_' num2str(aff.num,'%04.0f') '.fig'];
            fprintf('>>Sauvegarde figure: \n fichier %s\n',nomfig)
            saveas(gcf, nomfig,'psc2');
            saveas(gcf, nomfigm,'fig');
            
            
            %Vraisemblance
            li=krg.li;
            logli=krg.lilog;
            
            
            condr=krg.cond;
            emse=mse_p(Z.Z,ZK.Z);
            err=r_square(Z.Z,ZK.Z);
            eraae=raae(Z.Z,ZK.Z);
            ermae=rmae(Z.Z,ZK.Z);
            [eq1,eq2,eq3]=qual(Z.Z,ZK.Z);
            fprintf('\nMSE= %6.4d\n',emse);
            fprintf('R2= %6.4d\n',err);
            fprintf('RAAE= %6.4d\n',eraae);
            fprintf('RMAE= %6.4d\n',ermae);
            fprintf('Q1= %6.4d,  Q2= %6.4d,  Q3= %6.4d\n\n',eq1,eq2,eq3);
            fprintf('Likelihood= %6.4d, Log-Likelihood= %6.4d \n\n',li,logli);
     
    case 'DACE'
         
         disp('>>> Interpolation par Krigeage (Toolbox DACE)');
        disp(' ')
        [model,perf]=dacefit(tirages,eval,meta.regr,meta.corrd,meta.theta);
        ZZ=zeros(size(X));
        DZ=ZZ;
        MSE=ZZ;
        for ii=1:size(X,2)
           
                [ZZ(ii),DZ(ii),MSE(ii)]=predictor(X(ii),model);
                
        end
        
        figure;
        plot(X,Z.Z,'LineWidth',2);
            title('fonction de reference');
            hold on;
            plot(tirages,eval,'rs','Color','red','MarkerSize',10);
            plot(X,ZZ,'Color','green');
            plot(X,DZ,'Color','yellow');
            plot(X,MSE,'Color','blue');
            legend('fct ref','Evaluations','Krigeage','Derivee KRG','MSE');
            hold off
        
            
            
end

        disp('=====================================');
        disp('=====================================');




%sauvegarde workspace
nomfich=[aff.doss '/para_KG.mat'];
save(nomfich)
%diary([aff.doss '/log.txt'])