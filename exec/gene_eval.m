%%Evaluation de la fonction et de ses gradients
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function [eval,grad]=gene_eval(fct,X)

tailX=zeros(1,3);
tailX(1)=size(X,1);
tailX(2)=size(X,2);
tailX(3)=size(X,3);

%pour des vecteurs de dimension 1 et 2
if tailX(3)==1
    %en dimension 1
    if size(X,2)==1
       [ev,grad]=feval(fct,X);
    end

    %en dimension 2
    if tailX(2)==2
        grad=zeros(size(X));
        [ev,grad(:,1),grad(:,2)]=feval(fct,X(:,1),X(:,2));
    end
% pour des évaluations multiples (matrice de matrices)
elseif tailX(3)==2
    [ev,grad.GR1,grad.GR2]=feval(fct,X(:,:,1),X(:,:,2));
end

if nargout==1
    eval.Z=ev;
    if tailX(2)==2&&tailX(3)==1
        eval.GR1=grad(:,1);
        eval.GR2=grad(:,1);
    elseif tailX(3)==2
        eval.GR1=grad.GR1;
        eval.GR2=grad.GR2;
    end
else
    eval=ev;
end