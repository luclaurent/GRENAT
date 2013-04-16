%% Evaluation du metamodele
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr
% modif le 12/12/2011


function [Z]=eval_meta(points,donnees,meta,verb)


[tMesu,tInit]=mesu_time;

%reconditionnement donnees construction
if ~iscell(donnees)
    donnees_const={donnees};
    Z=struct;
else
    donnees_const=donnees;
    if numel(donnees)~=1
        Z=cell(size(donnees));
    else
        Z=[];
    end
end

%parametre verbosite de la fonction
if nargin==3
    verb=true;
end

%nombre de variables
nb_var=donnees_const{1}.nb_var;
%nombre de points
nb_val=donnees_const{1}.nb_val;
dim_ev(1)=size(points,1);
dim_ev(2)=size(points,2);
dim_ev(3)=size(points,3);

%reconditionnement des points d'evaluations
if nb_var>1
    % si les points d'entree correspondent a une grille
    if dim_ev(3)~=1
        %alors on definit le nombre de points a evaluer
        nb_ev_pts=prod(dim_ev(1:2)); %nb de points d'evaluation du metamodele
        ev_pts=zeros(nb_ev_pts,dim_ev(3));
        for ll=1:dim_ev(3)
            tmp=points(:,:,ll);
            ev_pts(:,ll)=tmp(:);
        end
    else
        %sinon on definit le nombre de points a evaluer
        nb_ev_pts=dim_ev(1);
        ev_pts=points;
    end
