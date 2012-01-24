%% Procédure de construction de la matrice RBF et de calcul de la validation croisée
%% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function [msep,build,cv]=bloc_rbf(data,meta,para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%si para défini alors on charge cette nouvelle valeur
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Détermination des coefficients
warning off all
w=KK\data.build.y;
warning on all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
data.build.KK=KK;
data.build.w=w;
data.build.fct=meta.fct;
data.build.para=meta.para;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee
%%%%%Calcul des differentes erreurs
if meta.cv
    %tps_stop=toc;
    [cv]=cross_validate_rbf(data,meta);
    %tps_cv=toc;
    %fprintf('Execution validation croisee RBF/HBRBF: %6.4d s\n\n',tps_cv-tps_stop);
else
    cv=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
build=data.build;
msep=cv.msep;