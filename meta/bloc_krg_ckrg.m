%% Construction des blocs du Krigeage
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr


function [lilog,ret]=bloc_krg_ckrg(donnees,meta,para)

%coefficient de reconditionnement
coef=eps;
% type de factorisation de la matrice de correlation
fact_rcc='QR' ; %LU %QR %LL %None
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
        %morceau de la matrice issu du krigeage
        rc=zeros(nb_val,nb_val);
        rca=zeros(nb_val,nb_var*nb_val);
        rci=zeros(nb_val*nb_var,nb_val*nb_var);
        
        for ii=1:nb_val
            ind=ii:nb_val;
            indd=(ii-1)*nb_var+1:nb_val*nb_var;
            inddd=nb_val-numel(ind)+1:nb_val;
            indddd=(ii-1)*nb_var+1:ii*nb_var;
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=one_tir(ones(1,numel(ind)),:)-tiragesn(ind,:);
            % evaluation de la fonction de correlation
            [ev,dev,ddev]=feval(fct_corr,dist,para_val);
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
        bmax=nb_val-1;
        for ii=1:bmax
            ind=ii+1:nb_val;
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=tiragesn(ii,:);
            dist=one_tir(ones(1,numel(ind)),:)-tiragesn(ind,:);            
            % evaluation de la fonction de correlation
            [ev]=feval(fct_corr,dist,para_val);
            % matrice de krigeage
            rcc(ind,ii)=ev;
        end
        %Construction matrice complete
        rcc=rcc+rcc'+eye(nb_val);
    end
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
    cond_orig=condest(rcc);
    if cond_orig>10^14
        cond_old=cond_orig;
        rcc=rcc+coef*speye(size(rcc));
        cond_new=condest(rcc);
        fprintf('>>> Amelioration conditionnement: \n%g >> %g  <<<\n',...
            cond_old,cond_new);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conditionnement de la matrice de correlation
if nargin==2   %en phase de construction
    cond_new=condest(rcc);
    fprintf('Conditionnement R: %6.5d\n',cond_new)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%approche factorisee
%attention cette factorisation n'est possible que sous condition
%QR
switch fact_rcc
    case 'QR'
%          [Q,R]=qr(rcc);
%           Qrcc=Q;
%          Rrcc=R;
%          Qt=Q';
%          tic
%          
%          yQ=Qt*donnees.build.y;
%         fcQ=Qt*donnees.build.fc;
%          fctR=donnees.build.fct/R;
%          fctCfc=(donnees.build.fc\Q)*(R/donnees.build.fct);
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          %calcul du coefficient beta
%          %%approche classique
%          block1=fctR*fcQ;
%          block2=fctR*yQ;
%          betao=block1\block2;
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          %calcul du coefficient gamma
%          gammao=R\(yQ-fcQ*betao);
        
                %% Nouvelle version
        % matrice de krigeage: M=[C X;Xt 0];
        MKrg=[rcc donnees.build.fc;donnees.build.fct zeros(donnees.build.dim_fc)];
        [QMKrg,RMKrg]=qr(MKrg);
        if final
            iMKrg=RMKrg\QMKrg';
            coef_KRG=iMKrg*[donnees.build.y;zeros(donnees.build.dim_fc,1)];
        else
            calc_Q=QMKrg'*[donnees.build.y;zeros(donnees.build.dim_fc,1)];
            coef_KRG=RMKrg\calc_Q;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        beta=coef_KRG((end-donnees.build.dim_fc+1):end);
        gamma=coef_KRG(1:(end-donnees.build.dim_fc));
        
    case 'LU'
        [Lrcc,Urcc]=lu(rcc);
        yL=Lrcc\donnees.build.y;
        fcL=Lrcc\donnees.build.fc;
        fctU=donnees.build.fct/Urcc;
        fctCfc=(donnees.build.fc\Lrcc)*(Urcc/donnees.build.fct);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=fctU*fcL;
        block2=fctU*yL;
        beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        gamma=Urcc\(yL-fcL*beta);
    case 'LL'
        %%% A debugguer
        Lrcc=chol(rcc,'lower');
        yL=Lrcc\donnees.build.y;
        fcL=Lrcc\donnees.build.fc;
        fctL=donnees.build.fct/Lrcc;
        fctCfc=(donnees.build.fc\Lrcc)*(Lrcc/donnees.build.fct);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        block1=fctL*fcL;
        block2=fctL*yL;
        beta=block1\block2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        gamma=Lrcc\(yL-fcL*beta);
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
       % block1=((donnees.build.fct/rcc)*donnees.build.fc);
       % block2=((donnees.build.fct/rcc)*donnees.build.y);
       % betao=block1\block2;
        %  fctCfc=(donnees.build.fc\rcc)/donnees.build.fct;
       % beta
        %% Nouvelle version
        % matrice de krigeage: M=[C X;Xt 0];
        MKrg=[rcc donnees.build.fc;donnees.build.fct zeros(donnees.build.dim_fc)];
        if final
            iMKrg=inv(MKrg);
            coef_KRG=iMKrg*[donnees.build.y;zeros(donnees.build.dim_fc,1)];
        else
            coef_KRG=MKrg\[donnees.build.y;zeros(donnees.build.dim_fc,1)];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient gamma
        beta=coef_KRG((end-donnees.build.dim_fc+1):end);
        gamma=coef_KRG(1:(end-donnees.build.dim_fc));
       % gammao=rcc\(donnees.build.y-donnees.build.fc*betao);

      %  beta
      %  gamma
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde de donnees
if exist('cond_orig','var');build_data.cond_orig=cond_orig;end
if exist('cond_new','var');build_data.cond_new=cond_new;end
if exist('QMKrg','var');build_data.QMKrg=QMKrg;end
if exist('RMKrg','var');build_data.RMKrg=RMKrg;end
if exist('iMKrg','var');build_data.iMKrg=iMKrg;end
if exist('iRcc','var');build_data.iRcc=iRcc;end
if exist('yQ','var');build_data.yQ=yQ;end
if exist('fcQ','var');build_data.fcQ=fcQ;end
if exist('fctR','var');build_data.fctR=fctR;end
if exist('fctCfc','var');build_data.fctCfc=fctCfc;end
if exist('Lrcc','var');build_data.Lrcc=Lrcc;end
if exist('yL','var');build_data.yL=yL;end
if exist('fcL','var');build_data.fcL=fcL;end
if exist('fctU','var');build_data.fctU=fctU;end
if exist('Lrcc','var');build_data.Lrcc=Lrcc;end
if exist('Urcc','var');build_data.Urcc=Urcc;end
build_data.coef_KRG=coef_KRG;
build_data.beta=beta;
build_data.gamma=gamma;
build_data.rcc=rcc;
build_data.MKrg=MKrg;
build_data.deg=meta.deg;
build_data.para=meta.para;
build_data.fact_rcc=fact_rcc;
ret.build=build_data;
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






