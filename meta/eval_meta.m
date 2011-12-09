%% Evaluation du metamodele
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr


function [Z]=eval_meta(points,donnees,meta)


%nombre de variables
nb_var=donnees{1}.nb_var;
%nombre de points
nb_val=donnees{1}.nb_val;
dim_ev=size(points);

%varibales de stockage
var=zeros(dim_ev([1 2]));
rep=zeros(dim_ev([1 2]));
Z=cell(size(donnees));
GR=zeros(dim_ev(1),dim_ev(2),nb_var);

%%%%%%% Evaluation de divers metamodeles
% generation des metamodeles
for num_meta=1:numel(donnees)
    type=donnees{num_meta}.type;
    meta_donnee=donnees{num_meta};
    
    %chargement variables
    tirages=donnees{num_meta}.tirages;
    eval=donnees{num_meta}.eval;
    % en dimension 1, les points ou l'on souhaite evaluer le metamodele se
    % presentent sous forme d'une matrice
    if nb_var==1
        
        switch type
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            case 'SWF'
                %%	Evaluation du metamodele 'Shepard Weighting Functions'
                for jj=1:length(points)
                    [rep(jj),G]=eval_swf(points(jj),meta_donnee);
                    GR(jj)=G;
                end
            case 'RBF'
                %%	Evaluation du metamodele 'RBF/HBRBF'
                
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'CKRG'
                %%     Evaluation du metamodele de CoKrigeage
                for jj=1:length(points)
                    [rep(jj),G,var(jj)]=eval_ckrg(points(jj),meta_donnee);
                    GR(jj)=G;
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'KRG'
                %%     Evaluation du metamodele de Krigeage
                for jj=1:length(points)
                    [rep(jj),G,var(jj)]=eval_krg(points(jj),meta_donnee);
                    GR(jj)=G;
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'DACE'
                %% Evaluation du metamodele de Krigeage (DACE)
                for jj=1:length(points)
                    [rep(jj),G,var(jj)]=predictor(points(jj),meta_donnee);
                    GR(jj)=G;
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'PRG'
                for degre=meta.deg
                    %% Evaluation du metamodele de Regression
                    for jj=1:length(points)
                        rep(jj)=eval_prg(prg.coef,points(jj,1),points(jj,2),meta_donnee);
                        %evaluation des gradients du MT
                        [GRG1,GRG2]=evald_prg(prg.coef,points(jj,1),points(jj,2),meta_donnee);
                        GR(jj)=[GRG1 GRG2];
                    end
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'ILIN'
                %% interpolation par fonction de base linéaire
                fprintf('\n%s\n',[textd  'Interpolation par fonction de base linéaire' textf]);
                for jj=1:length(points)
                    [rep(jj),GR(jj)]=interp_lin(points(jj),meta_donnee);
                end
                
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'ILAG'
                %% interpolation par fonction polynomiale de Lagrange
                fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
                for jj=1:length(points)
                    [rep(jj),GR(jj)]=interp_lag(points(jj),meta_donnee);
                end
                
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
        switch type
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            case 'SWF'
                %%	Evaluation du metamodele 'Shepard Weighting Functions'
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G]=eval_swf(points(jj,kk,:),meta_donnee);
                        GR(jj,kk,:)=G;
                    end
                end
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'CKRG'
                %% Evaluation du metamodele de CoKrigeage
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G,var(jj,kk)]=eval_ckrg(points(jj,kk,:),meta_donnee);
                        GR(jj,kk,:)=G;
                    end
                end
                %% verification interpolation
                if meta.verif
                    for jj=1:size(tirages,1)
                        [Zverif(jj),G,varverif(jj)]=eval_ckrg(tirages(jj,:),meta_donnee);
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
                        [rep(jj,kk),G,var(jj,kk)]=eval_krg(points(jj,kk,:),meta_donnee);
                        GR(jj,kk,:)=G;
                    end
                end
                %% verification interpolation
                if meta.verif
                    for jj=1:size(tirages,1)
                        [Zverif(jj),G,varverif(jj)]=eval_krg(tirages(jj,:),meta_donnee);
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
                        [rep(jj,kk),G,var(jj,kk)]=predictor(points(jj,kk,:),meta_donnee);
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
                            rep(jj,kk)=eval_prg(prg.coef,points(jj,kk,1),points(jj,kk,2),meta_donnee);
                            %evaluation des gradients du MT
                            [GRG1,GRG2]=evald_prg(prg.coef,points(jj,kk,1),points(jj,kk,2),meta_donnee);
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
                        [rep(jj,kk),G]=interp_lin(points(jj,kk,:),meta_donnee);
                        GR1(jj,kk)=G(1);
                        GR2(jj,kk)=G(2);
                    end
                end
                
                %%%%%%%%=================================%%%%%%%%
                %%%%%%%%=================================%%%%%%%%
            case 'ILAG'
                %% interpolation par fonction polynomiale de Lagrange
                fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
                for jj=1:size(points,1)
                    for kk=1:size(points,2)
                        [rep(jj,kk),G]=interp_lag(points(jj,kk,:),meta_donnee);
                        GR1(jj,kk)=G(1);
                        GR2(jj,kk)=G(2);
                    end
                end
                
        end
    else
        error('dimension non encore prise en charge');
    end
    
    %Stockage des evaluations
    Z{num_meta}.Z=rep;
    Z{num_meta}.GZ=GR;
    Z{num_meta}.var=var;
    
end

