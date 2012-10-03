%% Construction des blocs du Krigeage
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr


function [lilog,ret]=bloc_krg_ckrg(donnees,meta,para)

%coefficient de reconditionnement
coef=10^-6;
% type de factorisation de la matrice de correlation
fact_rcc='QR' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement grandeurs utiles
nb_val=data.in.nb_val;
nb_var=data.in.nb_var;
tiragesn=data.in.tiragesn;
fct_corr=meta.corr;
para_val=meta.para.val;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para defini alors on charge cette nouvelle valeur
if nargin==3
    meta.para.val=para;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creation matrice de correlation
if donnees.in.pres_grad
    %si parallelisme actif ou non    
    if matlabpool('size')>=2
        %%%%%% PARALLEL %%%%%%
        %morceaux de la matrice GRBF
        rc=zeros(nb_val,nb_val);
        rca=cell(1,nb_val);
        rci=cell(1,nb_val);
        parfor ii=1:nb_val
             %distance 1 tirages aux autres (construction par colonne)
            dist=repmat(tiragesn(ii,:),nb_val,1)-tirages;
            % evaluation de la fonction de correlation
            [ev,dev,ddev]=feval(fct_corr,dist,para_val);
            %morceau de la matrice issue du modele RBF classique
            rc(:,ii)=ev;
            %morceau des derivees premieres
            %KKa(:,(ii-1)*nb_var+1:ii*nb_var)=dev;
            rca{ii}=dev;
            %matrice des derivees secondes
            rci{ii}=-reshape(ddev,nb_var,nb_val*nb_var);
        end
        %%construction des matrices completes
        rcaC=horzcat(rca{:});
        rciC=vertcat(rci{:});
        %Matrice de complete
        rcc=[rc rcaC;-rcaC' rciC];
    else
        %morceau de la matrice issu du krigeage
        rc=zeros(nb_val,nb_val);
        rca=zeros(nb_val,nb_var*nb_val);
        rci=zeros(nb_val*nb_var,nb_val*nb_var);

        for ii=1:jnb_val
            ind=ii:nb_val;
            indd=(ii-1)*nb_var+1:nb_val*nb_var;
            inddd=nb_val-numel(ind)+1:nb_val;
            indddd=(ii-1)*nb_var+1:ii*nb_var;
            %distance 1 tirages aux autres (construction par colonne)
            dist=repmat(tiragesn(ii,:),numel(ind),1)-tiragesn(ind,:);
            % evaluation de la fonction de correlation
            [ev,dev,ddev]=feval(fct_corr,dist,meta.para.val);
            %morceau de la matrice issue du krigeage
            rc(ind,ii)=ev;
            %morceau de la matrice provenant du Cokrigeage
            rca(ii,indd)=-reshape(dev',1,numel(ind)*nb_var);
            rca(inddd,indddd)=dev;
            %matrice des derivees secondes
            rci(nb_var*(ii-1)+1:nb_var*ii,indd)=...
                -reshape(ddev,nb_var,numel(ind)*nb_var);
            % reshape(ddev,donnees.in.nb_var,numel(ind)*donnees.in.nb_var)

        end
        %construction matrices completes
        rc=rc+rc'-eye(donnees.in.nb_val);
        %extraction de la diagonale (procedure pour eviter les doublons)
        diago=0;   % //!!\\ corrections envisageables ici
        val_diag=spdiags(rci,diago);
        %full(spdiags(val_diag./2,diago,zeros(size(rci))))
        rci=rci+rci'-spdiags(val_diag,diago,zeros(size(rci))); %correction termes diagonaux pour eviter les doublons
        %rci
        %Matrice de correlation du Cokrigeage
        rcc=[rc rca;rca' rci];
        
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
    end
    
else
    %matrice de correlation du Krigeage par matrice triangulaire inferieure
    %sans diagonale
    rcc=zeros(nb_val,nb_val);
    bmax=nb_val-1;
    for ii=1:bmax
        ind=ii+1:nb_val;
        %distance 1 tirages aux autres (construction par colonne)
        dist=repmat(tiragesn(ii,:),numel(ind),1)-tiragesn(ind,:);
        % evaluation de la fonction de correlation
        [ev]=feval(fct_corr,dist,meta.para.val);
        % matrice de krigeage
        rcc(ind,ii)=ev;
    end
    %Construction matrice complete
    rcc=rcc+rcc'+eye(nb_val);
    %si donnees manquantes
    if donnees.manq.eval.on
        rcc(donnees.manq.eval.ix_manq,:)=[];
        rcc(:,donnees.manq.eval.ix_manq)=[];
    end
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
        ret.build.fctCfc=(donnees.build.fc\L)*(U/donnees.build.fct);
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
        %%% A debugguer
        L=chol(rcc,'lower');
        ret.build.Lrcc=L;
        ret.build.yL=L\donnees.build.y;
        ret.build.fcL=L\donnees.build.fc;
        ret.build.fctL=donnees.build.fct/L;
        ret.build.fctCfc=(donnees.build.fc\L)*(L/donnees.build.fct);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=ret.build.fctL*ret.build.fcL;
        block2=ret.build.fctL*ret.build.yL;
        ret.build.beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        ret.build.gamma=L\(ret.build.yL-ret.build.fcL*ret.build.beta);
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=((donnees.build.fct/rcc)*donnees.build.fc);
        block2=((donnees.build.fct/rcc)*donnees.build.y);
        ret.build.beta=block1\block2;
        ret.build.fctCfc=(donnees.build.fc\rcc)/donnees.build.fct;
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






