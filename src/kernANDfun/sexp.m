%% Function: squared exponential
%%L. LAURENT -- 18/01/2012 -- luc.laurent@cnam.fr
%revision of the 13/11/2012
%change of the 19/12/2012: change correlation length
%revision of the31/08/2015: change of the name of the function
%change of the 02/05/2016: change to unidimensional function

%Rasmussen 2006 p. 83

function [k,dk,ddk]=sexp(xx,para)
%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length and smoothness hyperparameters
lP=1./para(:,1);

%compute value of the function at point xx
td=-xx.^2./lP.^2/2;
k=exp(td);

%compute first derivatives
if nbOut>1
    %calcul derivees premieres
    dk=-xx./lP.^2.*k;
end

%compute second derivatives
if nbOut>2
    ddk=(xx.^2./lP.^4-1./lP.^2).*k;
end
end
