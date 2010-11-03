%Fichier d'étude et de mise en oeuvre des démarche de la biblio
%L LAURENT   --  31/01/2010   --  luc.laurent@ens-cachan.fr
clf;clc;close all; clear all;
addpath('doe/LHS');addpath('meta/dace');addpath('meta');addpath('doe');addpath('fct');
addpath('crit');global cofast;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aff.save=false;
aff.tikz=false;
aff.scale=false;
%%Définition de l'espace de conception
esp.type='auto';   %gestion automatique de l'espace de conception pour fonction étudiée standards
xmin=-2;
xmax=2;
ymin=-1;
ymax=3;
%Fonction utilisée
fct='peaks';    %fonction utilisée (rosenbrock: 'rosen' / peaks: 'peaks')
%pas du tracé
pas=0.1;

%calcul des gradients des fonctions initiales
calc_grad=true;

%%DOE
%type  LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
meta.doe='LHS';

%nb d'échantillons
nb_samples=80;

%%Métamodèle
%type d'interpolation
%PRG: regression polynomiale
%DACE: krigeage (utilisation de la toolbox DACE)
%KRG: krigeage
%CKRG: CoKrigeage (nécessite le calcul des gradients)
%RBF: fonctions à base radiale
%POD: décomposition en valeurs singulières
meta.type='CKRG';
%degré de linterpolation/regression (si nécessaire)
meta.deg=0;   %cas KRG/CKRG compris (mais pas DACE)
%paramètre Krigeage
meta.theta=5;
meta.regr='regpoly2';  % toolbox DACE
meta.corr='corr_gauss';
%paramètre RBF
meta.para=1.5;
meta.fct='cauchy';     %fonction à base radiale: 'gauss', 'multiqua', 'invmultiqua' et 'cauchy'
%paramètre POD
meta.nb_vs=3;        %nombre de valeurs singulières à prendre en compte
%normalisation
meta.norm=true;


%affichage actif ou non
aff.on=true;
aff.d3=true;
aff.d2=true;
aff.contour3=true;
aff.contour2=true;

%affichage des gradients
aff.grad=true;
cofast.grad=true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=====================================');
disp('=====================================');
disp('=======Construction métamodèle=======');
disp('=====================================');
disp('=====================================');
%définition du domaine d'étude
switch esp.type
    case 'auto'
        disp('Définition auto du domaine de conception');
        switch fct
            case 'rosen'
                xmin=-2;
                xmax=2;
                ymin=-1;
                ymax=3;
            case 'peaks'
                xmin=-3;
                xmax=3;
                ymin=-3;
                ymax=3;
        end
    case 'manu'
        disp('Définition manu du domaine de conception');
end



%Tracé de la fonction de la fonction étudiée et des gradients
x=xmin:pas:xmax;
y=ymin:pas:ymax;
[X,Y]=meshgrid(x,y);

switch fct
    case 'rosen'
        if calc_grad
            [Z.Z,Z.GR1,Z.GR2]=fct_rosenbrock(X,Y);
        else
            Z.Z=fct_rosenbrock(X,Y);
        end
    case 'peaks'
        if calc_grad
           [Z.Z,Z.GR1,Z.GR2]=fct_peaks(X,Y);
        else
            Z.Z=fct_peaks(X,Y);
        end
end




%% Tirages: plan d'expérience
disp('===== DOE =====');

%LHS uniform
Xmin=[xmin,ymin];
Xmax=[xmax,ymax];
switch meta.doe
    case 'ffact'
        tirages=factorial_design(nb_samples,nb_samples,xmin,xmax,ymin,ymax);
    case 'sfill'
        xxx=linspace(xmin,xmax,nb_samples);
        yyy=linspace(ymin,ymax,nb_samples);
        tirages=zeros(size(xxx,2)^2,2);
        for ii=1:size(xxx,2)
            for jj=1:size(xxx,2)
                tirages(size(xxx,2)*(ii-1)+jj,1)=xxx(ii);
                tirages(size(xxx,2)*(ii-1)+jj,2)=yyy(jj);
            end
        end
    case 'LHS'
        tirages=lhsu(Xmin,Xmax,nb_samples);
    otherwise
        error('le type de tirage nest pas défini');
