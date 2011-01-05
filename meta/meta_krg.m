
%fonction assurant la creation du metamodele de Krigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_krg(tirages,eval,meta)
tic;
tps_start=toc;


ns=size(eval,1);
tai_conc=size(tirages,2);

%Normalisation
if meta.norm
    disp('Normalisation');
    moy_e=mean(eval);
    std_e=std(eval);
    moy_t=mean(tirages);
    std_t=std(tirages);

    %normalisation des valeur de la fonction objectif et des tirages
    evaln=(eval-repmat(moy_e,ns,1))./repmat(std_e,ns,1);
    tiragesn=(tirages-repmat(moy_t,ns,1))./repmat(std_t,ns,1);
    
    %sauvegarde des donnees
    krg.norm.moy_eval=moy_e;
    krg.norm.std_eval=std_e;
    krg.norm.moy_tirages=moy_t;
    krg.norm.std_tirages=std_t;
    krg.norm.on=true;
else
    krg.norm.on=false;
    evaln=eval;
    tiragesn=tirages;
end

%evaluation aux points de l'espace de conception
y=evaln;

%creation matrice de conception
%(regression polynomiale)
if meta.deg==0
    nb_termes=1;
elseif meta.deg==1
    nb_termes=1+tai_conc;
elseif meta.deg==2
    p=(tai_conc+1)*(tai_conc+2)/2;
    nb_termes=p;
else
    error('Degre de regression non pris en charge')
end

fc=zeros(ns,nb_termes);
fct=['reg_poly' num2str(meta.deg,1)];
for ii=1:ns
    fc(ii,:)=feval(fct,tiragesn(ii,:)); 
end


%%Construction des differents elements avec ou sans estimation des
%%paramètres
if meta.para.estim
    %minimisation de la log-vraisemblance
    switch meta.para.method
        case 'simplex'  %methode du simplexe
            
        case 'fmincon'
            [x,fval,exitflag,output,lambda] = fmincon(
        otherwise
            error('Stratégie de minimisation non prise en charge');
    end

else
    krg=bloc_krg(tiragesn,meta);
end

tps_stop=toc;
fprintf('\nExecution construction Krigeage: %6.4d s\n',tps_stop-tps_start);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee
%%%%%Calcul des differentes erreurs
if meta.cv
    [krg.cv]=cross_validate_krg(krg,tirages,eval);  
    %les tirages et evaluations ne sont pas normalises (elles le seront
    %plus tard lors de la CV)

    tps_cv=toc;
    fprintf('Execution validation croisee Krigeage: %6.4d s\n\n',tps_cv-tps_stop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end