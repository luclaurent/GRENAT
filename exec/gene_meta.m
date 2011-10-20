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

var=zeros(dim_ev([1 2]));
Z.Z=zeros(dim_ev([1 2]));


%construction metamodele
switch meta.type
    case 'CKRG'
        %% Construction du metamodele de CoKrigeage
        fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
        %affichage informations
        fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
        ckrg=meta_ckrg(tirages,eval,grad,meta);
        ret=ckrg;
    case 'KRG'
        %% Construction du metamodele de Krigeage
        fprintf('\n%s\n',[textd 'Krigeage' textf]);
        %affichage informations
        fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
        krg=meta_krg(tirages,eval,meta);
        ret=krg;
    case 'DACE'
        %% Construction du metamodele de Krigeage (DACE)
        fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
        %affichage informations
        fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
        [dace.model,dace.perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.para);
        ret=dace;
    case 'PRG'
        for degre=meta.deg
            %% Construction du metamodele de Regression polynomiale
            fprintf('\n%s\n',[textd  'Regression polynomiale' textf]);
            dd=['-- Degre du polynome \n',num2str(degre)];
            fprintf(dd);
            [prg.coef,prg.MSE]=meta_prg(tirages,eval,degre);
            ret=prg;
        end
    case 'ILIN'
        %% Construction du metamodele d'interpolation lineaire
        fprintf('\n%s\n',[textd  'Interpolation par fonction de base ' textf]);
    case 'ILAG'
        %% interpolation par fonction de base linéaire
        fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
end

% en dimension 1, les points ou l'on souhaite evaluer le metamodele se
% presentent sous forme d'une matrice
if nb_var==1
    Z.GZ=zeros(dim_ev);
    switch meta.type
        case 'CKRG'
            %% Evaluation du metamodele de CoKrigeage
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=eval_ckrg(points(jj),tirages,ckrg);
                Z.GZ(jj)=G;
            end
        case 'KRG'
            %% Evaluation du metamodele de Krigeage
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=eval_krg(points(jj),tirages,krg);
                Z.GZ(jj)=G;
            end
        case 'DACE'
            %% Evaluation du metamodele de Krigeage (DACE)
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=predictor(points(jj),dace.model);
                Z.GZ(jj)=G;
            end
        case 'PRG'
            for degre=meta.deg
                %% Evaluation du metamodele de Regression
                for jj=1:length(points)
                    Z.Z(jj)=eval_prg(prg.coef,points(jj,1),points(jj,2),degre);
                    %evaluation des gradients du MT
                    [GRG1,GRG2]=evald_prg(prg.coef,points(jj,1),points(jj,2),degre);
                    Z.GZ(jj)=[GRG1 GRG2];
                end
            end
        case 'ILIN'
            %% interpolation par fonction de base linéaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base linéaire' textf]);
            for jj=1:length(points)
                [Z.Z(jj),Z.GZ(jj)]=interp_lin(points(jj),tirages,eval);
            end
            ret=[];
        case 'ILAG'
            %% interpolation par fonction polynomiale de Lagrange
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            for jj=1:length(points)
                [Z.Z(jj),Z.GZ(jj)]=interp_lag(points(jj),tirages,eval);
            end
            ret=[];
            
    end
    
    % en dimension ou plus, les points ou l'on souhaite evaluer le metamodele se
    % presentent sous forme d'un vecteur de matrices
elseif nb_var>=2
    Z.GR=zeros(dim_ev(1),dim_ev(2),nb_var);
    if meta.verif
        Zverif=zeros(nb_val,1);varverif=zeros(nb_val,1);
        GZverif=zeros(nb_val,nb_var);
    end
    switch meta.type
        case 'CKRG'
            %% Evaluation du metamodele de CoKrigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=eval_ckrg(points(jj,kk,:),tirages,ckrg);
                    Z.GR(jj,kk,:)=G;
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
        case 'KRG'
            %% Evaluation du metamodele de Krigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=eval_krg(points(jj,kk,:),tirages,krg);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
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
        case 'DACE'
            %% Evaluation du metamodele de Krigeage (DACE)
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=predictor(points(jj,kk,:),dace.model);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
        case 'PRG'
            for degre=meta.deg
                %% Evaluation du metamodele de Regression
                for jj=1:length(points)
                    for kk=1:size(points,2)
                        Z.Z(jj,kk)=eval_prg(prg.coef,points(jj,kk,1),points(jj,kk,2),degre);
                        %evaluation des gradients du MT
                        [GRG1,GRG2]=evald_prg(prg.coef,points(jj,kk,1),points(jj,kk,2),degre);
                        Z.GR1(jj,kk)=GRG1;
                        Z.GR1(jj,kk)=GRG2;
                    end
                end
            end
        case 'ILIN'
            %% interpolation par fonction de base linéaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base linéaire' textf]);
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G]=interp_lin(points(jj,kk,:),tirages,eval);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
            ret=[];
        case 'ILAG'
            %% interpolation par fonction polynomiale de Lagrange
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G]=interp_lag(points(jj,kk,:),tirages,eval);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
            ret=[];
    end
else
    error('dimension non encore prise en charge');
end

%Variance de prediction
Z.var=var;
