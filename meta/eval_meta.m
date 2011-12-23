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
dim_ev=size(points);

%reconditionnement des points d'évaluations
nb_ev_pts=prod(dim_ev(1:2)); %nb de points d'évaluation du métamodèle
if nb_var>1
    ev_pts=zeros(nb_ev_pts,dim_ev(3));
    for ll=1:dim_ev(3)
        tmp=points(:,:,ll);
        ev_pts(:,ll)=tmp(:);
    end
else
    ev_pts=points(:);
end

%variables de stockage
var=zeros(dim_ev([1 2]));
rep=zeros(dim_ev([1 2]));
GR=zeros(nb_ev_pts,nb_var);


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
        case 'CKRG'
            %% Evaluation du metamodele de CoKrigeage
            for jj=1:nb_ev_pts
                [rep(jj),G,var(jj)]=eval_krg_ckrg(ev_pts(jj,:),meta_donnee);
                GR(jj,:)=G;
            end
            
            %% verification interpolation
            if meta.verif
                for jj=1:size(tirages,1)
                    [Zverif(jj),G,varverif(jj)]=eval_krg_ckrg(tirages(jj,:),meta_donnee);
                    GZverif(jj,:)=G;
                end
                diffZ=Zverif-eval;
                diffGZ=GZverif-grad;
                if ~isempty(find(diffZ>1e-7, 1))
                    fprintf('pb d''interpolation (eval) CKRG\n')
                    diffZ
                end
                if ~isempty(find(diffGZ>1e-7, 1))
                    fprintf('pb d''interpolation (grad) CKRG\n')
                    diffGZ
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'KRG'
            %% Evaluation du metamodele de Krigeage
            for jj=1:nb_ev_pts
                [rep(jj),G,var(jj)]=eval_krg_ckrg(ev_pts(jj,:),meta_donnee);
                GR(jj,:)=G;
            end
            %% verification interpolation
            if meta.verif
                for jj=1:size(tirages,1)
                    [Zverif(jj),~,varverif(jj)]=eval_krg_ckrg(tirages(jj,:),meta_donnee);
                end
                diffZ=Zverif-eval;
                if ~isempty(find(diffZ>1e-7, 1))
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
    %reconditionnement gradients
    if nb_var>1
        GZ=zeros(dim_ev(1),dim_ev(2),dim_ev(3));
        for ll=1:dim_ev(3)
            tmp=GR(:,ll);
            GZ(:,:,ll)=reshape(tmp,dim_ev(1),dim_ev(2));
        end
    else
        GZ=GR;
    end
    
    %Stockage des evaluations
    if numel(donnees_const)==1
        Z.Z=rep;
        Z.GZ=GZ;
        Z.var=var;
    else
        Z{num_meta}.Z=rep;
        Z{num_meta}.GZ=GZ;
        Z{num_meta}.var=var;
    end
end

