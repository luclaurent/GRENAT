%%%Etude de l'influence du parametre de la fonction de correlation
%%%gaussienne sur la qualite du metamodele de Krigeage construit

%%fonction ï¿½tudiï¿½e: fonction cosinus
%% 21/10/2010


clf;clc;close all; clear all;
addpath('doe/LHS');addpath('meta/dace');addpath('doe');addpath('fct');addpath('meta');
addpath('crit');global cofast;
addpath('matlab2tikz/')


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
xmax=15;

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
meta.theta=1;
meta.regr='regpoly0';
meta.corr='corr_gauss';
meta.corrd='corrgauss';
%normalisation
meta.norm=true;
meta.recond=false;
meta.cv=true;

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
aff.ic='68'; %('0','68','95','99')

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
        var=zeros(size(X));
        GK1=zeros(size(X));
         for ii=1:length(X)
                 [ZZ(ii),GZ,var(ii)] =eval_krg(X(ii),tirages,krg);
                 GK1(ii)=GZ;
                
         end
         ZK.Z=ZZ;
         %%%gï¿½nï¿½ration des diffï¿½rents intervalles de confiance
        
         [ic68,ic95,ic99]=const_ic(ZK.Z,sqrt(var));
         %%%affichage de la surface obtenue par KRG
            figure;
            hold on;
            %IC99
            switch aff.ic
                case '99'
                    h99s=area(X,ic99.sup,min(min(ic99.sup,ic99.inf)));
                    h99i=area(X,ic99.inf,min(min(ic99.sup,ic99.inf)));
                    set(h99s(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
                    set(h99i(1),'FaceColor',[1 1 1],'EdgeColor','none')
                    ic='IC99';
                case '95'
                    disp('95')
                    %IC95
                    h95s=area(X,ic95.sup,min(min(ic95.sup,ic95.inf)));
                    h95i=area(X,ic95.inf,min(min(ic95.sup,ic95.inf)));
                    set(h95s(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
                    set(h95i(1),'FaceColor',[1 1 1],'EdgeColor','none')
                    ic='IC95';
                case '68'
                    %IC68
                    h68s=area(X,ic68.sup,min(min(ic68.sup,ic68.inf)));
                    h68i=area(X,ic68.inf,min(min(ic68.sup,ic68.inf)));
                    set(h68s(1),'Facecolor',[0.8 0.8 0.8],'EdgeColor','none')
                    set(h68i(1),'FaceColor',[1 1 1],'EdgeColor','none')
                    ic='IC68';
            end
            
            
            %fonction de rï¿½fï¿½rence
            plot(X,Z.Z,'Color','blue','LineWidth',1.5);
            
            %%%%%%%%%%
            plot(tirages,eval,'rs','Color','red','MarkerSize',10);
            plot(X,ZK.Z,'Color','green','LineWidth',1.5);
            plot(X,GK1,'Color','red');
            plot(X,var,'Color','blue');
            if str2num(aff.ic)~=0
                legend(ic,' ','fct ref','Evaluations','Krigeage','Derivee KRG','MSE');
            else
                legend('fct_ref','Evaluations','Krigeage','Derivee KRG','MSE');
            end
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
            if meta.cv
                fprintf('\n>>>Validation croisée<<<\n');
                fprintf('Biais moyen=%g\n',krg.cv.bm);
                fprintf('MSE=%g\n',krg.cv.msep);
                fprintf('Critere adequation=%g\n',krg.cv.adequ)
                fprintf('PRESS=%g\n',krg.cv.press);
            end
            
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