%% Procedure de construction de la matrice RBF et de calcul de la validation croisï¿½e
%% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function [msep,ret]=bloc_rbf(data,meta,para)

%coefficient de reconditionnement
coef=10^-6;
% type de factorisation de la matrice de corrï¿½lation
fact_KK='QR' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para dï¿½fini alors on charge cette nouvelle valeur
if nargin==3
    meta.para.val=para;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construction de la matrice de Gram
if data.in.pres_grad
    %morceau de la matrice issu du krigeage
    KK=zeros(data.in.nb_val,data.in.nb_val);
    KKa=zeros(data.in.nb_val,data.in.nb_var*data.in.nb_val);
    KKi=zeros(data.in.nb_val*data.in.nb_var,data.in.nb_val*data.in.nb_var);    
    
    for ii=1:data.in.nb_val
        ind=ii:data.in.nb_val;
        indd=(ii-1)*data.in.nb_var+1:data.in.nb_val*data.in.nb_var;
        inddd=data.in.nb_val-numel(ind)+1:data.in.nb_val;
        indddd=(ii-1)*data.in.nb_var+1:ii*data.in.nb_var;
        %distance 1 tirages aux autres (construction par colonne)
        dist=repmat(data.in.tiragesn(ii,:),numel(ind),1)-data.in.tiragesn(ind,:);
        % evaluation de la fonction de correlation
        [ev,dev,ddev]=feval(meta.fct,dist,meta.para.val);
        %morceau de la matrice issue du krigeage
        KK(ind,ii)=ev;
        %morceau de la matrice provenant du Cokrigeage
        KKa(ii,indd)=reshape(dev',1,numel(ind)*data.in.nb_var);
        KKa(inddd,indddd)=-dev;
        %matrice des derivees secondes         
        KKi(data.in.nb_var*(ii-1)+1:data.in.nb_var*ii,indd)=...
             reshape(ddev,data.in.nb_var,numel(ind)*data.in.nb_var);
        % reshape(ddev,data.in.nb_var,numel(ind)*data.in.nb_var)

    end
    %construction matrices completes
    KK=KK+KK'-eye(data.in.nb_val);
    %extraction de la diagonale (procÃ©dure pour eviter les doublons)
    diago=0;   % //!!\\ corrections envisageables ici
    val_diag=spdiags(KKi,diago);
    %full(spdiags(val_diag./2,diago,zeros(size(rci))))
    KKi=KKi+KKi'-spdiags(val_diag,diago,zeros(size(KKi))); %correction termes diagonaux pour eviter les doublons
    %rci
    %Matrice de correlation du Cokrigeage
    KK=[KK KKa;KKa' KKi];    
else
    %matrice de correlation du Krigeage par matrice triangulaire infï¿½rieure
    %sans diagonale
    KK=zeros(data.in.nb_val,data.in.nb_val);
    bmax=data.in.nb_val-1;
    for ii=1:bmax
        ind=ii+1:data.in.nb_val;
        %distance 1 tirages aux autres (construction par colonne)
        dist=repmat(data.in.tiragesn(ii,:),numel(ind),1)-data.in.tiragesn(ind,:);
        % evaluation de la fonction de correlation
        [ev]=feval(meta.corr,dist,meta.para.val);
        % matrice de krigeage
        KK(ind,ii)=ev;
    end
        %Construction matrice complï¿½te
    KK=KK+KK'+eye(data.in.nb_val);   
    
end

% if data.in.pres_grad
%     %initialisation matrice
%     KK=zeros(data.in.nb_val*(data.in.nb_var+1));
%     for ii=1:data.in.nb_val
%         for jj=1:data.in.nb_val
%             %evaluation de la fonction de base radiale
%             dist=data.in.tiragesn(ii,:)-data.in.tiragesn(jj,:);
%             [ev,dev,ddev]=feval(meta.fct,dist,meta.para.val);
%             %construction du bloc
%             B=[ev,dev;dev',ddev];
%             %remplissage matrice de "Gram"
%             posi=(ii-1)*(data.in.nb_var+1)+1:ii*(data.in.nb_var+1);
%             posj=(jj-1)*(data.in.nb_var+1)+1:jj*(data.in.nb_var+1);
%             KK(posi,posj)=B;
%         end
%     end
% else
%     KK=zeros(data.in.nb_val);
%     for ii=1:data.in.nb_val
%         for jj=1:data.in.nb_val
%             KK(ii,jj)=feval(meta.fct,data.in.tiragesn(jj,:)-data.in.tiragesn(ii,:),meta.para.val);
%         end
%     end
% end
%passage en sparse
KK=sparse(KK);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%amelioration du conditionnement de la matrice de corrï¿½lation
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
        % a écrire
     case 'LL'
         %%% A coder
        L=chol(KK,'lower');
        % a ecrire
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        ret.build.w=KK\data.build.y;
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
ret.build.fct=meta.fct;
ret.build.para=meta.para;
ret.build.KK=KK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee (obligatoire pour affinage paramètre
%%%%%Calcul des differentes erreurs
if meta.cv||meta.para.estim
    %tps_stop=toc;
    [cv]=cross_validate_rbf(ret,data,meta);
    %tps_cv=toc;
    %fprintf('Execution validation croisee RBF/HBRBF: %6.4d s\n\n',tps_cv-tps_stop);
    msep=cv.msep;
else
    cv=[];
    msep=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ret.cv=cv;
