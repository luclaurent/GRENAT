%%Etude metamodeles en 2D
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr

%effacement du Workspace
clear all

%chargement des repertoires de travail
init_rep;
%initialisation de l'espace de travail
init_esp;
%affichage de la date et de l'heure


aff_date;
%initialisation des variables d'affichage
aff=init_aff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fonction etudiee
fun{1}='branin'; %branin,gold,peaks,rosenbrock,sixhump
fun{2}='gold';
fun{3}='peaks';
%fun{1}='rosenbrock';
%fun{1}='sixhump';

for itfun=1:length(fun)
    fct=fun{itfun};
    

%%Definition de l'espace de conception
[doe.bornes,doe.fct]=init_doe(fct);

%nombre d'element pas dimension (pour le trace)
aff.nbele=30;

%type de tirage LHS/Factoriel complet (ffact)/Remplissage espace (sfill)
doe.type='ffact';

%parametrage balayage nombre de points
nb_min=2;nb_max=10;


%metamodeles construits
const{1}='KRG';const{2}='CKRG';

donnees=cell(1,length(const));

for itconst=1:length(const)
    donnees{itconst}=zeros(15,nb_max-nb_min+1);
    nbb=0;
    for nb=nb_min:nb_max
        close all
        %nb d'echantillons
        doe.nb_samples=nb;
        
        sprintf('Nombre de TIRAGES:   %d\n',nb^2)

        % Parametrage du metamodele
        deg=0;
        theta=[0 25];
        corr='matern32';
        modm=const{itconst};
        meta=init_meta(modm,deg,theta,corr);

        %affichage de l'intervalle de confiance
        aff.ic.on=true;
        aff.ic.type='68'; %('0','68','95','99')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Creation du dossier de travail
        aff.doss=['results/para_' fct '_' doe.type '_' modm];
        cmd=['mkdir ' aff.doss];unix(cmd);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('=====================================');
        disp('=====================================');
        disp('=======Construction metamodele=======');
        disp('=====================================');
        disp('=====================================');

        %realisation des tirages
        tirages=gene_doe(doe);

        %evaluations de la fonction aux points
        [eval,grad]=gene_eval(doe.fct,tirages);

        %Trace de la fonction de la fonction etudiee et des gradients
        [grid_XY,aff]=gene_aff(doe,aff);
        Z=gene_eval(doe.fct,grid_XY);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Construction et evaluation du metamodele aux points souhaites
        [K,krg]=gene_meta(tirages,eval,grad,grid_XY,meta);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%generation des differents intervalles de confiance
        [ic68,ic95,ic99]=const_ic(K.Z,K.var);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            
         %%%affichage
        aff.on='true';
        aff.num=aff.num+1;
        aff.newfig=false;
        aff.ic.on=true;
        figure;
        subplot(3,3,1)
        if aff.ic.on
            aff.rendu=true;
            aff.titre=['Intervalle de confiance IC' aff.ic.type];
            switch aff.ic.type
                case '68'
                    affichage_ic(grid_XY,ic68,aff);
                case '95'
                    affichage_ic(grid_XY,ic95,aff);
                case '99'
                    affichage_ic(grid_XY,ic99,aff);
            end
            subplot(3,3,2)
            aff.titre='Variance de prediction';
            aff.d3=true;
            v.Z=K.var;
            affichage(grid_XY,v,tirages,eval,grad,aff);
            camlight; lighting gouraud;
            aff.titre='';
            aff.rendu=false;
        end

        %fonction de reference
        aff.newfig=false;
        aff.d3=true;
        aff.contour3=true;
        aff.pts=true;
        aff.titre='Fonction de reference';
        subplot(3,3,4)
        affichage(grid_XY,Z,tirages,eval,grad,aff);
        aff.titre='Metamodele';
        subplot(3,3,5)
        affichage(grid_XY,K,tirages,eval,grad,aff);

        aff.titre='Fonction de reference';
        aff.d3=false;
        aff.d2=true;
        aff.grad_eval=true;
        aff.grad_meta=true;
        aff.contour2=true;
        subplot(3,3,7)
        affichage(grid_XY,Z,tirages,eval,grad,aff);
        aff.titre='Metamodele';
        subplot(3,3,8)
        affichage(grid_XY,K,tirages,eval,grad,aff);
        aff.titre=[];
        aff.grad_eval=false;
        aff.grad_meta=false;
        aff.contour2=false;
        aff.d2=false;



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %sauvegarde image
        aff.num=save_aff(aff.num,aff.doss);

        %calcul et affichage des criteres d'erreur
        err=crit_err(K.Z,Z.Z,krg);

        fprintf('=====================================\n');
        fprintf('=====================================\n');


        %enregistrement donnees en vue de leur sauvegarde
        nbb=nbb+1;
        donnees{itconst}(1,nbb)=nb^2;
        donnees{itconst}(2,nbb)=krg.tps;
        donnees{itconst}(3,nbb)=krg.estim_para.iterations;
        donnees{itconst}(4,nbb)=err.emse;
        donnees{itconst}(5,nbb)=err.r2;
        donnees{itconst}(6,nbb)=err.eraae;
        donnees{itconst}(7,nbb)=err.ermae;
        donnees{itconst}(8,nbb)=err.eq1;
        donnees{itconst}(9,nbb)=err.eq2;
        donnees{itconst}(10,nbb)=err.eq3;
        donnees{itconst}(11,nbb)=krg.cv.bm;
        donnees{itconst}(12,nbb)=krg.cv.msep;
        donnees{itconst}(13,nbb)=krg.cv.adequ;
        donnees{itconst}(14,nbb)=krg.cv.press;
        donnees{itconst}(15,nbb)=krg.estim_para.theta;
        clear krg

    end
end

%extraction des donnees

sprintf('Sauvegarde donnees %s \n',fct)
extract_caract(meta,donnees,fct,const);

end
