%% Construction des blocs du Krigeage
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr


function [lilog,ret]=bloc_krg_ckrg(donnees,meta,para)

%coefficient de reconditionnement
coef=10^-6;
% type de factorisation de la matrice de corr�lation
fact_rcc='QR' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para d�fini alors on charge cette nouvelle valeur
if nargin==3
    meta.para.val=para;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creation matrice de correlation
if donnees.in.pres_grad
    %morceau de la matrice issu du krigeage
    rc=zeros(donnees.in.nb_val,donnees.in.nb_val);
    rca=zeros(donnees.in.nb_val,donnees.in.nb_var*donnees.in.nb_val);
    rci=zeros(donnees.in.nb_val*donnees.in.nb_var,donnees.in.nb_val*donnees.in.nb_var);    
    
    for ii=1:donnees.in.nb_val
        ind=ii:donnees.in.nb_val;
        indd=(ii-1)*donnees.in.nb_var+1:donnees.in.nb_val*donnees.in.nb_var;
        inddd=donnees.in.nb_val-numel(ind)+1:donnees.in.nb_val;
        indddd=(ii-1)*donnees.in.nb_var+1:ii*donnees.in.nb_var;
        %distance 1 tirages aux autres (construction par colonne)
        dist=repmat(donnees.in.tiragesn(ii,:),numel(ind),1)-donnees.in.tiragesn(ind,:);
        % evaluation de la fonction de correlation
        [ev,dev,ddev]=feval(meta.corr,dist,meta.para.val);
        %morceau de la matrice issue du krigeage
        rc(ind,ii)=ev;
        %morceau de la matrice provenant du Cokrigeage
        rca(ii,indd)=-reshape(dev',1,numel(ind)*donnees.in.nb_var);
        rca(inddd,indddd)=dev;
        %matrice des derivees secondes         
        rci(donnees.in.nb_var*(ii-1)+1:donnees.in.nb_var*ii,indd)=...
             -reshape(ddev,donnees.in.nb_var,numel(ind)*donnees.in.nb_var);
        % reshape(ddev,donnees.in.nb_var,numel(ind)*donnees.in.nb_var)

    end
    %construction matrices completes
    rc=rc+rc'-eye(donnees.in.nb_val);
    %extraction de la diagonale (procédure pour eviter les doublons)
    diago=0;   % //!!\\ corrections envisageables ici
    val_diag=spdiags(rci,diago);
    %full(spdiags(val_diag./2,diago,zeros(size(rci))))
    rci=rci+rci'-spdiags(val_diag,diago,zeros(size(rci))); %correction termes diagonaux pour eviter les doublons
    %rci
    %Matrice de correlation du Cokrigeage
    rcc=[rc rca;rca' rci]; 
else
    %matrice de correlation du Krigeage par matrice triangulaire inf�rieure
    %sans diagonale
    rcc=zeros(donnees.in.nb_val,donnees.in.nb_val);
    bmax=donnees.in.nb_val-1;
    for ii=1:bmax
        ind=ii+1:donnees.in.nb_val;
        %distance 1 tirages aux autres (construction par colonne)
        dist=repmat(donnees.in.tiragesn(ii,:),numel(ind),1)-donnees.in.tiragesn(ind,:);
        % evaluation de la fonction de correlation
        [ev]=feval(meta.corr,dist,meta.para.val);
        % matrice de krigeage
        rcc(ind,ii)=ev;
    end
        %Construction matrice compl�te
    rcc=rcc+rcc'+eye(donnees.in.nb_val);   
    
end
%passage en sparse
rcc=sparse(rcc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%amelioration du conditionnement de la matrice de corr�lation
if meta.recond
    ret.build.cond_orig=condest(rcc);
    if ret.build.cond_orig>10^13
        cond_old=ret.build.cond_orig;
        rcc=rcc+coef*speye(size(rcc));
        ret.build.cond=condest(rcc);
        fprintf('>>> Amelioration conditionnement: \n%g >> %g  <<<\n',...
            cond_old,ret.build.cond_orig);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conditionnement de la matrice de correlation
if nargin==2   %en phase de construction
    ret.cond=condest(rcc);
    fprintf('Conditionnement R: %6.5d\n',ret.cond)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%approche factorisee
%attention cette factorisation n'est possible que sous condition
%QR
switch fact_rcc
    case 'QR'
        [Q,R]=qr(rcc);
        ret.build.Qrcc=Q;
        ret.build.Rrcc=R;
        ret.build.yQ=Q'*donnees.build.y;
        ret.build.fcQ=Q'*donnees.build.fc;
        ret.build.fctR=donnees.build.fct/R;
        ret.build.fctCfc=(donnees.build.fc\Q)*(R/donnees.build.fct);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=ret.build.fctR*ret.build.fcQ;
        block2=ret.build.fctR* ret.build.yQ;
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=R\(ret.build.yQ-ret.build.fcQ*ret.build.beta);
    case 'LU'
        [L,U]=lu(rcc);
        ret.build.Lrcc=L;
        ret.build.Urcc=U;
        ret.build.yL=L\donnees.build.y;
        ret.build.fcL=L\donnees.build.fc;
        ret.build.fctU=donnees.build.fct/U;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=ret.build.fctU*ret.build.fcL;
        block2=ret.build.fctU* ret.build.yL;
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=U\(ret.build.yL-ret.build.fcL*ret.build.beta);
     case 'LL'
         %%% A coder
        L=chol(rcc,'lower');
        ret.build.Lrcc=L;
        ret.build.yL=L\donnees.build.y;
        ret.build.fcL=L\donnees.build.fc;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=ret.build.fctU*ret.build.fcL;
        block2=ret.build.fctU*ret.build.yL;
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=U\(ret.build.yL-ret.build.fcL*ret.build.beta);
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=((donnees.build.fct/rcc)*donnees.build.fc);
        block2=((donnees.build.fct/rcc)*donnees.build.y);
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=rcc\(donnees.build.y-donnees.build.fc*ret.build.beta);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde de donnees
ret.build.rcc=rcc;
ret.build.deg=meta.deg;
ret.build.para=meta.para;
ret.build.fact_rcc=fact_rcc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%variance de prediction
sig2=1/size(rcc,1)*...
    ((donnees.build.y-donnees.build.fc*ret.build.beta)'*ret.build.gamma);
if meta.norm&&~isempty(donnees.norm.std_eval)
    ret.build.sig2=sig2*donnees.norm.std_eval^2;
else
    ret.build.sig2=sig2;
end

%Maximum de vraisemblance
[ret.lilog,ret.li]=likelihood(ret);
lilog=ret.lilog;


%Dans la phase de minimisation de la log vraisemblance
% if nargin==7
%     if abs(lilog)==Inf
%         theta_save=meta.theta;
%         global theta_save
%         me.message='valeur log-vraisemblance incompatible';
%         error(me);
%     end
% end
%%%%%%%%%%%%%%%%%%






