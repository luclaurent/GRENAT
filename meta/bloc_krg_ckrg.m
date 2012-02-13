%% Construction des blocs du Krigeage
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr


function [lilog,ret]=bloc_krg_ckrg(donnees,meta,para)

%coefficient de reconditionnement
coef=10^8;
% type de factorisation de la matrice de corrélation
fact_rcc='LU' ; %LU %QR
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
    rc=zeros(donnees.in.nb_val);
    rca=zeros(donnees.in.nb_val,donnees.in.nb_var*donnees.in.nb_val);
    rci=zeros(donnees.in.nb_val*donnees.in.nb_var);
    
    for ii=1:donnees.in.nb_val
        for jj=1:donnees.in.nb_val
            % evaluation de la fonction de correlation
            [ev,dev,ddev]=feval(meta.corr,donnees.in.tiragesn(ii,:)-donnees.in.tiragesn(jj,:),...
                meta.para.val);
            %morceau de la matrice issue du krigeage
            rc(ii,jj)=ev;
            %morceau de la matrice provenant du Cokrigeage
            rca(ii,donnees.in.nb_var*(jj-1)+1:donnees.in.nb_var*jj)=-dev;
            %matrice des derivees secondes
            rci(donnees.in.nb_var*(ii-1)+1:donnees.in.nb_var*ii,...
                donnees.in.nb_var*(jj-1)+1:donnees.in.nb_var*jj)=-ddev;
        end
    end
    
    %Matrice de correlation du Cokrigeage
    rcc=[rc rca;rca' rci];
else
    %matrice de correlation du Krigeage
    rcc=zeros(donnees.in.nb_val);
    for ii=1:donnees.in.nb_val
        for jj=1:donnees.in.nb_val
            rcc(ii,jj)=feval(meta.corr,donnees.in.tiragesn(jj,:)-donnees.in.tiragesn(ii,:),meta.para.val);
        end
    end
end
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
        krg.beta=R\(Q'*yc);
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
    ((donnees.build.y-donnees.build.fc*ret.build.beta)'*ret.build.gamma;
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






