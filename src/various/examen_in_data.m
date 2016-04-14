%% fonction assurant l'examen des donn�es entrante (en cas de donn�es manquantes)
%% L. LAURENT -- 12/06/2012 -- luc.laurent@lecnam.net

function [ret]=examen_in_data(tirages,eval,grad)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf(' >> Examen des donnees entrantes \n');

%nombre de variables
nb_var=size(tirages,2);
%nombre de points
nb_val=size(tirages,1);
emptygrad=isempty(grad);

%donn�es manquante dans les �valuations
manq_eval=isnan(eval);
nb_manq_eval=sum(manq_eval);
ix_manq_eval=find(manq_eval==1);
ix_dispo_eval=find(manq_eval==0);
if nb_manq_eval==nb_val;manq_eval_all=true;else manq_eval_all=false;end

%donnees manquantes dans les gradients
if ~emptygrad
    %positionnement classique gradients (dy1/dx1,dy2/dx1...)
    manq_grad=isnan(grad);
    nb_manq_grad=sum(manq_grad(:));
    [r,c]=find(manq_grad==1);
    ix_manq_grad=[r c];
    [r,c]=find(manq_grad==0);
    ix_dispo_grad=[r c];
    [ix]=find(manq_grad==1);
    ix_manq_grad_line=ix;
    [ix]=find(manq_grad==0);
    ix_dispo_grad_line=ix;
    %positionnement metamodele gradients (dy1/dx1,dy1/dx2...)
    manq_gradt=isnan(grad');
    [r,c]=find(manq_gradt==1);
    ix_manq_gradt=[r c];
    [r,c]=find(manq_gradt==0);
    ix_dispo_gradt=[r c];
    [ix]=find(manq_gradt==1);
    ix_manq_gradt_line=ix;
    [ix]=find(manq_gradt==0);
    ix_dispo_gradt_line=ix;
    if nb_manq_grad==nb_val*nb_var;manq_grad_all=true;else manq_grad_all=false;end
else
    nb_manq_grad=0;
    manq_grad=false;
end


%affichage des infos
if nb_manq_eval==0&&nb_manq_grad==0
    fprintf('>>> Aucune donnee manquante\n');
end

if nb_manq_eval~=0
    fprintf('>>> Reponse(s) manquante(s) au(x) point(x):\n')
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
    ret.eval.on=any(manq_eval);
    ret.eval.masque=manq_eval;
    ret.eval.nb=nb_manq_eval;
    ret.eval.ix_manq=ix_manq_eval;
    ret.eval.ix_dispo=ix_dispo_eval;
    ret.eval.all=manq_eval_all;
else
    ret.eval.on=false;
    ret.eval.nb=0;
    ret.eval.all=false;
end

if any(manq_grad(:))
    ret.grad.on=any(manq_grad(:));
    ret.grad.masque=manq_grad;
    ret.grad.nb=nb_manq_grad;
    ret.grad.ix_manq=ix_manq_grad;
    ret.grad.ix_manq_line=ix_manq_grad_line;
    ret.grad.ix_dispo_line=ix_dispo_grad_line;
    ret.grad.ix_dispo=ix_dispo_grad;
    ret.grad.ixt_manq=ix_manq_gradt;
    ret.grad.ixt_manq_line=ix_manq_gradt_line;
    ret.grad.ixt_dispo_line=ix_dispo_gradt_line;
    ret.grad.ixt_dispo=ix_dispo_gradt;
    ret.grad.all=manq_grad_all;
else
    ret.grad.on=false;
    ret.grad.nb=0;
    ret.grad.all=false;
end