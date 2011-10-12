%fonction assurant la creation du metamodele de CoKrigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_ckrg(tirages,eval,grad,meta)

global aff

tic;
tps_start=toc;

%nombre d'evalutions
nbs=size(eval,1);
%dimension du pb (nb de variables de conception)
nbv=size(tirages,2);
grad


%Normalisation
if meta.norm
    %calcul des moyennes et des ecarts type
    moy_e=mean(eval)
    std_e=std(eval)
    moy_t=mean(tirages)
    std_t=std(tirages)
    
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
    repmat(moy_t,nbs,1)
    evaln=(eval-repmat(moy_e,nbs,1))./repmat(std_e,nbs,1);
    tiragesn=(tirages-repmat(moy_t,nbs,1))./repmat(std_t,nbs,1);
    gradn=grad.*repmat(std_t,nbs,1)/std_e;
    
    
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
der=zeros(nbv*nbs,1);
for ii=1:nbs
    for jj=1:nbv
        der(nbv*ii-nbv+jj)=gradn(ii,jj);
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
    p=(nbv+1)*(nbv+2)*1/2;
else
    error('Degre de polynome non encore prise en charge');
end

fc=zeros((nbv+1)*nbs,p);
fct=['reg_poly' num2str(meta.deg,1)];
p=nbs;
for ii=1:nbs
    [fc(ii,:),fc(p+(1:nbv),:)]=feval(fct,tiragesn(ii,:));
    p=p+nbv;
end

%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de la log-vraisemblance dans le cas  de l'estimation des parametres
if meta.para.estim&&meta.para.aff_likelihood
    val_para=linspace(meta.para.min,meta.para.max,30);
    
    if meta.para.aniso&&nbv>1
        [val_X,val_Y]=meshgrid(val_para,val_para);
        
        val_lik=zeros(size(val_X));
        val_cond=zeros(size(val_X));
        for itli=1:size(val_X,1)*size(val_X,2)
            [val_lik(itli)]=bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e,[val_X(itli) val_Y(itli)]);
            %val_cond(itli)=kk.cond;
            
        end
        
        figure;
        [C,h]=contourf(val_X,val_Y,val_lik);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        title('Evolution de la log-vraisemblance');
        matlab2tikz([aff.doss '/logli.tex'])
        %         figure;
        %         [C,h]=contourf(val_X,val_Y,val_cond);
        %         text_handle = clabel(C,h);
        %         set(text_handle,'BackgroundColor',[1 1 .6],...
        %             'Edgecolor',[.7 .7 .7])
        %         set(h,'LineWidth',2)
        %         title('Evolution du conditionnement');
        
    else
        val_lik=zeros(1,length(val_para));
        for itli=1:length(val_para)
            [val_lik(itli)]=bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e,val_para(itli));
            % val_cond(itli)=kk.cond;
        end
        ss=[val_para' val_lik'];
        save([aff.doss '/logli.dat'],'ss','-ascii');
        figure;
        plot(val_para,val_lik);
        title('Evolution de la log-vraisemblance');
        %         figure;
        %         plot(val_para,val_cond);
        %         title('Evolution du conditionnement');
    end
    if aff.save
        fich=save_aff('fig_likelihood',aff.doss);
        if aff.tex
            fid=fopen([aff.doss '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,'Vraisemblance',fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%

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
            fun=@(para)bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e,para);
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
            nkrg.estim_para=mergestruct(output,nkrg.estim_para);
            nkrg.estim_para.val=x;
            meta.para.val=x;
            fprintf('Valeur de la longueur de correlation %6.4f\n',x);
        case 'fmincon'
            %anisotropie
            if meta.para.aniso
                nb_para=nbv;
            else
                nb_para=1;
            end
            %definition des bornes de l'espace de recherche
            lb=meta.para.min*ones(1,nb_para);ub=meta.para.max*ones(1,nb_para);
            %definition valeur de depart de la variable
            x0=lb+1/5*(ub-lb);%x0=(lb+ub)./2;
            %declaration de la fonction a  minimiser
            fun=@(para)bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e,para);
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
            if meta.norm
                meta.para.val_denorm=x.*std_t+moy_t;
                fprintf('Valeur(s) longueur(s) de correlation');
                fprintf(' %6.4f',meta.para.val_denorm);
                fprintf('\n');
            end
            fprintf('Valeur(s) longueur(s) de correlation (brut)');
            fprintf(' %6.4f',x);
            fprintf('\n');
            
        otherwise
            error('Strategie de minimisation non prise en charge');
    end
end

%construction des blocs de krigeage finaux
[lilog,krg]=bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e);


%sauvegarde informations
krg=mergestruct(nkrg,krg);
krg.fc=fc;
krg.y=y;
krg.reg=fct;
krg.dim=nbs;
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
