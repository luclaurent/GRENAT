%% Fonction assurant l'estimation des parametres (longueur de correlation)
% L. LAURENT -- 14/12/2011 -- laurent@lmt.ens-cachan.fr

function para_estim=estim_para_krg_ckrg(donnees,meta)
% affichages warning ou non
aff_warning=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Estimation de la longueur de Correlation par minimisation de la log-vraisemblance\n');
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
x0=lb+1/5*(ub-lb);
% Définition de la function à minimiser
fun=@(para)bloc_krg_ckrg(donnees,meta,para);
%Options algo pour chaque fonction de minimisation
%declaration des options de la strategie de minimisation
options_fmincon = optimset(...
    'Display', 'iter',...        %affichage evolution
    'Algorithm','interior-point',... %choix du type d'algorithme
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','always',...
    'PlotFcns','');    %{@optimplotx,@optimplotfunccount,@optimplotstepsize,@optimplotfirstorderopt,@optimplotconstrviolation,@optimplotfval}
options_fminbnd = optimset(...
    'Display', 'iter',...        %affichage evolution
    'OutputFcn',@stop_estim,...      %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
    'FunValCheck','off',...      %test valeur fonction (Nan,Inf)
    'UseParallel','always',...
    'PlotFcns','');


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
        fun=@(para)bloc_krg(tiragesn,nbs,fc,y,meta,std_e,para);
        
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
        desc=true;
        pas_min=1/50*(ub-lb);
        xinit=x0;
        while indic==0
            try
                [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options_fmincon);
            catch exception
                text='undefined at initial point';
                [tt,~,~]=regexp(exception.message,text,'match','start','end');
                
                if ~isempty(tt)
                    fprintf('Problème initialisation fmincon (fct non définie au point initial)\n');
                    if desc&&(x0-pas_min)>lb
                        x0=x0-pas_min;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif desc&&(x0-pas_min)<lb
                        desc=false;
                        x0=x0+pas_min;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif ~desc&&(x0+pas_min)<ub
                        x0=x0+pas_min;
                        fprintf('||Fmincon|| Reinitialisation au point:\n');
                        fprintf('%g ',x0); fprintf('\n');
                        exitflag=-1;
                    elseif ~desc&&(x0+pas_min)>ub
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
        
    otherwise
        error('Strategie de minimisation non prise en charge');
end

%stockage valeur paramètres obtenue par minimisation
para_estim.val=x;
if meta.norm
    para_estim.val_denorm=x.*donnees.norm.std_tirages+donnees.norm.moy_tirages;
    fprintf('Valeur(s) longueur(s) de correlation');
    fprintf(' %6.4f',para_estim.val_denorm);
    fprintf('\n');
end
fprintf('Valeur(s) longueur(s) de correlation (brut)');
fprintf(' %6.4f',x);
fprintf('\n');
end