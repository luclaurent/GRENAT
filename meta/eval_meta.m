%% Evaluation du metamodele
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr
% modif le 12/12/2011


function [Z]=eval_meta(points,donnees,meta)

%reconditionneent données construction
if ~iscell(donnees)
    donnees_const={donnees};
    Z=struct;
else
    donnees_const=donnees;
    Z=cell(size(donnees));
end

%nombre de variables
nb_var=donnees_const{1}.nb_var;
%nombre de points
nb_val=donnees_const{1}.nb_val;
dim_ev(1)=size(points,1);
dim_ev(2)=size(points,2);
dim_ev(3)=size(points,3);

%reconditionnement des points d'évaluations
if nb_var>1
    % si les points d'entrée correspondent à une grille
    if dim_ev(3)~=1
        %alors on définit le nombre de points à évaluer
        nb_ev_pts=prod(dim_ev(1:2)); %nb de points d'évaluation du métamodèle
        ev_pts=zeros(nb_ev_pts,dim_ev(3));
        for ll=1:dim_ev(3)
            tmp=points(:,:,ll);
            ev_pts(:,ll)=tmp(:);
        end
    else
        %sinon on définit le nombre de points à évaluer
        nb_ev_pts=dim_ev(1);
        ev_pts=points;
    end
else
    nb_ev_pts=prod(dim_ev(1:2)); %nb de points d'évaluation du métamodèle
    ev_pts=points(:);
end

%variables de stockage
if nb_var>1
    var_rep=zeros(size(ev_pts,1),1);
    rep=zeros(size(ev_pts,1),1);
    GR=zeros(nb_ev_pts,nb_var);
else
    var_rep=[];
    rep=[];
    GR=[];
end