end

%évaluations aux points
switch fct
    case 'rosen'
        if calc_grad
            [eval,grad(:,1),grad(:,2)]=fct_rosenbrock(tirages(:,1),tirages(:,2));
        else
            [eval]=fct_rosenbrock(tirages(:,1),tirages(:,2));
        end
    case 'peaks'
        if calc_grad
            [eval,grad(:,1),grad(:,2)]=fct_peaks(tirages(:,1),tirages(:,2));
        else
            [eval]=fct_peaks(tirages(:,1),tirages(:,2));
        end
end


%%Affichage courbe initiale
%paramètrage options
aff.on=true;
aff.newfig=true;
aff.contour=true;
aff.rendu=true;
aff.uni=false;
aff.pts=true;
aff.titre='Surface de la fonction objectif';
aff.xlabel='x_{1}';
aff.ylabel='x_{2}';
aff.zlabel='F';
aff.grad=true;
aff.pas=pas;
aff.contour2=false;
aff.contour3=false;
affichage(X,Y,Z,tirages,eval,aff);
aff.newfig=true;
aff.d3=false;
aff.d2=true;
aff.contour2=true;
global resultats
resultats.tirages=tirages;
resultats.grad.gradients=grad;
affichage(X,Y,Z,tirages,eval,aff);
aff.grad=true;



%% Génération du métamodèle
disp('===== METAMODELE =====');
disp(' ')

