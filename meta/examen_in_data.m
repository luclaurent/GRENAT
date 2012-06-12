%% fonction assurant l'examen des données entrante (en cas de données manquantes)
%% L. LAURENT -- 12/06/2012 -- laurent@lmt.ens-cachan.fr

function [ret]=examen_in_data(tirages,eval,grad)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf(' >> Examen des données entrantes \n');

%nombre de variables
nb_var=size(tirages,2);
%nombre de points
nb_val=size(tirages,1);
emptygrad=isempty(grad);

%données manquante dans les évaluations
manq_eval=isnan(eval);
nb_manq_eval=sum(manq_eval);
ix_manq_eval=find(manq_eval==1);
ix_dispo_eval=find(manq_eval==0);
if nb_manq_eval==nb_val;manq_eval_all=true;else manq_eval_all=false;end

%données manquantes dans les gradients
if ~emptygrad
manq_grad=isnan(grad);
nb_manq_grad=sum(manq_grad(:));
[r,c]=find(manq_grad==1);
ix_manq_grad=[r c];
[r,c]=find(manq_grad==0);
ix_dispo_grad=[r c];
if nb_manq_grad==nb_val*nb_var;manq_grad_all=true;else manq_grad_all=false;end
else
    nb_manq_grad=0;
    manq_grad=false;
end
    

%affichage des infos
if nb_manq_eval==0&&nb_manq_grad==0
    fprintf('>>> Aucune donnée manquante\n');
end

if nb_manq_eval~=0
    fprintf('>>> Réponse(s) manquante(s) au(x) point(x):\n')
    for ii=1:nb_manq_eval
        num_tir=ix_manq_eval(ii);
        fprintf(' n%s %i (%4.2f',char(176),num_tir,tirages(num_tir,1));
        if nb_var>1;fprintf(',%4.2f',tirages(num_tir,2:end));end
        fprintf(')\n');
    end
end
if ~emptygrad
if nb_manq_grad~=0
    fprintf('>>> Gradient(s) manquant(s) au(x) point(x):\n')
    for ii=1:nb_manq_grad
        num_tir=ix_manq_grad(ii,1);
        composante=ix_manq_grad(ii,2);
        fprintf(' n%s %i (%4.2f',char(176),num_tir,tirages(num_tir,1));
        if nb_var>1;fprintf(',%4.2f',tirages(num_tir,2:end));end
        fprintf(')');
        fprintf('  composante: %i\n',composante)
    end
    fprintf('----------------\n')
end
end

%extraction infos
if any(manq_eval)
    ret.manq_eval.on=any(manq_eval);
    ret.manq_eval.masque=manq_eval;
    ret.manq_eval.nb=nb_manq_eval;
    ret.manq_eval.ix_manq=ix_manq_eval;
    ret.manq_eval.ix_dispo=ix_dispo_eval;
    ret.manq_eval.all=manq_eval_all;
else
    ret.manq_eval.on=false;
end

if any(manq_grad)
    ret.manq_grad.on=any(manq_grad);
    ret.manq_grad.masque=manq_grad;
    ret.manq_grad.nb=nb_manq_grad;
    ret.manq_grad.ix_manq=ix_manq_grad;
    ret.manq_grad.ix_dispo=ix_dispo_grad;
    ret.manq_grad.all=manq_grad_all;
else
    ret.manq_grad.on=false;
end