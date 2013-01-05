%% Fonction assurant l'estimation des parametres (longueur de correlation)
% L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function para_estim=estim_para_krg_ckrg(donnees,meta)
% affichages warning ou non
aff_warning=false;

%Definition manuelle de la population initiale par LHS (Ga)
popInitManu=meta.para.popManu;
nbPopInit=meta.para.popInit;

%critere arret minimisation
crit_opti=meta.para.crit_opti;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')
fprintf('++ Estimation parametres\n');
[tMesu,tInit]=mesu_time;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition des parametres de minimisation
% Nombre de parametres a estimer
%anisotropie
if meta.para.aniso
    nb_para=donnees.in.nb_var;
    nb_para_optim=nb_para;
else
    nb_para=1;
    nb_para_optim=nb_para;
end
% traitement des cas particuliers (fonctions de correlation exponentielles
% generalisees)
switch meta.corr
    case 'corr_expg'
        %definition des bornes de l'espace de recherche
        lb=[meta.para.l_min*ones(1,nb_para) meta.para.p_min];
        ub=[meta.para.l_max*ones(1,nb_para) meta.para.p_max];
        nb_para_optim=nb_para+1;
    case 'corr_expgg'
        %definition des bornes de l'espace de recherche
        lb=[meta.para.l_min*ones(1,nb_para) meta.para.p_min*ones(1,nb_para)];
        ub=[meta.para.l_max*ones(1,nb_para) meta.para.p_max*ones(1,nb_para)];
        nb_para_optim=2*nb_para;
    otherwise
        %definition des bornes de l'espace de recherche
        lb=meta.para.l_min*ones(1,nb_para);ub=meta.para.l_max*ones(1,nb_para);
end
%definition valeur de depart de la variable
x0=lb+1/5*(ub-lb);
% Definition de la function a minimiser
fun=@(para)bloc_krg_ckrg(donnees,meta,para);
%Options algo pour chaque fonction de minimisation
%declaration des options de la strategie de minimisation
options_fmincon = optimset(...
    'Display', 'iter',...        %affichage evolution
    'Algorithm','interior-point',... %choix du type d'algorithme
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','',...   %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}
    'TolFun',crit_opti);
options_fminbnd = optimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','never',...
    'PlotFcns','');
options_ga = gaoptimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'PopInitRange',[lb(:)';ub(:)'],...  %zone de d�finition de la population initiale
    'UseParallel','always',...
    'PlotFcns','',...
    'TolFun',crit_opti,...
    'StallGenLimit',20);
options_fminsearch = optimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'TolFun',crit_opti,...
    'PlotFcns','');

%affichage des iterations
if ~meta.para.aff_iter_graph
    options_fmincon=optimset(options_fmincon,'OutputFcn','');
    options_fminbnd=optimset(options_fminbnd,'OutputFcn','');
    options_fminsearch=optimset(options_fminbnd,'OutputFcn','');
    options_ga=gaoptimset(options_ga,'OutputFcn','');
else
    figure
end
if ~meta.para.aff_iter_cmd
    options_fmincon=optimset(options_fmincon,'Display', 'final');
    options_fminbnd=optimset(options_fminbnd,'Display', 'final');
    options_fminsearch=optimset(options_fminbnd,'Display', 'final');
    options_ga=gaoptimset(options_ga,'Display', 'final');
end

%affichage informations interations algo (sous forme de plot)
if meta.para.aff_plot_algo
    options_fmincon=optimset(options_fmincon,'PlotFcns',{@optimplotx,@optimplotfunccount,...
        @optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval});
    options_ga=gaoptimset(options_ga,'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotdistance,...
        @gaplotexpectation,@gaplotmaxconstr,@gaplotrange,@gaplotselection,...
        @gaplotscorediversity,@gaplotscores,@gaplotstopping});
end

