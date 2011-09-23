
%fonction assurant la creation du metamodele de Krigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_krg(tirages,eval,meta)

global aff

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

%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de la log-vraisemblance dans le cas  de l'estimation des parametres
if meta.para.estim&&meta.para.aff_likelihood
    val_para=linspace(meta.para.min,meta.para.max,30);
    if meta.para.aniso&&tai_conc>1
        [val_X,val_Y]=meshgrid(val_para,val_para);
        val_lik=zeros(size(val_X));
        for itli=1:size(val_X,1)*size(val_X,2)
            val_lik(itli)=bloc_krg(tiragesn,ns,fc,y,meta,std_e,[val_X(itli) val_Y(itli)]);
        end
        
        figure;
        [C,h]=contourf(val_X,val_Y,val_lik);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        matlab2tikz([aff.doss '/logli.tex'])
        
    else
        val_lik=zeros(1,length(val_para));
        for itli=1:length(val_para)
            val_lik(itli)=bloc_krg(tiragesn,ns,fc,y,meta,std_e,val_para(itli));
        end
        ss=[val_para' val_lik'];
        save([aff.doss '/logli.dat'],'ss','-ascii');
        figure;
        plot(val_para,val_lik);
        title('Evolution de la log-vraisemblance');
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
            %anisotropie
            if meta.para.aniso
                nb_para=tai_conc;
            else
                nb_para=1;
            end
            %definition des bornes de l'espace de recherche
            lb=meta.para.min*ones(1,nb_para);ub=meta.para.max*ones(1,nb_para);
            %definition valeur de depart de la variable
            x0=lb+1/5*(ub-lb);
            fprintf('||Fmincon|| Initialisation au point:\n');
            fprintf('%g ',x0): fprintf('\n');
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
               try
                    [x,fval,exitflag,output,lambda] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);
                catch exception
                    text='undefined at initial point';
                    [tt,ss,ee]=regexp(exception.message,[text],'match','start','end');
                    
                    if ~isempty(tt)
                        fprintf('Problème initialisation fmincon (fct non définie au point initial)\n');
                        if desc&(x0-pas_min)>lb
                            x0=x0-pas_min;
                            fprintf('||Fmincon|| Reinitialisation au point:\n');
                            fprintf('%g ',x0): fprintf('\n');
                            exitflag=-1;
                        elseif desc&(x0-pas_min)<lb
                            desc=false;
                            x0=x0+pas_min;
                            fprintf('||Fmincon|| Reinitialisation au point:\n');
                            fprintf('%g ',x0): fprintf('\n');
                            exitflag=-1;
                        elseif ~desc&(x0+pas_min)<ub
                            x0=x0+pas_min;
                            fprintf('||Fmincon|| Reinitialisation au point:\n');
                            fprintf('%g ',x0): fprintf('\n');
                            exitflag=-1;
                        elseif ~desc&(x0+pas_min)>ub
                            exitflag=1;
                            fprintf('||Fmincon|| Reinitialisation impossible.\n');
                        end
                    else
                        throw(exception);
                        exitflag=1;
                    end
                end
            end
            %arret minimisation
                if exitflag==1||exitflag==0||exitflag==2
                    indic=1;
                    nkrg.estim_para=output;
                    nkrg.estim_para.val=x;
                end
            warning on all;
            
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