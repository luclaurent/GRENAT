%% Procedure de construction de la matrice RBF et de calcul de la validation croisee
%% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function [crit_min,ret]=bloc_rbf(data,meta,para,type)

% affichages warning ou non
aff_warning=false;
% fonction a minimiser pour trouver jeu de parametres
fct_min='eloot'; %eloot/eloor/eloog
%coefficient de reconditionnement
coef=10^-6;
% type de factorisation de la matrice de correlation
fact_KK='QR' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement grandeurs utiles
nb_val=data.in.nb_val;
nb_var=data.in.nb_var;
tiragesn=data.in.tiragesn;
fct_rbf=meta.rbf;
ret=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para defini alors on charge cette nouvelle valeur
if nargin>=3
    para_val=para;
    %dans ce cas, on ne calcul que le critere a minimiser (phase
    %estimation)
    type_CV='estim';
else
    para_val=meta.para.val;
    type_CV='final';
end
mod_estim=false;
if nargin==4
    if strcmp(type,'etud');type_CV=type;end
    if strcmp(type,'estim');type_CV=type;mod_estim=true;end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construction de la matrice de Gram
if data.in.pres_grad
    %si parallelisme actif ou non
    if meta.worker_parallel>=2
        %%%%%% PARALLEL %%%%%%
        %morceaux de la matrice GRBF
        KK=zeros(nb_val,nb_val);
        KKa=cell(1,nb_val);
        KKi=cell(1,nb_val);
        
        parfor ii=1:nb_val
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=tiragesn-one_tir(ones(1,nb_val),:);
            % evaluation de la fonction de correlation
            [ev,dev,ddev]=feval(fct_rbf,dist,para_val);
            %morceau de la matrice issue du modele RBF classique
            KK(:,ii)=ev;
            %morceau des derivees premieres
            %KKa(:,(ii-1)*nb_var+1:ii*nb_var)=dev;
            KKa{ii}=dev;
            %matrice des derivees secondes
            KKi{ii}=reshape(ddev,nb_var,nb_val*nb_var);
        end
        %%construction des matrices completes
        KKaC=horzcat(KKa{:});
        KKiC=vertcat(KKi{:});
        %Matrice de complete
        KK=[KK KKaC;-KKaC' KKiC];
    else
        %morceaux de la matrice GRBF
        KK=zeros(nb_val,nb_val);
        KKa=zeros(nb_val,nb_var*nb_val);
        KKat=KKa';
        KKi=zeros(nb_val*nb_var,nb_val*nb_var);
        
        for ii=1:nb_val
            ind=ii:nb_val;
            indd=(ii-1)*nb_var+1:nb_val*nb_var;
            inddd=nb_val-numel(ind)+1:nb_val;
            indddd=(ii-1)*nb_var+1:ii*nb_var;
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=tiragesn(ind,:)-one_tir(ones(1,numel(ind)),:);
            % evaluation de la fonction de correlation
            [ev,dev,ddev]=feval(fct_rbf,dist,para_val);
            %morceau de la matrice issue du modele RBF classique
            KK(ind,ii)=ev;
            %morceau des derivees premiers
            KKa(inddd,indddd)=dev;
            KKa(ii,indd)=-reshape(dev',1,numel(ind)*nb_var);
            KKat(indddd,inddd)=-dev';
            KKat(indd,ii)=reshape(dev',numel(ind)*nb_var,1);
            
            %matrice des derivees secondes
            KKi(indddd,indd)=...
                reshape(ddev,nb_var,numel(ind)*nb_var);
            
        end
        %construction matrices completes
        KK=KK+KK'-eye(nb_val);
        %extraction de la diagonale (procedure pour eviter les doublons)
        diago=0;   % //!!\\ corrections envisageables ici
        val_diag=spdiags(KKi,diago);
        %full(spdiags(val_diag./2,diago,zeros(size(rci))))
        KKi=KKi+KKi'-spdiags(val_diag,diago,zeros(size(KKi))); %correction termes diagonaux pour eviter les doublons
        %Matrice de complete
        KK=[KK KKa;KKat KKi];
    end
    %si donnees manquantes
    if data.manq.eval.on
        KK(data.manq.eval.ix_manq,:)=[];
        KK(:,data.manq.eval.ix_manq)=[];
    end
    
    %si donnees manquantes
    if data.manq.grad.on
        rep_ev=nb_val-data.manq.eval.nb;
        KK(rep_ev+data.manq.grad.ixt_manq_line,:)=[];
        KK(:,rep_ev+data.manq.grad.ixt_manq_line)=[];
    end
    
else
    if meta.worker_parallel>=2
        %%%%%% PARALLEL %%%%%%
        %matrice de RBF classique par bloc
        KK=zeros(nb_val,nb_val);
        parfor ii=1:nb_val
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=tiragesn-one_tir(ones(1,nb_val),:);
            % evaluation de la fonction de correlation
            [ev]=feval(fct_rbf,dist,para_val);
            %morceau de la matrice issue du modele RBF classique
            KK(:,ii)=ev;
        end
    else
        %matrice de RBF classique par matrice triangulaire inferieure
        %sans diagonale
        KK=zeros(nb_val,nb_val);
        bmax=nb_val-1;
        for ii=1:bmax
            ind=ii+1:nb_val;
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=tiragesn(ind,:)-one_tir(ones(1,numel(ind)),:);
            % evaluation de la fonction de correlation
            [ev]=feval(meta.rbf,dist,para_val);
            % matrice de RBF
            KK(ind,ii)=ev;
        end
        %Construction matrice complete
        KK=KK+KK'+eye(nb_val);
        %si donnees manquantes
    end
    if data.manq.eval.on
        KK(data.manq.eval.ix_manq,:)=[];
        KK(:,data.manq.eval.ix_manq)=[];
    end
end


%passage en sparse
%KK=sparse(KK);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%amelioration du conditionnement de la matrice de correlation
if meta.recond
    cond_orig=condest(KK);
    if cond_orig>10^14
        cond_old=cond_orig;
        KK=KK+coef*speye(size(KK));
        cond_new=condest(KK);
        fprintf('>>> Amelioration conditionnement: \n%g >> %g  <<<\n',...
            cond_old,cond_new);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conditionnement de la matrice de correlation
if nargin==2   %en phase de construction
    cond_new=condest(KK);
    fprintf('Conditionnement R: %4.2e\n',cond_new)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%approche factorisee
%attention cette factorisation n'est possible que sous condition
%QR
switch fact_KK
    case 'QR'
        [Q,R]=qr(KK);
        QKK=Q;
        RKK=R;
        iKK=R\Q';
        yQ=Q'*data.build.y;
        w=R\yQ;
    case 'LU'
        [L,U]=lu(KK);
        % a ecrire
    case 'LL'
        %%% A coder
        L=chol(KK,'lower');
        % a ecrire
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        if ~aff_warning; warning off all;end
        iKK=inv(KK);
        if ~aff_warning; warning on all;end
        w=iKK*data.build.y;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
if exist('cond_orig','var');build_data.cond_orig=cond_orig;end
if exist('cond_new','var');build_data.cond_new=cond_new;end
if exist('QKK','var');build_data.QKK=QKK;end
if exist('RKK','var');build_data.RKK=RKK;end
if exist('iKK','var');build_data.iKK=iKK;end
if exist('yQ','var');build_data.yQ=yQ;end
if exist('cond_orig','var');build_data.cond_orig=cond_orig;end
if exist('cond_new','var');build_data.cond_new=cond_new;end
build_data.w=w;
build_data.KK=KK;
build_data.fct=meta.rbf;
build_data.para=meta.para;
ret.build=build_data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee (obligatoire pour affinage parametre)
%%%%%Calcul des differentes erreurs
if meta.cv||meta.para.estim
    %tps_stop=toc;
    [cv]=cross_validate_rbf(ret,data,meta,type_CV);
    %tps_cv=toc;
    %fprintf('Execution validation croisee RBF/HBRBF: %6.4d s\n\n',tps_cv-tps_stop);
    if isfield(cv,fct_min)
        crit_min=cv.(fct_min);
    else
        disp('la')
        crit_min=cv.eloot;
        disp('ici')
    end
else
    cv=[];
    crit_min=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ret.cv=cv;