%specification manuelle de la population initiale (Ga)
if ~isempty(popInitManu)
    doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nbPopInit;doePop.aff=false;doePop.type=meta.para.popManu;
    tir_pop=gene_doe(doePop);
    options_ga=gaoptimset(options_ga,'PopulationSize',nbPopInit,'InitialPopulation',tir_pop);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'tir_min'
        nb_pts=nb_para*50;
        type_tir='LHS_O1';
        fprintf('||Tir_min||  Tirage %s de %i points\n',type_tir,nb_pts);
        doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nb_pts;doePop.aff=false;doePop.type=type_tir;
        tir_pop=gene_doe(doePop);
        crit=zeros(1,nb_pts);
        parfor tir=1:nb_pts
            crit(tir)=fun(tir_pop(tir,:));
        end
        [fval,IX]=min(crit);
        x=tir_pop(IX,:);
        
        %stockage retour algo
        para_estim.out_algo.fval=fval;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'tir_min_fmincon'
        nb_pts=nb_para*10;
        type_tir='LHS_O1';
        fprintf('||Tir_min + opti||  Tirage %s de %i points\n',type_tir,nb_pts);
        doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nb_pts;doePop.aff=false;doePop.type=type_tir;
        tir_pop=gene_doe(doePop);
        crit=zeros(1,nb_pts);
        parfor tir=1:nb_pts
            crit(tir)=fun(tir_pop(tir,:));
        end
        [fval1,IX]=min(crit);
        x1=tir_pop(IX,:);
        %recherche locale
        fprintf('||Fmincon (IP)|| Initialisation au point:\n');
        fprintf('%g ',x1); fprintf('\n');
        [x,fval2,exitflag,output] = fmincon(fun,x1,[],[],[],[],lb,ub,[],options_fmincon);
        %stockage retour algo
        para_estim.out_algo.fval1=fval1;
        para_estim.out_algo=output;
        para_estim.out_algo.fval=fval2;
        para_estim.out_algo.exitflag=exitflag;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'tir_min_sqp'
        nb_pts=nb_para*10;
        type_tir='LHS_O1';
        fprintf('||Tir_min + opti||  Tirage %s de %i points\n',type_tir,nb_pts);
        doePop.Xmin=lb;doePop.Xmax=ub;doePop.nb_samples=nb_pts;doePop.aff=false;doePop.type=type_tir;
        tir_pop=gene_doe(doePop);
        crit=zeros(1,nb_pts);
        parfor tir=1:nb_pts
            crit(tir)=fun(tir_pop(tir,:));
        end
        [fval1,IX]=min(crit);
        x1=tir_pop(IX,:);
        %recherche locale
        fprintf('||Fincon (SQP)|| Initialisation au point:\n');
        fprintf('%g ',x1); fprintf('\n');
        options_fmincon=optimset(options_fmincon,'Algorithm','sqp');
        [x,fval2,exitflag,output] = fmincon(fun,x1,[],[],[],[],lb,ub,[],options_fmincon);
        %stockage retour algo
        para_estim.out_algo.fval1=fval1;
        para_estim.out_algo=output;
        para_estim.out_algo.fval=fval2;
        para_estim.out_algo.exitflag=exitflag;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminbnd'
        fprintf('||Fminbnd|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fminsearch'
        fprintf('||Fminsearch|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimisation
        [x,fval,exitflag,output] = fminsearch(fun,x0,options_fminsearch);
        
        %stockage retour algo
        para_estim.out_algo=output;
        para_estim.out_algo.fval=fval;
        para_estim.out_algo.exitflag=exitflag;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'fmincon'
        fprintf('||Fmincon|| Initialisation au point:\n');
        fprintf('%g ',x0); fprintf('\n');
        %minimisation avec traitement de point de d�part non d�fini
        indic=0;
        if ~aff_warning;warning off all;end
        %pas de recherche d'initialisation
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
                    fprintf('Probleme initialisation fmincon (fct non definie au point initial)\n');
                    if desc&&any((x0-pas)>lb)
                        x0=x0-pas;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif desc&&any((x0-pas)<lb)
                        desc=false;
                        x0=xinit;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif ~desc&&any((x0+pas)<ub)
                        x0=x0+pas;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif ~desc&&any((x0+pas)>ub)
                        exitflag=-2;
                        fprintf('||Fmincon|| Reinitialisation impossible.\n');
                    end
                else
                    exitflag=-1;
                    getReport(exception,'extended')
                    x=x0;
                    break
                end
            end
            
            %arret minimisation
            if exitflag==1||exitflag==0||exitflag==2
                disp('Arret')
                para_estim.out_algo=output;
                para_estim.out_algo.fval=fval;
                para_estim.out_algo.exitflag=exitflag;
                indic=1;
            elseif exitflag==-2
                fprintf('Impossible d''initialiser l''algorithme\n Valeur du (des) parametre(s) fixe(s) � la valeur d''initialisation\n');
                x=xinit;
                indic=1;
            end
        end
        if ~aff_warning;warning on all;end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'ga'
        fprintf('||Ga|| Initialisation par tirages %s:\n',popInitManu);
        if ~aff_warning;warning off all;end
        [x,fval,exitflag,output] = ga(fun,nb_para_optim,[],[],[],[],lb,ub,[],options_ga);
        %arret minimisation
        if exitflag==1||exitflag==0||exitflag==2
            disp('Arret')
            para_estim.out_algo=output;
            para_estim.out_algo.fval=fval;
            para_estim.out_algo.exitflag=exitflag;
        elseif exitflag==-2
            fprintf('Bug arret Ga\n');
        end
        
        if ~aff_warning;warning on all;end
        
    otherwise
        error('Strategie de minimisation non prise en charge');
end
mesu_time(tMesu,tInit);
fprintf(' - - - - - - - - - - - - - - - - - - - - \n')
%stockage valeur parametres obtenue par minimisation
if nb_para_optim>nb_para
    para_estim.l_val=x(1:nb_para);
    para_estim.p_val=x(nb_para+1:end);
else
    para_estim.l_val=x;
end

if meta.norm
    para_estim.l_val_denorm=para_estim.l_val.*donnees.norm.std_tirages+donnees.norm.moy_tirages;
    fprintf('\nValeur(s) longueur(s) de correlation');
    fprintf(' %6.4f',para_estim.l_val_denorm);
    fprintf('\n');
end
fprintf('Valeur(s) longueur(s) de correlation (brut)');
fprintf(' %6.4f',para_estim.l_val);
fprintf('\n\n');
if nb_para_optim>nb_para
    fprintf('Valeur(s) longueur(s) puissance(s)');
    fprintf(' %6.4f',para_estim.p_val);
    fprintf('\n\n');
end
end