%fonction assurant la creation du metamodele de CoKrigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_ckrg(tirages,eval,grad,meta)
tic;
tps_start=toc;

%nombre d'evalutions
ns=size(eval,1);
%dimension du pb (nb de variables de conception)
dim=size(tirages,2);



%Normalisation
if meta.norm
    %calcul des moyennes et des ecarts type
    moy_e=mean(eval);
    std_e=std(eval);
    moy_t=mean(tirages);
    std_t=std(tirages);
    
    %test pour verification ecart type
    ind=find(std_e==0);
    if ~isempty(ind)
        std_e(ind)=1;
    end
    ind=find(std_t==0);
    if ~isempty(ind)
        std_t(ind)=1;
    end
    
    %normalisation
    evaln=(eval-repmat(moy_e,ns,1))./repmat(std_e,ns,1);
    tiragesn=(tirages-repmat(moy_t,ns,1))./repmat(std_t,ns,1);
    gradn=grad.*repmat(std_t,ns,1)/std_e;
  
    
    %sauvegarde des calculs
    nkrg.norm.moy_eval=moy_e;
    nkrg.norm.std_eval=std_e;
    nkrg.norm.moy_tirages=moy_t;
    nkrg.norm.std_tirages=std_t;
    nkrg.norm.on=true;
else
    nkrg.norm.on=false;
    evaln=eval;
    tiragesn=tirages;
    gradn=grad;
end

%rangement gradient
der=zeros(dim*ns,1);
for ii=1:ns
    for jj=1:dim
        der(dim*ii-dim+jj)=gradn(ii,jj);        
    end
end

%creation du vecteur d'evaluation
y=vertcat(evaln,der) ;


%creation matrice de conception
if meta.deg==0
    p=1;
elseif meta.deg==1
    p=dim+1;
elseif meta.deg==2
    p=(dim+1)*(dim+2)*1/2;
else
    error('Degre de polynome non encore prise en charge');
end
    
fc=zeros((dim+1)*ns,p);
fct=['reg_poly' num2str(meta.deg,1)];
p=ns;
for ii=1:ns
       [fc(ii,:),fc(p+(1:dim),:)]=feval(fct,tiragesn(ii,:));
       p=p+dim;
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
            fun=@(para)bloc_ckrg(tiragesn,ns,fc,y,meta,std_e,para);
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
            fprintf('Valeur de la longueur de correlation %6.4f\n',x);
        case 'fmincon'
            %definition des bornes de l'espace de recherche
            lb=meta.para.min;ub=meta.para.max;
            %definition valeur de depart de la variable
            x0=lb+eps;
            %declaration de la fonction a  minimiser
            fun=@(para)bloc_ckrg(tiragesn,ns,fc,y,meta,std_e,para);
            %declaration des options de la strategie de minimisation
            options = optimset(...
               'Display', 'iter',...        %affichage evolution
               'Algorithm','interior-point',... %choix du type d'algorithme
               'OutputFcn',@stop_estim,...           %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
               'FunValCheck','off',...
               'UseParallel','always',...
               'PlotFcns','');  %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}    
           
            %minimisation
            indic=0;
            warning off all;
            while indic==0
                %interception erreur
                try
                    [x,fval,exitflag,output,lambda] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);
                catch exception
                    throw(exception);
                    
                    exitflag=1;
                end
                %arret minimisation
                if exitflag==1||exitflag==0||exitflag==2
                    indic=1;
                    nkrg.estim_para=output;
                    nkrg.estim_para.val=x;
                end
            end
                    
            meta.para.val=x;
            fprintf('Valeur de la longueur de correlation %6.4f\n',x);
        otherwise
            error('Strategie de minimisation non prise en charge');
    end
end

%construction des blocs de krigeage finaux
[lilog,krg]=bloc_ckrg(tiragesn,ns,fc,y,meta,std_e);


%sauvegarde informations
krg=mergestruct(nkrg,krg);
krg.fc=fc;
krg.y=y;
krg.reg=fct;
krg.dim=ns;
krg.corr=meta.corr;    
krg.deg=meta.deg;
krg.para=meta.para;
krg.con=size(tirages,2);



tps_stop=toc;
krg.tps=tps_stop-tps_start;
fprintf('\nExecution construction CoKrigeage: %6.4d s\n',tps_stop-tps_start);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee
%%%%%Calcul des differentes erreurs
if meta.cv
    [krg.cv]=cross_validate_ckrg(krg,tirages,eval);  
    %les tirages et evaluations ne sont pas normalises (elles le seront
    %plus tard lors de la CV)

    tps_cv=toc;
    fprintf('Execution validation croisee CoKrigeage: %6.4d s\n\n',tps_cv-tps_stop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end