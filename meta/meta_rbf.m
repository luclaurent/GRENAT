%%fonction permettant de construire un metamodele à l'aide de fonctions a
%base radiale
% RBF: sans gradient
% HBRBF: avec gradients
%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010 modif le 12/04/2010 puis le 15/01/2012

function ret=meta_rbf(tirages,eval,grad,meta,manq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf(' >> Construction : ');
if ~isempty(grad);fprintf('GRBF \n');else fprintf('RBF \n');end
fprintf('>> Fonction de base radiale: %s\n',meta.rbf);
fprintf('>>> Normalisation: ');if meta.norm; fprintf('Oui\n');else fprintf('Non\n');end
fprintf('>>> CV: ');if meta.cv; fprintf('Oui\n');else fprintf('Non\n');end
fprintf('>> Affichage CV: ');if meta.cv_aff; fprintf('Oui\n');else fprintf('Non\n');end

fprintf('>>> Estimation parametre: ');if meta.para.estim; fprintf('Oui\n');else fprintf('Non\n');end
if meta.para.estim
    fprintf('>> Algo estimation: %s\n',meta.para.method);
    fprintf('>> Borne recherche: [%d , %d]\n',meta.para.min,meta.para.max);
    fprintf('>> Anisotropie: ');if meta.para.aniso; fprintf('Oui\n');else fprintf('Non\n');end
    fprintf('>> Affichage estimation console: ');if meta.para.aff_iter_cmd; fprintf('Oui\n');else fprintf('Non\n');end
    fprintf('>> Affichage estimation graphique: ');if meta.para.aff_iter_graph; fprintf('Oui\n');else fprintf('Non\n');end
else
    fprintf('>> Valeur parametre: %d\n',meta.para.val);
end
fprintf('\n\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement variables globales
global aff

%initialisation tempo
tic;
tps_start=toc;

%initialisation des variables
%nombre d'evalutions
nb_val=size(eval,1);
%dimension du pb (nb de variables de conception)
nb_var=size(tirages,2);

%test presence des gradients
pres_grad=~isempty(grad);
%test donnees manquantes
if nargin==5
    manq_eval=manq.eval.on;
    manq_grad=manq.grad.on;
    pres_grad=(~manq.grad.all&&manq.grad.on)||(pres_grad&&~manq.grad.on);
else
    manq.eval.on=false;
    manq.grad.on=false;
    manq_eval=manq.eval.on;
    manq_grad=manq.grad.on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Normalisation
if meta.norm
    disp('Normalisation');
    %normalisation des donnees
    [evaln,infos_e]=norm_denorm(eval,'norm',manq);
    [tiragesn,infos_t]=norm_denorm(tirages,'norm');
    std_e=infos_e.std;moy_e=infos_e.moy;
    std_t=infos_t.std;moy_t=infos_t.moy;
    
    %normalisation des gradients
    if pres_grad
        infos.std_e=infos_e.std;infos.moy_e=infos_e.moy;
        infos.std_t=infos_t.std;infos.moy_t=infos_t.moy;
        gradn=norm_denorm_g(grad,'norm',infos); clear infos
    else
        gradn=[];
    end
    
    %sauvegarde des calculs
    rbf.norm.moy_eval=infos_e.moy;
    rbf.norm.std_eval=infos_e.std;
    rbf.norm.moy_tirages=infos_t.moy;
    rbf.norm.std_tirages=infos_t.std;
    rbf.norm.on=true;
    clear infos_e infos_t
else
    rbf.norm.on=false;
    rbf.norm.moy_eval=[];
    rbf.norm.std_eval=[];
    rbf.norm.moy_tirages=[];
    rbf.norm.std_tirages=[];
    rbf.norm.on=false;
    evaln=eval;
    tiragesn=tirages;
    if pres_grad
        gradn=grad;
    else
        gradn=[];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluations et gradients aux points echantillonnes
y=evaln;
%suppression reponse(s) manquantes
if manq_eval
    y=y(manq.eval.ix_dispo);
end
if pres_grad
    tmp=gradn';
    der=tmp(:);
    %supression gradient(s) manquant(s)
    if manq_grad
        der=der(manq.grad.ixt_dispo_line);
    end
    y=vertcat(y,der);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
ret.in.tirages=tirages;
ret.in.tiragesn=tiragesn;
ret.in.eval=eval;
ret.in.evaln=evaln;
ret.in.pres_grad=pres_grad;
ret.in.grad=grad;
ret.in.gradn=gradn;
ret.in.nb_var=nb_var;
ret.in.nb_val=nb_val;
ret.build.y=y;
ret.norm=rbf.norm;
ret.manq=manq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de MSE par Cross-Validation
%arret affichage CV si c'est le cas et activation CV si ca n'est pas le cas
cv_old=meta.cv;
aff_cv_old=meta.cv_aff;
meta.cv_aff=false;

if meta.para.estim&&meta.para.aff_estim
    val_para=linspace(meta.para.min,meta.para.max,gene_nbele(nb_var));
    %dans le cas ou on considere de l'anisotropie (et si on a 2
    %variable de conception)
    if meta.para.aniso&&nb_var==2
        %on genere la grille d'etude
        [val_X,val_Y]=meshgrid(val_para,val_para);
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_msep=zeros(size(val_X));
        %si affichage dispo
        if usejava('desktop');h = waitbar(0,'Evaluation critere .... ');end
        for itli=1:numel(val_X)
            
            %calcul de la log-vraisemblance et stockage
            val_msep(itli)=bloc_rbf(ret,meta,[val_X(itli) val_Y(itli)]);
            %affichage barre attente
            if usejava('desktop')&&exist('h','var')
                avance=(itli-1)/numel(val_X);
                aff_av=avance*100;
                mess=['Eval. en cours ' num2str(aff_av,3) '% ' num2str(itli) '/' num2str(numel(val_X)) ];
                waitbar(avance,h,mess);
            end
        end
        close(h)
        %trace log-vraisemblance
        figure;
        [C,h]=contourf(val_X,val_Y,val_msep);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        %stockage de la figure au format LaTeX/TikZ
        if meta.save
            matlab2tikz([aff.doss '/logli.tex'])
        end
        
    elseif ~meta.para.aniso||nb_var==1
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_msep=zeros(1,length(val_para));
        rippa_bomp=val_msep;
        cv_moi=val_msep;
        %si affichage dispo
        if usejava('desktop');h = waitbar(0,'Evaluation critere .... ');end
        for itli=1:length(val_para)
            %calcul de la log-vraisemblance et stockage
            [~,build_rbf]=bloc_rbf(ret,meta,val_para(itli),'etud');
            rippa_bomp(itli)=build_rbf.cv.eloot;
            cv_moi(itli)=build_rbf.cv.perso.eloot;
            %affichage barre attente
            if usejava('desktop')&&exist('h','var')
                avance=(itli-1)/length(val_para);
                aff_av=avance*100;
                mess=['Eval. en cours ' num2str(aff_av,3) '% ' num2str(itli) '/' num2str(numel(val_para)) ];
                waitbar(avance,h,mess);
            end
        end
        close(h)
        
        %stockage mse dans un fichier .dat
        if meta.save
            ss=[val_para' val_msep'];
            save([aff.doss '/logli.dat'],'ss','-ascii');
        end
        
        %trace log-vraisemblance
        figure;
        semilogy(val_para,rippa_bomp,'r');
        hold on
        semilogy(val_para,cv_moi,'k');
        legend('Rippa (Bompard)','Moi');
        title('CV');
        
        %         semilogy(val_para,val_msep);
        %         title('Evolution de MSE (CV)');
        
    end
    
    %stocke les courbes (si actif)
    if aff.save&&(nb_val<=2)
        fich=save_aff('fig_mse_cv',aff.doss);
        if aff.tex
            fid=fopen([aff.doss '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,'Vraisemblance',fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
end
%rechargement config initiale si c'etait le cas avant la phase d'estimation
meta.cv_aff=aff_cv_old;
meta.cv=cv_old;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Construction des differents elements avec ou sans estimation des
%%parametres sinon on propose une/des valeur(s) des parametres a partir des
%%proposition de Hardy/Franke
if meta.para.estim
    para_estim=estim_para_rbf(ret,meta);
    meta.para.val=para_estim.val;
else
    meta.para.val=calc_para_rbf(tiragesn,meta);
    fprintf('Definition parametre (%s), val=',meta.para.type);
    fprintf(' %d',meta.para.val);
    fprintf('\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construction elements finaux RBF (matrice, coefficients et CV) en tenant
% compte des parametres obtenus par minimisation
[~,block]=bloc_rbf(ret,meta);
%sauvegarde informations
tmp=mergestruct(ret.build,block.build);
ret.build=tmp;
ret.cv=block.cv;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tps_stop=toc;
ret.tps=tps_stop-tps_start;
if pres_grad;txt='HBRBF';else txt='RBF';end
fprintf('\nExecution construction %s: %6.4d s\n',txt,tps_stop-tps_start);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


