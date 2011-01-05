%%Evaluation de la fonction et de ses gradients
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function [eval,grad]=gene_eval(fct,X)

%pour des vecteurs de dimension 1 et 2
if size(X,3)==1
    %en dimension 1
    if size(X,2)==1
       [eval,grad]=feval(fct,X);
    end

    %en dimension 2
    if size(X,2)==2
        grad=zeros(size(X));
        [eval,grad(:,1),grad(:,2)]=feval(fct,X(:,1),X(:,2));
    end
% pour des évaluations multiples (matrice de matrices)
elseif size(X,3)==2
    [eval,grad.GR1,grad.GR2]=feval(fct,X(:,:,1),X(:,:,2));
end