%%%%%%% Evaluation de divers metamodeles
% generation des metamodeles
for num_meta=1:numel(donnees_const)
    type=donnees_const{num_meta}.type;
    meta_donnee=donnees_const{num_meta};
    
    %chargement variables
    tirages=meta_donnee.tirages;
    eval=meta_donnee.eval;
    grad=meta_donnee.grad;
    
    %si l'on souhaite vérifier le metamodele à l'évaluation (vérification
    %de l'interpolation)
    if meta.verif
        Zverif=zeros(nb_val,1);varverif=zeros(nb_val,1);
        GZverif=zeros(nb_val,nb_var);
    end
    switch type
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        case 'SWF'
            %%	Evaluation du metamodele 'Shepard Weighting Functions'
            for jj=1:nb_ev_pts
                [rep(jj),G]=eval_swf(ev_pts(jj,:),meta_donnee);
                GR(jj,:)=G;
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'GRBF','RBF'}
            %% Evaluation du metamodele de RBF/HBRBF
            for jj=1:nb_ev_pts
                
                [rep(jj),G]=eval_rbf(ev_pts(jj,:),meta_donnee);
                GR(jj,:)=G;

            end
            %% verification interpolation
            if meta.verif
                for jj=1:size(tirages,1)
                    [Zverif(jj),G]=eval_rbf(tirages(jj,:),meta_donnee);
                    GZverif(jj,:)=G;
                end
                diffZ=Zverif-eval;
                
                if ~isempty(find(diffZ>1e-7, 1))
                    fprintf('pb d''interpolation (eval) GRBF\n')
                    diffZ
                end 
                
                if meta_donnee.in.pres_grad
                    diffGZ=GZverif-grad;
                    if ~isempty(find(diffGZ>1e-7, 1))
                        fprintf('pb d''interpolation (grad) GRBF\n')
                        diffGZ
                    end
                    diffNG=sqrt(sum(GZverif.^2,2))-sqrt(sum(grad.^2,2));
                    if ~isempty(find(diffNG>1e-7, 1))
                        fprintf('pb d''interpolation (grad) GRBF\n')
                        diffNG
                    end
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'KRG','CKRG'}
            
            %stockage specifique
            Z_sto=rep;Z_reg=rep;
            GR_reg=GR;GR_sto=GR;
            
            %% Evaluation du metamodele de Krigeage/CoKrigeage
            for jj=1:nb_ev_pts
                [rep(jj),G,var_rep(jj),det]=eval_krg_ckrg(ev_pts(jj,:),meta_donnee);
                GR(jj,:)=G;
                Z_sto(jj)=det.Z_sto;
                Z_reg(jj)=det.Z_reg;
                GR_reg(jj,:)=det.GZ_reg;
                GR_sto(jj,:)=det.GZ_sto;
            end
            
            
            %% verification interpolation
            if meta.verif
                for jj=1:size(tirages,1)
                    [Zverif(jj),G,varverif(jj)]=eval_krg_ckrg(tirages(jj,:),meta_donnee);
                    GZverif(jj,:)=G';
                end
                diffZ=Zverif-eval;
                
                if ~isempty(find(diffZ>1e-7, 1))
                    fprintf('pb d''interpolation (eval) CKRG\n')
                    diffZ
                end
                if meta_donnee.in.pres_grad
                    diffGZ=GZverif-grad;
                    if ~isempty(find(diffGZ>1e-7, 1))
                        fprintf('pb d''interpolation (grad) CKRG\n')
                        diffGZ
                    end
                    diffNG=sqrt(sum(GZverif.^2,2))-sqrt(sum(grad.^2,2));
                    if ~isempty(find(diffNG>1e-7, 1))
                        fprintf('pb d''interpolation (grad) CKRG\n')
                        diffNG
                    end
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            
        case 'DACE'
            %% Evaluation du metamodele de Krigeage (DACE)
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [rep(jj,kk),G,var_rep(jj,kk)]=predictor(points(jj,kk,:),meta_donnee);
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
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %reconditionnement gradients
    if nb_var>1
        if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
            GZ_sto=zeros(dim_ev(1),dim_ev(2),dim_ev(3));
            GZ_reg=zeros(dim_ev(1),dim_ev(2),dim_ev(3));
        end
        GZ=zeros(dim_ev(1),dim_ev(2),dim_ev(3));
        if dim_ev(3)>1
            for ll=1:dim_ev(3)
                tmp=GR(:,ll);
                GZ(:,:,ll)=reshape(tmp,dim_ev(1),dim_ev(2));
            end
            if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
                for ll=1:dim_ev(3)
                    tmp=GR_sto(:,ll);
                    tmp1=GR_reg(:,ll);
                    GZ_sto(:,:,ll)=reshape(tmp,dim_ev(1),dim_ev(2));
                    GZ_reg(:,:,ll)=reshape(tmp1,dim_ev(1),dim_ev(2));
                end
            end
        else
            GZ=GR;
            if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
                GZ_sto=GR_sto;
                GZ_reg=GR_reg;
            end
        end
    else
        GZ=GR;
        if exist('GR_sto','var')==1&&exist('GR_reg','var')==1
            GZ_sto=GR_sto;
            GZ_reg=GR_reg;
        end
    end
    
    %Stockage des evaluations
    if numel(donnees_const)==1
        if nb_var>1
            if dim_ev(3)==1
                if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                    Z.Z_sto=Z_sto;
                    Z.Z_reg=Z_reg;
                end
                Z.Z=rep;
                Z.var=var_rep;
            else
                if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                    Z.Z_sto=reshape(Z_sto,dim_ev(1),dim_ev(2));
                    Z.Z_reg=reshape(Z_reg,dim_ev(1),dim_ev(2));
                end
                Z.Z=reshape(rep,dim_ev(1),dim_ev(2));
                Z.var=reshape(var_rep,dim_ev(1),dim_ev(2));
            end
        else
            if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                Z.Z_sto=reshape(Z_sto,dim_ev(1),dim_ev(2));
                Z.Z_reg=reshape(Z_reg,dim_ev(1),dim_ev(2));
            end
            Z.Z=reshape(rep,dim_ev(1),dim_ev(2));
            if ~isempty(var_rep)
                Z.var=reshape(var_rep,dim_ev(1),dim_ev(2));
            end
        end
        Z.GZ=GZ;
        if exist('GZ_sto','var')==1&&exist('GZ_reg','var')==1
            Z.GZ_sto=GZ_sto;Z.GZ_reg=GZ_reg;
        end
    else
        Z{num_meta}.Z=rep;
        Z{num_meta}.GZ=GZ;
        Z{num_meta}.var=var_rep;
        if exist('GZ_sto','var')==1&&exist('GZ_reg','var')==1
            Z{num_meta}.GZ_sto=GZ_sto;Z{num_meta}.GZ_reg=GZ_reg;
        end
        if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
            Z{num_meta}.Z_sto=Z_sto;Z{num_meta}.Z_reg=Z_reg;
        end
    end
end

