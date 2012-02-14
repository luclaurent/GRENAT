%% Construction des blocs du Krigeage
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr


function [lilog,ret]=bloc_krg_ckrg(donnees,meta,para)

%coefficient de reconditionnement
coef=10^-6;
% type de factorisation de la matrice de corrélation
fact_rcc='LU' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para défini alors on charge cette nouvelle valeur
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
    end
    %construction matrices complètes
    rc=rc+rc'-eye(donnees.in.nb_val);
    diago=[-donnees.in.nb_var+1:donnees.in.nb_var-1];
    rci=rci+spdiags(zeros(donnees.in.nb_val*donnees.in.nb_var,numel(diago)),diago,rci'); %suppression termes diagonaux pour eviter les doublons
    %Matrice de correlation du Cokrigeage
    rcc=[rc rca;rca' rci];    
else
    %matrice de correlation du Krigeage par matrice triangulaire inférieure
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
    %Construction matrice complète
    rcc=rcc+rcc'+eye(donnees.in.nb_val);    
end
%passage en sparse
rcc=sparse(rcc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%amelioration du conditionnement de la matrice de corrï¿½lation
if meta.recond
    ret.build.cond_orig=cond(rcc);
    rcc=rcc+coef*eye(size(rcc));
    ret.build.cond=cond(rcc);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conditionnement de la matrice de correlation
if nargin==2   %en phase de construction
    ret.cond=cond(rcc);
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
        donnees.build.yQ=Q'*donnees.build.y;
        donnees.build.fcQ=Q'*donnees.build.fc;
        donnees.build.fctR=donnees.build.fct/R;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=donnees.build.fctR*donnees.build.fcQ;
        block2=donnees.build.fctR* donnees.build.yQ;
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=R\(donnees.build.yQ-donnees.build.fcQ*ret.build.beta);
    case 'LU'
        [L,U]=lu(rcc);
        donnees.build.yL=L\donnees.build.y;
        donnees.build.fcL=L\donnees.build.fc;
        donnees.build.fctU=donnees.build.fct/U;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=donnees.build.fctU*donnees.build.fcL;
        block2=donnees.build.fctU* donnees.build.yL;
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=U\(donnees.build.yL-donnees.build.fcL*ret.build.beta);
     case 'LL'
        R=chol(rcc);
        donnees.build.yL=L\donnees.build.y;
        donnees.build.fcL=L\donnees.build.fc;
        donnees.build.fctU=donnees.build.fct/U;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=donnees.build.fctU*donnees.build.fcL;
        block2=donnees.build.fctU* donnees.build.yL;
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=U\(donnees.build.yL-donnees.build.fcL*ret.build.beta);
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






