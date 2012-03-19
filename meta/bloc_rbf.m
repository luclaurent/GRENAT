%% Procï¿½dure de construction de la matrice RBF et de calcul de la validation croisï¿½e
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
    %initialisation matrice
    KK=zeros(data.in.nb_val*(data.in.nb_var+1));
    for ii=1:data.in.nb_val
        for jj=1:data.in.nb_val
            %evaluation de la fonction de base radiale
            [ev,dev,ddev]=feval(meta.fct,data.in.tiragesn(ii,:)-data.in.tiragesn(jj,:),meta.para.val);
            %construction du bloc
            B=[ev,dev;dev',ddev];
            %remplissage matrice de "Gram"
            posi=(ii-1)*(data.in.nb_var+1)+1:ii*(data.in.nb_var+1);
            posj=(jj-1)*(data.in.nb_var+1)+1:jj*(data.in.nb_var+1);
            KK(posi,posj)=B;
        end
    end
else
    KK=zeros(data.in.nb_val);
    for ii=1:data.in.nb_val
        for jj=1:data.in.nb_val
            KK(ii,jj)=feval(meta.fct,data.in.tiragesn(jj,:)-data.in.tiragesn(ii,:),meta.para.val);
        end
    end
end
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
%%%%%Validation croisee
%%%%%Calcul des differentes erreurs
if meta.cv
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
