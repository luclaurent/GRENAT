%% Initialisation du metamodele
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function meta=init_meta(in)

fprintf('=========================================\n')
fprintf('     >>> INITIALISATION META <<<\n');
[tMesu,tInit]=mesu_time;

meta.grad=in.grad; %prise en compte des gradients

meta.type=in.type;         %type de metamodele KRG/CKRG/DACE/RBF/GRBF
meta.para.val=in.para.long(1);       %longueur de correlation


%en focntion du type de metamodele
switch in.type
    case 'SWF'
        meta.swf_para=in.para.swf_para;
    case 'DACE'
        if strcmp(type,'DACE')
            fctp='regpoly';
            meta.regr=[fctp num2str(in.para.deg,'%d')];      %fonction de regression
            meta.corr=['corr' in.corr];    %fonction de correlation
        end
    case {'RBF','GRBF','InRBF'}
        if isfield(in,'rbf')
            meta.fct=['rf_' in.rbf];
        else
            meta.fct='rf_sexp';
        end
        meta.para.val=in.para.rbf_para;
    case {'KRG','CKRG','InKRG'}
        meta.deg=in.deg;           %degre de la regression
        if isfield(in,'corr')
            meta.corr=['corr_' in.corr];     %fonction de correlation
        else
            meta.corr='corr_sexp';
        end
    otherwise
        
end

%normalisation
meta.norm=true;         %normalisation
meta.recond=false;      %amelioration du conditionnement de la matrice de correlation
meta.cv=true;           %validation croisee
meta.cv_aff=true;       %affichage QQ plot CV

%estimation parametre long (longueur de correlation)
meta.para.method='ga';     % m�thode de minimisation de la log-vraisemblance
meta.para.estim=true;           % recherche de la longueur de corr�lation
meta.para.aff_estim=false;  %affichage de la fonctionnelle � miniser pour obtenir le "meilleur" jeu de parametres
meta.para.aniso=true;   %prise en compte de l'anisotropie (longueur de corr�lation suivant chaque dimension)
meta.para.aff_iter_graph=false; %affichage iteration estimation param�tres sur un graph (1D/2D)
meta.para.aff_iter_cmd=false;   %affichage iteration dans la console
if meta.para.estim
    meta.para.max=in.para.long(2);
    meta.para.min=in.para.long(1);
end

%enrichissement (evaluation critere)
meta.enrich.on=true;
meta.enrich.para_wei=0.5;
meta.enrich.para_gei=1;
meta.enrich.para_lcb=0.5;

%Verification interpolation
meta.verif=true;

mesu_time(tMesu,tInit);
fprintf('=========================================\n')