switch meta.type
    case 'PRG'
        for degre=meta.deg
            
            disp('>>> Régression polynomiale');
            disp(' ')
            dd=['-- Degré du polynôme ',num2str(degre)];
            disp(dd)
            [coef,MSE]=meta_prg(tirages,eval,degre);
            ZRG=eval_prg(coef,X,Y,degre);Za.Z=ZRG;
            [GRG1,GRG2]=evald_prg(coef,X,Y,degre);

            %%%affichage de la surface obtenue par PRG
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.titre=['Surface obtenue par régression polynômiale de degré ',num2str(degre)];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{PRG}';
            aff.grad=false;
            affichage(X,Y,Za,tirages,eval,aff);
            
            %%affichage du gradient de la fonction
            aff.titre=['Gradient de linterpolation par fonctions à base radiale'];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='dF_{RBF}/dx';
            aff.grad=true;
            affichage_gr(X,Y,Za.Z,GRG1,GRG2,aff);
            
             figure;
            quiver3(X,Y,Za.Z,GRG1,GRG2,-ones(size(GRG1)),0.5)
            hold on;
            surf(X,Y,Za.Z)
            

            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour3=false;
            aff.contour2=false;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=false;
            aff.titre=['Surface obtenue par régression polynômiale de degré ',num2str(degre)];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            aff.grad=false;
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,Za,tirages,eval,aff);
            emse=['MSE=',num2str(mse(Z.Z,ZRG))];
            err=['R2=',num2str(r_square(Z.Z,ZRG))];
            eraae=['RAAE=',num2str(raae(Z.Z,ZRG))];
            ermae=['RMAE=',num2str(rmae(Z.Z,ZRG))];
            disp(' ')
            disp(emse);
            disp(err)
            disp(eraae)
            disp(ermae)
            disp(' ')
            disp('=====================================');
            disp('=====================================');
        end
        
        disp('=====================================');
        disp('=====================================');
        
   case 'CKRG' 
        disp('>>> Interpolation par CoKrigeage');
        disp(' ')
        [krg]=meta_ckrg(tirages,eval,grad,meta);
        ZZ=zeros(size(X));
        GCKRG1=zeros(size(X));
        GCKRG2=zeros(size(X));
         for ii=1:size(X,1)*size(X,2)
                 [ZZ(ii),GZ] =eval_ckrg([X(ii) Y(ii)],tirages,krg);
                 GCKRG1(ii)=GZ(1);
                 GCKRG2(ii)=GZ(2);
         end
         ZK.Z=ZZ;
         ZK.GR1=GCKRG1;
         ZK.GR2=GCKRG2;
        
            %%%affichage de la surface obtenue par KRG
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.d3=true;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=true;
            aff.titre=['Surface obtenue par CoKrigeage: theta ',...
                num2str(meta.theta),' degré regression ',meta.deg,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{KRG}';
            aff.grad=false;
            cofast.grad=false;
            affichage(X,Y,ZK,tirages,eval,aff);
            aff.grad=true;
            cofast.grad=true;
            aff.newfig=true;
            aff.contour2=true;
            aff.contour3=false;
            aff.d3=false;
            aff.d2=true;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=true;
affichage(X,Y,ZK,tirages,eval,aff)
%              %%affichage du gradient de la fonction
%             aff.titre=['Gradient de linterpolation par Krigeage'];
%             aff.xlabel='x_{1}';
%             aff.ylabel='x_{2}';
%             aff.zlabel='dF_{KRG}/dx';
%             aff.grad=true;
%             affichage_gr(X,Y,ZK.Z,GK1,GK2,aff);
%             
%              figure;
%             quiver3(X,Y,ZK.Z,GK1,GK2,-ones(size(GK1)),0.5)
%             hold on;
%             surf(X,Y,ZK.Z)
            
            
            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.d3=true;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=true;
            aff.grad=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,ZK,tirages,eval,aff);
            emse=['MSE=',num2str(mse(Z.Z,ZK.Z))];
            err=['R2=',num2str(r_square(Z.Z,ZK.Z))];
            eraae=['RAAE=',num2str(raae(Z.Z,ZK.Z))];
            ermae=['RMAE=',num2str(rmae(Z.Z,ZK.Z))];
            disp(' ')
            disp(emse)
            disp(err)
            disp(eraae)
            disp(ermae)
            disp(' ')
        disp('=====================================');
        disp('=====================================');
        
        
        
        
        
        
        
        
        
        
        
    case 'KRG' 
        disp('>>> Interpolation par Krigeage');
        disp(' ')
        [krg]=meta_krg(tirages,eval,meta);
        ZZ=zeros(size(X));
        GK1=zeros(size(X));
        GK2=zeros(size(X));
         for ii=1:size(X,1)*size(X,2)
                 [ZZ(ii),GZ] =eval_krg([X(ii) Y(ii)],tirages,krg);
                 GK1(ii)=GZ(1);
                 GK2(ii)=GZ(2);
         end
         ZK.Z=ZZ;
        
            %%%affichage de la surface obtenue par KRG
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{KRG}';
            aff.grad=false;
            cofast.grad=false;
            affichage(X,Y,ZK,tirages,eval,aff);

             %%affichage du gradient de la fonction
            aff.titre=['Gradient de linterpolation par Krigeage'];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='dF_{KRG}/dx';
            aff.grad=true;
            cofast.grad=false;
            affichage_gr(X,Y,ZK.Z,GK1,GK2,aff);
            
             figure;
            quiver3(X,Y,ZK.Z,GK1,GK2,-ones(size(GK1)),0.5)
            hold on;
            surf(X,Y,ZK.Z)
            
            
            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=false;
            aff.grad=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,ZK,tirages,eval,aff);
            emse=['MSE=',num2str(mse(Z.Z,ZK.Z))];
            err=['R2=',num2str(r_square(Z.Z,ZK.Z))];
            eraae=['RAAE=',num2str(raae(Z.Z,ZK.Z))];
            ermae=['RMAE=',num2str(rmae(Z.Z,ZK.Z))];
            disp(' ')
            disp(emse)
            disp(err)
            disp(eraae)
            disp(ermae)
            disp(' ')
        disp('=====================================');
        disp('=====================================');

    case 'DACE' %utilisation de la Toolbox DACE
        disp('>>> Interpolation par Krigeage (Toolbox DACE)');
        disp(' ')
        [model,perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.theta);
        ZZ=zeros(size(X));
        for ii=1:size(X,1)
            for jj=1:size(X,2)
                ZZ(ii,jj)=predictor([X(ii,jj) Y(ii,jj)],model);
            end
        end
        ZK.Z=ZZ;
            %%%affichage de la surface obtenue par KRG
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.d3=true;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.grad=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{KRG}';
            aff.grad=false;
            cofast.grad=false;
            affichage(X,Y,ZK,tirages,eval,aff);

            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour2=false;
            aff.contour3=false;
            aff.d3=true;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=false;
            aff.titre=['Surface obtenue par Krigeage: theta ',...
                num2str(meta.theta),' regression ',meta.regr,' corrélation ',meta.corr];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,ZK,tirages,eval,aff);
            emse=['MSE=',num2str(mse(Z.Z,ZK.Z))];
            err=['R2=',num2str(r_square(Z.Z,ZK.Z))];
            eraae=['RAAE=',num2str(raae(Z.Z,ZK.Z))];
            ermae=['RMAE=',num2str(rmae(Z.Z,ZK.Z))];
            disp(' ')
            disp(emse)
            disp(err)
            disp(eraae)
            disp(ermae)
            disp(' ')
        disp('=====================================');
        disp('=====================================');

    case 'RBF'  %fonctions à base radiale
        disp('>>> Interpolation par fonctions à base radiale');
        disp(' ')
        w=meta_rbf(tirages,eval,meta.para,meta.fct);
        ZRBF=eval_rbf(X,Y,tirages,w,meta.para,meta.fct);Za.Z=ZRBF;
        [GRBF1,GRBF2]=evald_rbf(X,Y,tirages,w,meta.para,meta.fct);
        
            %%%affichage de la surface obtenue par RBF
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=false;
            aff.uni=false;
            aff.pts=false;
            aff.titre=['Surface obtenue par interpolation par fonctions à base radiale: r=',...
                num2str(meta.para),' fonction  ',meta.fct];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F_{RBF}';
            aff.grad=false;
            affichage(X,Y,Za,tirages,eval,aff);
            
            %%affichage du gradient de la fonction
            aff.titre=['Gradient de linterpolation par fonctions à base radiale'];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='dF_{RBF}/dx';
            aff.grad=true;
            %affichage_gr(X,Y,Za.Z,GRBF1,GRBF2,aff);
            Za.GR1=GRBF1;
            Za.GR2=GRBF2;
            aff.d2=false;
            affichage(X,Y,Za,tirages,eval,aff);
            

            
            %%%affichage de l'écart entre la fonction objectif et la fonction
            %%%approchée
            %paramètrage options
            aff.newfig=true;
            aff.contour=false;
            aff.rendu=true;
            aff.uni=true;
            aff.color='blue';
            aff.pts=true;
            aff.titre=['Surface obtenue par interpolation par fonctions à base radiale: r=',...
                num2str(meta.para),' fonction  ',meta.fct];
            aff.xlabel='x_{1}';
            aff.ylabel='x_{2}';
            aff.zlabel='F';
            aff.grad=false;
            affichage(X,Y,Z,tirages,eval,aff);
            aff.newfig=false;
            aff.color='red';
            affichage(X,Y,Za,tirages,eval,aff);
            emse=['MSE=',num2str(mse(Z.Z,ZRBF))];
            err=['R2=',num2str(r_square(Z.Z,ZRBF))];
            eraae=['RAAE=',num2str(raae(Z.Z,ZRBF))];
            ermae=['RMAE=',num2str(rmae(Z.Z,ZRBF))];
            disp(' ')
            disp(emse)
            disp(err)
            disp(eraae)
            disp(ermae)
        disp(' ')
        
        disp('=====================================');
        disp('=====================================');
        
    case 'POD'  %décomposition en valeurs singulières
        disp('>>> décomposition en valeurs singulières');
        disp(' ')
        S=meta_pod(tirages,xxx,yyy,eval,meta.nb_vs);
        extr_vs=zeros(size(S,1),2);
        for ii=1:size(S,1)
            extr_vs(ii,1)=ii;
            extr_vs(ii,2)=S(ii,ii);
        end
end
        

   