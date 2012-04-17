%% Generation et evaluation du metamodele
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr


function [Z,ret]=gene_meta(tirages,eval,grad,points,meta)

% Generation du metamodele
textd='===== METAMODELE de ';
textf=' =====';

%nombre de variables
nb_var=size(tirages,2);
%nombre de points
nb_val=size(tirages,1);
dim_ev=size(points);

%prise en compte gradients ou pas
if isempty(grad)||meta.grad==false;pec_grad='Non';grad=[];else;pec_grad='Oui';end

var=zeros(dim_ev([1 2]));
rep=zeros(dim_ev([1 2]));
GR=zeros(dim_ev(1),dim_ev(2),nb_var);

%%%%%%% Generation de divers metamodeles
%initialisation stockage
ret=cell(length(meta.type),1);
Z=ret;
% generation des metamodeles
num_meta=1;
for type=meta.type
    ret{num_meta}.type=type{1};

    %construction metamodele
    switch type{1}
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        case 'SWF'
            %% construction du metamodele 'Shepard Weighting Functions'
            fprintf('\n%s\n',[textd 'Fonctions Shepard (SWF)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            swf=meta_swf(tirages,eval,grad,meta);
            ret{num_meta}=swf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'RBF'
            %% construction du metamodele 'RBF/HBRBF' (Radial Basis Functions and Hermite-Birkhoff Radial Basis Functions)
            
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'CKRG'
            %% Construction du metamodele de CoKrigeage
            fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            ckrg=meta_ckrg(tirages,eval,grad,meta);
            ret{num_meta}=ckrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'KRG'
            %% Construction du metamodele de Krigeage
            fprintf('\n%s\n',[textd 'Krigeage' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
            krg=meta_krg(tirages,eval,meta);
            ret{num_meta}=krg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'DACE'
            %% Construction du metamodele de Krigeage (DACE)
            fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            [dace.model,dace.perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.para);
            ret{num_meta}=dace;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            ite_prg=1;
            ret{num_meta}.prg=length(meta.deg);
            for degre=meta.deg
                %% Construction du metamodele de Regression polynomiale
                fprintf('\n%s\n',[textd  'Regression polynomiale' textf]);
                fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
                fprintf('Gradients: %s\n\n',pec_grad);
                dd=['-- Degre du polynome \n',num2str(degre)];
                fprintf(dd);
                [prg.coef,prg.MSE]=meta_prg(tirages,eval,degre);
                ret{num_meta}.prg{ite_prg}=prg;
                ite_prg=ite_prg+1;
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILIN'
            %% Construction du metamodele d'interpolation lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base ' textf]);
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILAG'
            %% interpolation par fonction de base linéaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
    end
    
    % en dimension 1, les points ou l'on souhaite evaluer le metamodele se
    % presentent sous forme d'une matrice
    if nb_var==1
        
        switch type{1}
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            case 'SWF'
                %%	Evaluation du metamodele 'Shepard Weighting Functions'
                for jj=1:length(points)
                    [rep(jj),G]=eval_swf(points(jj),swf);
                    GR(jj)=G;
                end
            case 'RBF'
                %%	Evaluation du metamodele 'RBF/HBRBF'
                
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'CKRG'
                %%     Evaluation du metamodele de CoKrigeage
                for jj=1:length(points)
                    [rep(jj),G,var(jj)]=eval_ckrg(points(jj),tirages,ckrg);
                    GR(jj)=G;
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'KRG'
                %%     Evaluation du metamodele de Krigeage
                for jj=1:length(points)
                    [rep(jj),G,var(jj)]=eval_krg(points(jj),tirages,krg);
                    GR(jj)=G;
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'DACE'
                %% Evaluation du metamodele de Krigeage (DACE)
                for jj=1:length(points)
                    [rep(jj),G,var(jj)]=predictor(points(jj),dace.model);
                    GR(jj)=G;
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'PRG'
                for degre=meta.deg
                    %% Evaluation du metamodele de Regression
                    for jj=1:length(points)
                        rep(jj)=eval_prg(prg.coef,points(jj,1),points(jj,2),degre);
                        %evaluation des gradients du MT
                        [GRG1,GRG2]=evald_prg(prg.coef,points(jj,1),points(jj,2),degre);
                        GR(jj)=[GRG1 GRG2];
                    end
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'ILIN'
                %% interpolation par fonction de base linéaire
                fprintf('\n%s\n',[textd  'Interpolation par fonction de base linéaire' textf]);
                for jj=1:length(points)
                    [rep(jj),GR(jj)]=interp_lin(points(jj),tirages,eval);
                end
                ret=[];
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'ILAG'
                %% interpolation par fonction polynomiale de Lagrange
                fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
                for jj=1:length(points)
                    [rep(jj),GR(jj)]=interp_lag(points(jj),tirages,eval);
                end
                ret=[];
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
                
        end
        
        % en dimension ou plus, les points ou l'on souhaite evaluer le metamodele se
        % presentent sous forme d'un vecteur de matrices
    elseif nb_var>=2
        if meta.verif
            Zverif=zeros(nb_val,1);varverif=zeros(nb_val,1);
            GZverif=zeros(nb_val,nb_var);
        end
        switch type{1}
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            case 'SWF'
                %%	Evaluation du metamodele 'Shepard Weighting Functions'
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G]=eval_swf(points(jj,kk,:),swf);
                        GR(jj,kk,:)=G;
                    end
                end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            case 'CKRG'
                %% Evaluation du metamodele de CoKrigeage
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G,var(jj,kk)]=eval_ckrg(points(jj,kk,:),tirages,ckrg);
                        GR(jj,kk,:)=G;
                    end
                end
                %% verification interpolation
                if meta.verif
                    for jj=1:size(tirages,1)
                        [Zverif(jj),G,varverif(jj)]=eval_ckrg(tirages(jj,:),tirages,ckrg);
                        GZverif(jj,:)=G;
                    end
                    diffZ=Zverif-eval;
                    diffGZ=GZverif-grad;
                    if ~isempty(find(diffZ>1e-7))
                        fprintf('pb d''interpolation (eval) CKRG\n')
                        diffZ
                    end
                    if ~isempty(find(diffGZ>1e-7))
                        fprintf('pb d''interpolation (grad) CKRG\n')
                        diffGZ
                    end
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'KRG'
                %% Evaluation du metamodele de Krigeage
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G,var(jj,kk)]=eval_krg(points(jj,kk,:),tirages,krg);
                        GR(jj,kk,:)=G;
                    end
                end
                %% verification interpolation
                if meta.verif
                    for jj=1:size(tirages,1)
                        [Zverif(jj),G,varverif(jj)]=eval_krg(tirages(jj,:),tirages,krg);
                    end
                    diffZ=Zverif-eval;
                    if ~isempty(find(diffZ>1e-7))
                        fprintf('pb d''interpolation (eval) KRG\n')
                        diffZ
                    end
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'DACE'
                %% Evaluation du metamodele de Krigeage (DACE)
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G,var(jj,kk)]=predictor(points(jj,kk,:),dace.model);
                        GR(jj,kk)=G(1);
                        GR(jj,kk)=G(2);
                    end
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'PRG'
                for degre=meta.deg
                    %% Evaluation du metamodele de Regression
                    for jj=1:length(points)
                        for kk=1:size(points,2)
                            rep(jj,kk)=eval_prg(prg.coef,points(jj,kk,1),points(jj,kk,2),degre);
                            %evaluation des gradients du MT
                            [GRG1,GRG2]=evald_prg(prg.coef,points(jj,kk,1),points(jj,kk,2),degre);
                            GR(jj,kk)=GRG1;
                            GR(jj,kk)=GRG2;
                        end
                    end
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'ILIN'
                %% interpolation par fonction de base linéaire
                fprintf('\n%s\n',[textd  'Interpolation par fonction de base linéaire' textf]);
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G]=interp_lin(points(jj,kk,:),tirages,eval);
                        GR1(jj,kk)=G(1);
                        GR2(jj,kk)=G(2);
                    end
                end
                ret=[];
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'ILAG'
                %% interpolation par fonction polynomiale de Lagrange
                fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G]=interp_lag(points(jj,kk,:),tirages,eval);
                        GR1(jj,kk)=G(1);
                        GR2(jj,kk)=G(2);
                    end
                end
                ret=[];
        end
    else
        error('dimension non encore prise en charge');
    end
    
    %Stockage des evaluations
    Z{num_meta}.Z=rep;
    Z{num_meta}.GZ=GR;
    Z{num_meta}.var=var;
    
    num_meta=num_meta+1;
end

