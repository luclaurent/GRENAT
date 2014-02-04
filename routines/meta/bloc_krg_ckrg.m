%% Construction des blocs du Krigeage
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr


function [lilog,ret]=bloc_krg_ckrg(donnees,meta,para)

%coefficient de reconditionnement
coef=(10+size(donnees.build.fct,1))*eps;
% type de factorisation de la matrice de correlation
if strcmp(meta.type,'CKRG')
    fact_rcc='LU';
else
    fact_rcc='LU' ; %LU %QR %LL %None
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement grandeurs utiles
nb_val=donnees.in.nb_val;
nb_var=donnees.in.nb_var;
tiragesn=donnees.in.tiragesn;
fct_corr=meta.corr;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para defini alors on charge cette nouvelle valeur
final=false;
if nargin==3
    para_val=para;
else
    para_val=meta.para.val;
    final=true;
end
ret=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creation matrice de correlation
if donnees.in.pres_grad
    %si parallelisme actif ou non
    if meta.worker_parallel>=2
        %%%%%% PARALLEL %%%%%%
        %morceaux de la matrice GKRG
        rc=zeros(nb_val,nb_val);
        rca=cell(1,nb_val);
        rci=cell(1,nb_val);
        parfor ii=1:nb_val
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=one_tir(ones(1,nb_val),:)-tiragesn;
            % evaluation de la fonction de correlation
            [ev,dev,ddev]=feval(fct_corr,dist,para_val);
            %morceau de la matrice issue du modele KRG classique
            rc(:,ii)=ev;
            %morceau des derivees premieres
            rca{ii}=dev;
            %matrice des derivees secondes
            rci{ii}=-reshape(ddev,nb_var,nb_val*nb_var);
        end
        %%construction des matrices completes
        rcaC=horzcat(rca{:});
        rciC=vertcat(rci{:});
        %Matrice de complete
        rcc=[rc rcaC;rcaC' rciC];
    else

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %evaluation de la fonction de correlation pour les differents
        %intersites
        [ev,dev,ddev]=feval(fct_corr,donnees.in.dist,para_val);        
        
        %morceau de la matrice issu du krigeage
        rc=zeros(nb_val,nb_val);
        rca=zeros(nb_val,nb_var*nb_val);
        rci=zeros(nb_val*nb_var,nb_val*nb_var);
        
        rc(donnees.ind.matrix)=ev;
        rc=rc+rc'-eye(donnees.in.nb_val);
        
        rca(donnees.ind.matrixA)=dev(donnees.ind.dev);
        rca(donnees.ind.matrixAb)=-dev(donnees.ind.devb);
        rci(donnees.ind.matrixI)=-ddev(:);
        %extraction de la diagonale (procedure pour eviter les doublons)
        diago=0;   % //!!\\ corrections envisageables ici
        val_diag=spdiags(rci,diago);
        rci=rci+rci'-spdiags(val_diag,diago,zeros(size(rci))); %correction termes diagonaux pour eviter les doublons

        %Matrice de correlation du Cokrigeage
        rcc=[rc rca;rca' rci];
    end
    %si donnees manquantes
    if donnees.manq.eval.on
        rcc(donnees.manq.eval.ix_manq,:)=[];
        rcc(:,donnees.manq.eval.ix_manq)=[];
    end
    
    %si donnees manquantes
    if donnees.manq.grad.on
        rep_ev=nb_val-donnees.manq.eval.nb;
        rcc(rep_ev+donnees.manq.grad.ixt_manq_line,:)=[];
        rcc(:,rep_ev+donnees.manq.grad.ixt_manq_line)=[];
    end
else
    
    if meta.worker_parallel>=2
        %%%%%% PARALLEL %%%%%%
        %matrice de KRG classique par bloc
        rcc=zeros(nb_val,nb_val);
        parfor ii=1:nb_val
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=one_tir(ones(1,nb_val),:)-tiragesn;
            % evaluation de la fonction de correlation
            [ev]=feval(fct_corr,dist,para_val);
            %morceau de la matrice issue du modele RBF classique
            rcc(:,ii)=ev;
        end
    else        
        %matrice de correlation du Krigeage par matrice triangulaire inferieure
        %sans diagonale
        rcc=zeros(nb_val,nb_val);
        % evaluation de la fonction de correlation        
        [ev]=feval(fct_corr,donnees.in.dist,para_val);
        rcc(donnees.ind.matrix)=ev;
        %Construction matrice complete
        rcc=rcc+rcc'+eye(nb_val);
    end
    %toc
    %si donnees manquantes
    if donnees.manq.eval.on
        rcc(donnees.manq.eval.ix_manq,:)=[];
        rcc(:,donnees.manq.eval.ix_manq)=[];
    end
end

%passage en sparse
%rcc=sparse(rcc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%amelioration du conditionnement de la matrice de correlation
if meta.recond
    %cond_orig=condest(rcc);
    rcc=rcc+coef*speye(size(rcc));
    %cond_new=condest(rcc);
    %fprintf('>>> Amelioration conditionnement: \n%g >> %g  <<<\n',...
    %    cond_orig,cond_new);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conditionnement de la matrice de correlation
if final   %en phase de construction
    cond_new=condest(rcc);
    fprintf('Conditionnement R: %6.5e\n',cond_new)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%approche factorisee
switch fact_rcc
    case 'QR'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %factorisation QR de la matrice de covariance
        [Qrcc,Rrcc,Prcc]=qr(rcc);
        Qtrcc=Qrcc';
        yQ=Qtrcc*donnees.build.y;
        fctQ=Qtrcc*donnees.build.fct;
        fcR=donnees.build.fc*Prcc/Rrcc;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        fcCfct=fcR*fctQ;
        block2=fcR*yQ;
        beta=fcCfct\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        gamma=Prcc*(Rrcc\(yQ-fctQ*beta));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %sauvegarde variables
        build_data.yQ=yQ;
        build_data.fctQ=fctQ;
        build_data.fcR=fcR;
        build_data.fcCfct=fcCfct;
        build_data.Rrcc=Rrcc;
        build_data.Qrcc=Qrcc;
        build_data.Qtrcc=Qtrcc;
        build_data.Prcc=Prcc;
        
    case 'LU'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %factorisation LU de la matrice de covariance
        [Lrcc,Urcc,Prcc]=lu(rcc,'vector');
        yP=donnees.build.y(Prcc,:);
        fctP=donnees.build.fct(Prcc,:);
        yL=Lrcc\yP;
        fctL=Lrcc\fctP;
        fcU=donnees.build.fc/Urcc;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        fcCfct=fcU*fctL;
        block2=fcU*yL;
        beta=fcCfct\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        gamma=Urcc\(yL-fctL*beta);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %sauvegarde variables
        build_data.yL=yL;
        build_data.fcU=fcU;
        build_data.fctL=fctL;
        build_data.fcCfct=fcCfct;
        build_data.Lrcc=Lrcc;
        build_data.Urcc=Urcc;
        build_data.Prcc=Prcc;
    case 'LL'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %factorisation Cholesky de la matrice de covariance
        %%% A debugguer
        Lrcc=chol(rcc,'lower');
        Ltrcc=Lrcc';
        yL=Lrcc\donnees.build.y;
        fctL=Lrcc\donnees.build.fct;
        fcL=donnees.build.fc/Ltrcc;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        fcCfct=fcL*fctL;
        block2=fcL*yL;
        beta=fcCfct\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        gamma=Ltrcc\(yL-fctL*beta);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %sauvegarde variables
        build_data.yL=yL;
        build_data.fcL=fcL;
        build_data.fctL=fctL;
        build_data.fcCfct=fcCfct;
        build_data.Ltrcc=Ltrcc;
        build_data.Lrcc=Lrcc;
    otherwise
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul des coefficients beta et gamma
        %%approche classique
        fcC=donnees.build.fc/rcc;
        fcCfct=fcC*donnees.build.fct;
        block2=((donnees.build.fc/rcc)*donnees.build.y);
        beta=fcCfct\block2;
        gamma=rcc\(donnees.build.y-donnees.build.fct*beta);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %sauvegarde variables
        build_data.fcC=fcC;
        build_data.fcCfct=fcCfct;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde de donnees
if exist('cond_orig','var');build_data.cond_orig=cond_orig;end
if exist('cond_new','var');build_data.cond_new=cond_new;end

build_data.beta=beta;
build_data.gamma=gamma;
build_data.rcc=rcc;
build_data.deg=meta.deg;
build_data.para=meta.para;
build_data.fact_rcc=fact_rcc;
ret.build=build_data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%variance de prediction
ret.build.sig2=1/size(rcc,1)*...
    ((donnees.build.y-donnees.build.fct*ret.build.beta)'*ret.build.gamma);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Maximum de vraisemblance
[ret.lilog,ret.li]=likelihood(ret);
lilog=ret.lilog;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%denormalisation sigma^2
if meta.norm&&~isempty(donnees.norm.std_eval)
    ret.build.sig2=ret.build.sig2*donnees.norm.std_eval^2;
else
    ret.build.sig2=ret.build.sig2;
end


