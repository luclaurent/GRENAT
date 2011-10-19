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

%Normalisation
if meta.norm
    %normalisation des donnees
    [evaln,infos_e]=norm_denorm(eval,'norm');
    [tiragesn,infos_t]=norm_denorm(tirages,'norm');
    infos.std_e=infos_e.std;std_e=infos_e.std;
    infos.moy_e=infos_e.moy;moy_e=infos_e.moy;
    infos.std_t=infos_t.std;std_t=infos_t.std;
    infos.moy_t=infos_t.moy;moy_t=infos_t.moy;
    gradn=norm_denorm_g(grad,'norm',infos); clear infos
    
    %sauvegarde des calculs
    nkrg.norm.moy_eval=infos_e.moy;
    nkrg.norm.std_eval=infos_e.std;
    nkrg.norm.moy_tirages=infos_t.moy;
    nkrg.norm.std_tirages=infos_t.std;
    nkrg.norm.on=true;
    clear infos_e infos_t
else
    nkrg.norm.on=false;
    evaln=eval;
    tiragesn=tirages;
    gradn=grad;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%rangement gradient
der=zeros(nbv*nbs,1);
for ii=1:nbs
    for jj=1:nbv
        der(nbv*ii-nbv+jj)=gradn(ii,jj);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creation du vecteur d'evaluation
y=vertcat(evaln,der) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de la log-vraisemblance dans le cas  de l'estimation des parametres
%(si on saouhaite avoir les valeurs de la log-vraisemblance en fonction des
%paramètres
if meta.para.estim&&meta.para.aff_likelihood
    val_para=linspace(meta.para.min,meta.para.max,30);
    
    %dans le cas ou on considere de l'anisotropie (et si on a 2
    %variable de conception)
    if meta.para.aniso&&nbv==2
        %on genere la grille d'étude
        [val_X,val_Y]=meshgrid(val_para,val_para);
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_lik=zeros(size(val_X));
        for itli=1:size(val_X,1)*size(val_X,2)
            %calcul de la log-vraisemblance et stockage
            [val_lik(itli)]=bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e,[val_X(itli) val_Y(itli)]);
            %val_cond(itli)=kk.cond;            
        end
        
        %trace log-vraisemblance
        figure;
        [C,h]=contourf(val_X,val_Y,val_lik);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        title('Evolution de la log-vraisemblance');
        %stockage de la figure au format LaTeX/TikZ
        matlab2tikz([aff.doss '/logli.tex'])
        
    % en 1D    
    elseif nbv==1
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_lik=zeros(1,length(val_para));
        for itli=1:length(val_para)
            %calcul de la log-vraisemblance et stockage
            [val_lik(itli)]=bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e,val_para(itli));
            % val_cond(itli)=kk.cond;
        end
        
        %stockage log-vraisemblance dans un fichier .dat
        ss=[val_para' val_lik'];        
        save([aff.doss '/logli.dat'],'ss','-ascii');
        
        %trace log-vraisemblance
        figure;
        plot(val_para,val_lik);
        title('Evolution de la log-vraisemblance');
        
    end
    
    %stocke les courbes (si actif)
    if aff.save&&(nbv<=2)
        fich=save_aff('fig_likelihood',aff.doss);
        if aff.tex
            fid=fopen([aff.doss '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,'Vraisemblance',fich);
            fclose(fid);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Construction des differents elements avec ou sans estimation des
%%parametres
if meta.para.estim
    fprintf('Estimation de la longueur de Correlation par minimisation de la log-vraisemblance\n');
    %minimisation de la log-vraisemblance
    switch meta.para.method
        case 'simplex'  %methode du simplexe       
        case 'fminbnd'	%utilisation fminbnd 
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
        case 'fmincon'	%utilisation fmincon
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
            fprintf('||Fmincon|| Initialisation au point:\n');
            fprintf('%g ',x0): fprintf('\n');
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
            desc=true;
            pas_min=1/50*(ub-lb);
            while indic==0
                %interception erreur
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
                        elseif desc&&(x0-pas_min)<lb
                            desc=false;
                            x0=x0+pas_min;
                            fprintf('||Fmincon|| Reinitialisation au point:\n');
                            fprintf('%g ',x0): fprintf('\n');
                            exitflag=-1;
                        elseif ~desc&&(x0+pas_min)<ub
                            x0=x0+pas_min;
                            fprintf('||Fmincon|| Reinitialisation au point:\n');
                            fprintf('%g ',x0): fprintf('\n');
                            exitflag=-1;
                        elseif ~desc&&(x0+pas_min)>ub
                            exitflag=1;
                            fprintf('||Fmincon|| Reinitialisation impossible.\n');
                        end
                    else
                        throw(exception);
                        exitflag=1;
                    end
                end
                %arret minimisation
                if exitflag==1||exitflag==0||exitflag==2
                    indic=1;
                    nkrg.estim_para=output;
                    nkrg.estim_para.val=x;
                end
            end
            
            %stockage valeur paramètres obtenue par minimisation
            meta.para.val=x;
            %affichage des valeurs des longueurs de corrélation
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construction des blocs de krigeage finaux tenant compte des longueurs de
%corrélation obtenues par minimisation
[lilog,krg]=bloc_ckrg(tiragesn,nbs,fc,y,meta,std_e);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
