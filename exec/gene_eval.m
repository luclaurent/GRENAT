%%Evaluation de la fonction et de ses gradients
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function [eval,grad]=gene_eval(fct,X)

%% X matrice de tirages:
% colonnes: chaque dimension
% lignes: un jeu de paramètres
nb_var=size(X,2);
nb_val=size(X,1);

%préparation jeu de données pour evaluation
X_eval=zeros(1,nb_val,nb_var);
for ii=1:nb_var
    X_eval(:,:,ii)=X(:,ii);
end

%evaluation fonction et gradients aux points x
if nargout==1
    [eval]=feval(fct,X_eval);
elseif nargout==2
    [eval,grad]=feval(fct,X_eval);
else 
    fprintf('Mauvais nombre de paramètres de sortie (cf. gene_eval)');
end

