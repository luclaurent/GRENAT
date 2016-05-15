%% Function: Matern (5/2)
%% L. LAURENT -- 23/01/2011 -- luc.laurent@cnam.fr
%revision of the 12/11/2012 (from Lockwood 2010)
%change of the 01/02/2013: change correlation length
%revision 31/08/2015: change name of the function
%change of 02/05/2016: change to unidimensional function

function [k,dk,ddk]=matern52(xx,para)
%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length and smoothness hyperparameters
lP=para(:,1);

%compute value of the function at point xx
etd=exp(-abs(xx)./lP*sqrt(5));
co=1-abs(xx)./lP*sqrt(5)+sqrt(5).*xx.^2./(3*lP);
k=co.*etd;

%compute first derivatives
if nbOut>1
    %calcul derivees premieres
    dk=-(5./(3*lP.^2).*xx+5*sqrt(5)./(3*lP.^3).*xx.^2.*sign(xx)).*etd;
end

%compute second derivatives
if nbOut>2
    ddk=-5./(3*lP.^2).*(1+sqrt(5)*abs(xx)./lP-5*xx.^2./lP.^2).*etd;
end
end