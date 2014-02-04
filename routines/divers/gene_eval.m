%%Evaluation de la fonction et de ses gradients
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function [eval,grad]=gene_eval(fct,X,type)


[tMesu,tInit]=mesu_time;
%test parallelisme
numw=0;
if ~isempty(whos('parallel','global'))
    global parallel
    numw=parallel.num;
end
% en fonction du type d'évaluation (calcul au points tirés ou calcul pour
% affichage)
switch type
    %evaluations des pts tirées (X est une matrice: 1var par colonne)
    case 'eval'
        fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
        fprintf('  >>>        EVALUATION FONCTION      <<<\n');
        %% X matrice de tirages:
        % colonnes: chaque dimension
        % lignes: un jeu de paramètres
        nb_var=size(X,2);
        nb_val=size(X,1);
        %X
        
        %préparation jeu de données pour evaluation
        X_eval=zeros(nb_val,1,nb_var);
        
        parfor (ii=1:nb_var,numw)
            X_eval(:,:,ii)=X(:,ii);
        end
        %évaluation pour affichage (X est une matrice de matrice)
    case 'aff'
        fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
        fprintf('  >>> EVALUATION FONCTION (affichage) <<<\n');
        X_eval=X;
        nb_var=size(X,3);
        nb_val=size(X,1);
end

%evaluation fonction et gradients aux points x
if nargout==1
    [eval]=feval(fct,X_eval);
elseif nargout==2
    [eval,gradb]=feval(fct,X_eval);
    % dans le cas des évaluations aux points tirés on reorganise les
    % gradients
    if strcmp(type,'eval')
        grad=zeros(size(X));
        parfor (ii=1:nb_var,numw)
           grad(:,ii)=gradb(:,:,ii); 
        end
    else
        grad=gradb;
    end
else
    fprintf('Mauvais nombre de paramètres de sortie (cf. gene_eval)');
end

fprintf(' >> Evaluation de la fonction %s en %i pts (%iD)\n',fct,nb_val,nb_var);
fprintf(' >> Calcul des gradients: ');
if nargout==2;fprintf('Oui\n');else fprintf('Non\n');end

mesu_time(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')