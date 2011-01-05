%%Evaluation de la fonction et de ses gradients
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function [eval,grad]=gene_eval(fct,tirages,fctd)

if nargin==2
    [eval,grad]=feval(fct,tirages);
end

if nargin==3
    eval=feval(fct,tirages);
    grad=feval(fctd,tirages);
end
