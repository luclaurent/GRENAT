%% Fonction assurant l'estimation des parametres en RBF
% L. LAURENT -- 24/01/2012 -- laurent@lmt.ens-cachan.fr

function para_estim=estim_para_rbf(donnees,meta)
% affichages warning ou non
aff_warning=false;

%Definition manuelle de la population initiale par LHS (Ga)
popInitManu=true;
nbPopInit=50;
%critere arret minimisation
crit_opti=10^-6;

%arret affichage CV si c'est le cas et activation CV si ça n'est pas le cas
cv_old=meta.cv;
aff_cv_old=meta.cv_aff;
meta.cv_aff=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('- - - - - - - - - - - - - - - - -\n');
fprintf('++ Estimation parametres\n');
[tMesu,tInit]=mesu_time;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Définition des paramètres de minimisation
% Nombre de parametres à estimer
%anisotropie
if meta.para.aniso
    nb_para=donnees.in.nb_var;
else
    nb_para=1;
end
%definition des bornes de l'espace de recherche
lb=meta.para.min*ones(1,nb_para);ub=meta.para.max*ones(1,nb_para);
%definition valeur de depart de la variable
x0=0.1*(ub-lb);
% Définition de la function à minimiser
fun=@(para)bloc_rbf(donnees,meta,para);
%Options algo pour chaque fonction de minimisation
%declaration des options de la strategie de minimisation
options_fmincon = optimset(...
    'Display', 'iter',...        %affichage evolution
    'Algorithm','interior-point',... %choix du type d'algorithme
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','always',...
    'PlotFcns','',...   %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}
    'TolFun',crit_opti);
options_fminbnd = optimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','always',...
    'PlotFcns','');
options_ga = gaoptimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'UseParallel','always',...
    'PopInitRange',[lb(:)';ub(:)'],...  %zone de définition de la population initiale
    'PlotFcns','',...
    'TolFun',crit_opti,...
    'StallGenLimit',20);

%affichage des iterations
if ~meta.para.aff_iter_graph
    options_fmincon=optimset(options_fmincon,'OutputFcn','');
    options_fminbnd=optimset(options_fminbnd,'OutputFcn','');
    options_ga=gaoptimset(options_ga,'OutputFcn','');
else
    figure
end

if ~meta.para.aff_iter_cmd
    options_fmincon=optimset(options_fmincon,'Display','final');
    options_fminbnd=optimset(options_fminbnd,'Display','final');
    options_ga=gaoptimset(options_ga,'Display','final');
end

%specification manuelle de la population initiale (Ga)
if popInitManu
    tir_pop=lhsu(lb,ub,nbPopInit);
    options_ga=gaoptimset(options_ga,'InitialPopulation',tir_pop);
end

%minimisation de la log-vraisemblance suivant l'algorithme choisi
switch meta.para.method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'simplex'  %methode du simplexe
        fprintf('||Simplex|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        if ~aff_warning;warning off all;end
        [x, fmax, nf] = nmsmax(fun, x0, [], []);
        %stockage retour algo
        para_estim.out_algo.fmax=fmax;
        para_estim.out_algo.nf=nf;
        if ~aff_warning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminbnd'
        fprintf('||Fminbnd|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %definition des bornes de l'espace de recherche
        lb=meta.para.min;ub=meta.para.max;
        %declaration de la fonction a minimiser
        fun=@(para)bloc_rbf(donnees,meta,para);
        
        %minimisation
        if ~aff_warning;warning off all;end
        [x,fval,exitflag,output] = fminbnd(fun,lb,ub,options_fminbnd);
        if ~aff_warning;warning on all;end
        
        %stockage retour algo
        para_estim.out_algo=output;
        para_estim.out_algo.fval=fval;
        para_estim.out_algo.exitflag=exitflag;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'fmincon'
        
        fprintf('||Fmincon|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimisation avec traitement de point de départ non défini
        indic=0;
        if ~aff_warning;warning off all;end
        pas_min=1/500*(ub-lb);
        pas_max=1/50*(ub-lb);
        pente=0.2;
        desc=true;
        xinit=x0;
        pas_pres=pas_max;
        while indic==0
            try
                [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options_fmincon);
            catch exception
                text='undefined at initial point';
                [tt,~,~]=regexp(exception.message,text,'match','start','end');
                
                if ~isempty(tt)
                    %calcul du pas de variation
                    pas=(pas_max-pas_min).*(1-exp(-(x0-lb).*pas_max./pente))+pas_min;
                    if pas<pas_min;pas=pas_min;elseif pas>pas_max;pas=pas_max;end
                    fprintf('Variation: ');fprintf('%d ',pas);fprintf('\n');
                    fprintf('Problème initialisation fmincon (fct non définie au point initial)\n');
                    if desc&&any((x0-pas_min)>lb)
                        x0=x0-pas_min;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif desc&&any((x0-pas_min)<lb)
                        desc=false;
                        x0=x0+pas_min;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif ~desc&&any((x0+pas_min)<ub)
                        x0=x0+pas_min;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif ~desc&&any((x0+pas_min)>ub)
                        exitflag=-2;
                        fprintf('||Fmincon|| Reinitialisation impossible.\n');
                    end
                else
                    exitflag=-1;
                    throw(exception);
                end
            end
            
            %arret minimisation
            if exitflag==1||exitflag==0||exitflag==2
                para_estim.out_algo=output;
                para_estim.out_algo.fval=fval;
                para_estim.out_algo.exitflag=exitflag;
                indic=1;
            elseif exitflag==-2
                fprintf('Impossible d''initialiser l''algorithme\n Valeur du (des) paramètre(s) fixé(s) à la valeur d''initialisation\n');
                x=xinit;
                indic=1;
            end
        end
        if ~aff_warning;warning on all;end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'ga'
        
        fprintf('||Ga|| Initialisation par tirages LHS\n');
        %minimisation avec traitement de point de départ non défini
        indic=0;
        if ~aff_warning;warning off all;end
        [x,fval,exitflag,output] = ga(fun,nb_para,[],[],[],[],lb,ub,[],options_ga);
        %arret minimisation
        if exitflag==1||exitflag==0||exitflag==2
            para_estim.out_algo=output;
            para_estim.out_algo.fval=fval;
            para_estim.out_algo.exitflag=exitflag;
        elseif exitflag==-2
            fprintf('Bug arrêt Ga\n');
        end
        
        if ~aff_warning;warning on all;end
        
        
    otherwise
        error('Strategie de minimisation non prise en charge');
end

%reactivation affichage CV si c'était le cas avant la phase d'estimation
meta.cv_aff=aff_cv_old;
meta.cv=cv_old;

mesu_time(tMesu,tInit);
fprintf('- - - - - - - - - - - - - - - - -\n');
%stockage valeur paramètres obtenue par minimisation
para_estim.val=x;
if meta.norm
    para_estim.val_denorm=x.*donnees.norm.std_tirages+donnees.norm.moy_tirages;
    fprintf('\nValeur(s) parametre(s) RBF');
    fprintf(' %6.4f',para_estim.val_denorm);
    fprintf('\n');
end
fprintf('Valeur(s) parametre(s) RBF (brut)');
fprintf(' %6.4f',x);
fprintf('\n\n');
end