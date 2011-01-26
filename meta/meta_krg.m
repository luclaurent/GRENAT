
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
    nkrg.norm.moy_eval=moy_e;
    nkrg.norm.std_eval=std_e;
    nkrg.norm.moy_tirages=moy_t;
    nkrg.norm.std_tirages=std_t;
    nkrg.norm.on=true;
else
    nkrg.norm.on=false;
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
%%parametres
if meta.para.estim
    fprintf('Estimation de la longueur de Correlation par minimisation de la log-vraisemblance\n');
    %minimisation de la log-vraisemblance
    switch meta.para.method
        case 'simplex'  %methode du simplexe
            
        case 'fminbnd'
            %definition des bornes de l'espace de recherche
            lb=meta.para.min;ub=meta.para.max;
            %declaration de la fonction a minimiser
            fun=@(para)bloc_krg(tiragesn,ns,fc,y,meta,std_e,para);
            options = optimset(...
                'Display', 'iter',...        %affichage evolution
                'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
                'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
                'UseParallel','always',...
                'PlotFcns','');
            %minimisation
            warning off all;
            [x,fval,exitflag,output] = fminbnd(fun,lb,ub,options);
            warning on all;
            
            meta.para.val=x;
            nkrg.estim_para=output;
            nkrg.estim_para.val=x;
            fprintf('Valeur de la longueur de correlation %6.4f\n',x);
            
        case 'fmincon'
            %definition des bornes de l'espace de recherche
            lb=meta.para.min;ub=meta.para.max;
            %definition valeur de depart de la variable
            x0=lb+eps;
            %declaration de la fonction a minimiser
            fun=@(para)bloc_krg(tiragesn,ns,fc,y,meta,std_e,para);
            %declaration des options de la strategie de minimisation
            options = optimset(...
               'Display', 'iter',...        %affichage evolution
               'Algorithm','interior-point',... %choix du type d'algorithme
               'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
               'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
                'UseParallel','always',...
                'PlotFcns','');    %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}  
           
            %minimisation
            indic=0;
            warning off all;
            while indic==0
                %interception erreur
                %   try
                [x,fval,exitflag,output,lambda] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);
                %    catch exception
                %                   throw(exception)
                %       exitflag=-1;
                %   end
                
                %arret minimisation
                if exitflag==1||exitflag==0||exitflag==2
                    indic=1;
                    nkrg.estim_para=output;
                    nkrg.estim_para.val=x;
                end
            end
            warning on all;
            
            meta.para.val=x;
            fprintf('Valeur de la longueur de correlation %6.4f\n',x);
        otherwise
            error('Strategie de minimisation non prise en charge');
    end
end

%construction des blocs de krigeage finaux
[lilog,krg]=bloc_krg(tiragesn,ns,fc,y,meta,std_e);


%sauvegarde informations
krg=mergestruct(nkrg,krg);
krg.reg=fct;
krg.con=tai_conc;
krg.ter_reg=nb_termes;

tps_stop=toc;
krg.tps=tps_stop-tps_start;
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