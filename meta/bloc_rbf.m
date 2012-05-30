%% Procedure de construction de la matrice RBF et de calcul de la validation crois�e
%% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function [crit_min,ret]=bloc_rbf(data,meta,para)

% fonction a minimiser pour trouver jeu de parametres
fct_min='loot'; %msep/msemix
%coefficient de reconditionnement
coef=10^-6;
% type de factorisation de la matrice de correlation
fact_KK='None' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para defini alors on charge cette nouvelle valeur
if nargin==3
    meta.para.val=para;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construction de la matrice de Gram
if data.in.pres_grad
    %morceaux de la matrice GRBF
    KK=zeros(data.in.nb_val,data.in.nb_val);
    KKa=zeros(data.in.nb_val,data.in.nb_var*data.in.nb_val);
    KKi=zeros(data.in.nb_val*data.in.nb_var,data.in.nb_val*data.in.nb_var);
    
    for ii=1:data.in.nb_val
        ind=ii:data.in.nb_val;
        indd=(ii-1)*data.in.nb_var+1:data.in.nb_val*data.in.nb_var;
        inddd=data.in.nb_val-numel(ind)+1:data.in.nb_val;
        indddd=(ii-1)*data.in.nb_var+1:ii*data.in.nb_var;
        %distance 1 tirages aux autres (construction par colonne)
        dist=data.in.tiragesn(ind,:)-repmat(data.in.tiragesn(ii,:),numel(ind),1);
        % evaluation de la fonction de correlation
        [ev,dev,ddev]=feval(meta.fct,dist,meta.para.val);
        %morceau de la matrice issue du modele RBF classique
        KK(ind,ii)=ev;
        %morceau des derivees premiers
        KKa(inddd,indddd)=dev;
        KKa(ii,indd)=-reshape(dev',1,numel(ind)*data.in.nb_var);
        
        %matrice des derivees secondes
        KKi(indddd,indd)=...
            reshape(ddev,data.in.nb_var,numel(ind)*data.in.nb_var);

    end
    %construction matrices completes
    KK=KK+KK'-eye(data.in.nb_val);
    %extraction de la diagonale (procedure pour eviter les doublons)
    diago=0;   % //!!\\ corrections envisageables ici
    val_diag=spdiags(KKi,diago);
    %full(spdiags(val_diag./2,diago,zeros(size(rci))))
    KKi=KKi+KKi'-spdiags(val_diag,diago,zeros(size(KKi))); %correction termes diagonaux pour eviter les doublons
    %Matrice de complete
    KK=[KK KKa;KKa KKi];
    
    
else
    %matrice de RBF classique par matrice triangulaire inferieure
    %sans diagonale
    KK=zeros(data.in.nb_val,data.in.nb_val);
    bmax=data.in.nb_val-1;
    for ii=1:bmax
        ind=ii+1:data.in.nb_val;
        %distance 1 tirages aux autres (construction par colonne)
        dist=repmat(data.in.tiragesn(ii,:),numel(ind),1)-data.in.tiragesn(ind,:);
        % evaluation de la fonction de correlation
        [ev]=feval(meta.fct,dist,meta.para.val);
        % matrice de RBF
        KK(ind,ii)=ev;
    end
    %Construction matrice complete
    KK=KK+KK'+eye(data.in.nb_val);
end


%passage en sparse
%KK=sparse(KK);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%amelioration du conditionnement de la matrice de correlation
if meta.recond
    ret.build.cond_orig=condest(KK);
    if ret.build.cond_orig>10^13
        cond_old=ret.build.cond_orig;
        KK=KK+coef*speye(size(KK));
        ret.build.cond=condest(KK);
        fprintf('>>> Amelioration conditionnement: \n%g >> %g  <<<\n',...
            cond_old,ret.build.cond);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conditionnement de la matrice de correlation
if nargin==2   %en phase de construction
    ret.cond=condest(KK);
    fprintf('Conditionnement R: %6.5d\n',ret.cond)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%approche factorisee
%attention cette factorisation n'est possible que sous condition
%QR
switch fact_KK
    case 'QR'
        [Q,R]=qr(KK);
        ret.build.QKK=Q;
        ret.build.RKK=R;
        ret.build.iKK=R\Q';
        ret.build.yQ=Q'*data.build.y;
        ret.build.w=R\ret.build.yQ;
    case 'LU'
        [L,U]=lu(KK);
        % a �crire
    case 'LL'
        %%% A coder
        L=chol(KK,'lower');
        % a ecrire
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        ret.build.iKK=inv(KK);
        ret.build.w=ret.build.iKK*data.build.y;
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
ret.build.fct=meta.fct;
ret.build.para=meta.para;
ret.build.KK=KK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee (obligatoire pour affinage parametre)
%%%%%Calcul des differentes erreurs
if meta.cv||meta.para.estim
    %tps_stop=toc;
    [cv]=cross_validate_rbf(ret,data,meta);
    %tps_cv=toc;
    %fprintf('Execution validation croisee RBF/HBRBF: %6.4d s\n\n',tps_cv-tps_stop);
    if isfield(cv,fct_min)
        crit_min=cv.(fct_min);
    else
        crit_min=cv.loot;
    end
else
    cv=[];
    crit_min=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ret.cv=cv;

