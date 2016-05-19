%% Function : Matern (3/2)
%%L. LAURENT -- 23/01/2011 -- luc.laurent@cnam.fr
%revision of the 12/11/2012 (from Lockwood 2010)
%change of the 19/12/2012: change correlation length
%revision of the 31/08/2015: change function name
%change of the 02/05/2016: change to unidimensional function

function [k,dk,ddk]=matern32(xx,para)

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
etd=exp(-abs(xx)./lP*sqrt(3));
co=1+sqrt(3)./lP.*abs(xx);
k=co.*etd;

%compute first derivatives
if nbOut>1
    %calcul derivees premieres
    dk=-3./lP.^2.*xx.*etd;
end

%compute second derivatives
if nbOut>2
    ddk=3./lP.^2.*(sqrt(3)./lP.*abs(xx)-1).*etd;
end
end