else
    nb_ev_pts=prod(dim_ev(1:2)); %nb de points d'evaluation du metamodele
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
if nb_ev_pts>1&&verb
    fprintf('#########################################\n');
    fprintf('  >>> EVALUATION METAMODELE <<<\n');
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
    
    %si l'on souhaite verifier le metamodele a l'evaluation (verification
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
        case {'GRBF','RBF','InRBF'}
            %% Evaluation du metamodele de RBF/GRBF
            parfor jj=1:nb_ev_pts
                
                [rep(jj),G,var_rep(jj),det]=eval_rbf(ev_pts(jj,:),meta_donnee);
                GR(jj,:)=G;
            end
            %% verification interpolation
            if meta.verif
                parfor jj=1:size(tirages,1)
                    [Zverif(jj),G]=eval_rbf(tirages(jj,:),meta_donnee);
                    GZverif(jj,:)=G;
                end
                
                diffZ=Zverif-eval;
                if ~isempty(find(diffZ>1e-7,1))
                    fprintf('Pb d''interpolation (eval) RBF\n')
                    fprintf('DiffZ \t\t||Eval\t\t||Zverif\n');
                    conc=vertcat(diffZ',eval',Zverif');
                    fprintf('%4.2e\t||%4.2e\t||%4.2e\n',conc(:))
                end
                
                if meta_donnee.in.pres_grad
                    diffGZ=GZverif-grad;
                    if ~isempty(find(diffGZ>1e-7, 1))
                        fprintf('Pb d''interpolation (grad) RBF\n')
                        tt=repmat('\t\t',1,nb_var);
                        fprintf(['DiffGZ' tt '||Grad' tt '||GZverif\n']);
                        conc=vertcat(diffGZ',grad',GZverif');
                        tt=repmat('%4.2e\t',1,nb_var);
                        tt=[tt '||' tt '||' tt '\n'];
                        fprintf(tt,conc(:))
                        
                    end
                    diffNG=sqrt(sum(GZverif.^2,2))-sqrt(sum(grad.^2,2));
                    if ~isempty(find(diffNG>1e-7, 1))
                        fprintf('Pb d''interpolation (grad) RBF\n')
                        fprintf('DiffNG\n')
                        fprintf('%4.2e\n',diffNG)
                    end
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case {'KRG','CKRG','InKRG'}
            
            %stockage specifique
            Z_sto=rep;Z_reg=rep;
            GR_reg=GR;GR_sto=GR;
            %% Evaluation du metamodele de Krigeage/CoKrigeage
            parfor jj=1:nb_ev_pts
                [rep(jj),G,var_rep(jj),det]=eval_krg_ckrg(ev_pts(jj,:),meta_donnee);
                GR(jj,:)=G;
                Z_sto(jj)=det.Z_sto;
                Z_reg(jj)=det.Z_reg;
                GR_reg(jj,:)=det.GZ_reg;
                GR_sto(jj,:)=det.GZ_sto;
            end
            %% verification interpolation
            if meta.verif
                parfor jj=1:size(tirages,1)
                    [Zverif(jj),G]=eval_krg_ckrg(tirages(jj,:),meta_donnee);
                    GZverif(jj,:)=G;
                end
                
                diffZ=Zverif-eval;
                if ~isempty(find(diffZ>1e-7,1))
                    fprintf('Pb d''interpolation (eval) KRG\n')
                    fprintf('DiffZ \t\t||Eval\t\t||Zverif\n');
                    conc=vertcat(diffZ',eval',Zverif');
                    fprintf('%4.2e\t||%4.2e\t||%4.2e\n',conc(:))
                end
                
                if meta_donnee.in.pres_grad
                    diffGZ=GZverif-grad;
                    if ~isempty(find(diffGZ>1e-7, 1))
                        fprintf('Pb d''interpolation (grad) KRG\n')
                        tt=repmat('\t\t',1,nb_var);
                        fprintf(['DiffGZ' tt '||Grad' tt '||GZverif\n']);
                        conc=vertcat(diffGZ',grad',GZverif');
                        tt=repmat('%4.2e\t',1,nb_var);
                        tt=[tt '||' tt '||' tt '\n'];
                        fprintf(tt,conc(:))
                        
                    end
                    diffNG=sqrt(sum(GZverif.^2,2))-sqrt(sum(grad.^2,2));
                    if ~isempty(find(diffNG>1e-7, 1))
                        fprintf('Pb d''interpolation (grad) KRG\n')
                        fprintf('DiffNG\n')
                        fprintf('%4.2e\n',diffNG)
                    end
                end
            end
            
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
            
        case 'DACE'
            %% Evaluation du metamodele de Krigeage (DACE)
            for jj=1:nb_ev_pts
                [rep(jj),G,var_rep(jj)]=predictor(ev_pts(jj,:),meta_donnee.model);
                GR(jj,:)=G;
            end
            %% verification interpolation
            if meta.verif
                parfor jj=1:size(tirages,1)
                    [Zverif(jj),G]=predictor(tirages(jj,:),meta_donnee.model);
                    GZverif(jj,:)=G;
                end
                
                diffZ=Zverif-eval;
                if ~isempty(find(diffZ>1e-7,1))
                    fprintf('Pb d''interpolation (eval) DACE\n')
                    fprintf('DiffZ \t\t||Eval\t\t||Zverif\n');
                    conc=vertcat(diffZ',eval',Zverif');
                    fprintf('%4.2e\t||%4.2e\t||%4.2e\n',conc(:))
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            for degre=meta.deg
                %% Evaluation du metamodele de Regression
                parfor jj=1:nb_ev_pts
                    rep(jj)=eval_prg(meta_donnee.prg.coef,ev_pts(jj,1),points(jj,2),meta_donnee);
                    %evaluation des gradients du MT
                    [GRG1,GRG2]=evald_prg(meta_donnee.prg.coef,ev_pts(jj,1),points(jj,2),meta_donnee);
                    GR(jj,:)=[GRG1,GRG2];
                end
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILIN'
            %% interpolation par fonction de base lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base lin�aire' textf]);
            parfor jj=1:nb_ev_pts
                [rep(jj),G]=interp_lin(ev_pts(jj,:),meta_donnee);
                GR1(jj,:)=G;
                
            end
            
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILAG'
            %% interpolation par fonction polynomiale de Lagrange
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            parfor jj=1:nb_ev_pts
                [rep(jj),G]=interp_lag(ev_pts(jj,:),meta_donnee);
                GR1(jj,:)=G;
                
            end
            
    end
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    % calcul des criteres d'enrichissement
    explor_EI=[];
    exploit_EI=[];
    ei=[];
    wei=[];
    gei=[];
    lcb=[];
    if meta.enrich.on&&exist('var_rep','var')
        %reponse mini
        eval_min=min(meta_donnee.eval);
        %calcul criteres enrichissement
        [ei,wei,gei,lcb,exploit_EI,explor_EI]=crit_enrich(eval_min,rep,var_rep,meta.enrich);
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
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %%%%%%%%=================================%%%%%%%%
    %Stockage des evaluations
    if numel(donnees_const)==1
        if nb_var>1
            if dim_ev(3)==1
                if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                    Z.Z_sto=Z_sto;
                    Z.Z_reg=Z_reg;
                end
                Z.Z=rep;
                if ~isempty(var_rep);Z.var=var_rep;end
                if exist('wei','var');if ~isempty(wei);Z.wei=wei;end, end
                if exist('ei','var');if ~isempty(ei);Z.ei=ei;end, end
                if exist('gei','var');if ~isempty(gei);Z.gei=gei;end, end
                if exist('lcb','var');if ~isempty(lcb);Z.lcb=lcb;end, end
                if exist('explor_EI','var');if ~isempty(explor_EI);Z.explor_EI=explor_EI;end, end
                if exist('exploit_EI','var');if ~isempty(exploit_EI);Z.exploit_EI=exploit_EI;end, end
            else
                if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                    Z.Z_sto=reshape(Z_sto,dim_ev(1),dim_ev(2));
                    Z.Z_reg=reshape(Z_reg,dim_ev(1),dim_ev(2));
                end
                Z.Z=reshape(rep,dim_ev(1),dim_ev(2));
                if ~isempty(var_rep);Z.var=reshape(var_rep,dim_ev(1),dim_ev(2));end
                if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,dim_ev(1),dim_ev(2),size(wei,3));end, end
                if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,dim_ev(1),dim_ev(2));end, end
                if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,dim_ev(1),dim_ev(2),size(gei,3));end, end
                if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,dim_ev(1),dim_ev(2));end, end
                if exist('explor_EI','var');if ~isempty(explor_EI);Z.explor_EI=reshape(explor_EI,dim_ev(1),dim_ev(2));end, end
                if exist('exploit_EI','var');if ~isempty(exploit_EI);Z.exploit_EI=reshape(exploit_EI,dim_ev(1),dim_ev(2));end, end
            end
        else
            if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
                Z.Z_sto=reshape(Z_sto,dim_ev(1),dim_ev(2));
                Z.Z_reg=reshape(Z_reg,dim_ev(1),dim_ev(2));
            end
            Z.Z=reshape(rep,dim_ev(1),dim_ev(2));
            if ~isempty(var_rep);Z.var=reshape(var_rep,dim_ev(1),dim_ev(2));end
            if exist('wei','var');if ~isempty(wei);Z.wei=reshape(wei,dim_ev(1),dim_ev(2),size(wei,3));end, end
            if exist('ei','var');if ~isempty(ei);Z.ei=reshape(ei,dim_ev(1),dim_ev(2));end, end
            if exist('gei','var');if ~isempty(gei);Z.gei=reshape(gei,dim_ev(1),dim_ev(2),size(gei,3));end, end
            if exist('lcb','var');if ~isempty(lcb);Z.lcb=reshape(lcb,dim_ev(1),dim_ev(2));end, end
            if exist('explor_EI','var');if ~isempty(explor_EI);Z.explor_EI=reshape(explor_EI,dim_ev(1),dim_ev(2));end, end
            if exist('exploit_EI','var');if ~isempty(exploit_EI);Z.exploit_EI=reshape(exploit_EI,dim_ev(1),dim_ev(2));end, end
        end
        Z.GZ=GZ;
        if exist('GZ_sto','var')==1&&exist('GZ_reg','var')==1
            Z.GZ_sto=GZ_sto;Z.GZ_reg=GZ_reg;
        end
    else
        Z{num_meta}.Z=rep;
        Z{num_meta}.GZ=GZ;
        if ~isempty('var_rep');Z{num_meta}.var=var_rep;end
        if exist('wei','var');if ~isempty(wei);Z{num_meta}.wei=reshape(wei,dim_ev(1),dim_ev(2),size(wei,3));end, end
        if exist('gei','var');if ~isempty(gei);Z{num_meta}.gei=reshape(gei,dim_ev(1),dim_ev(2),size(gei,3));end, end
        if exist('ei','var');if ~isempty(ei);Z{num_meta}.ei=reshape(ei,dim_ev(1),dim_ev(2));end, end
        if exist('lcb','var');if ~isempty(lcb);Z{num_meta}.lcb=reshape(lcb,dim_ev(1),dim_ev(2));end, end
        if exist('explor_EI','var');if ~isempty(explor_EI);Z{num_meta}.explor_EI=reshape(explor_EI,dim_ev(1),dim_ev(2));end, end
        if exist('exploit_EI','var');if ~isempty(exploit_EI);Z{num_meta}.exploit_EI=reshape(exploit_EI,dim_ev(1),dim_ev(2));end, end
        if exist('GZ_sto','var')==1&&exist('GZ_reg','var')==1
            Z{num_meta}.GZ_sto=GZ_sto;Z{num_meta}.GZ_reg=GZ_reg;
        end
        if exist('Z_sto','var')==1&&exist('Z_reg','var')==1
            Z{num_meta}.Z_sto=Z_sto;Z{num_meta}.Z_reg=Z_reg;
        end
    end
end

if nb_ev_pts>1&&verb
    fprintf('++ Evaluation en %i points\n',nb_ev_pts);
    mesu_time(tMesu,tInit);
    fprintf('#########################################\n');
end