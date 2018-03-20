%% Function: exponential
%% L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@cnam.fr

function [G,dG,ddG]=expo(xx,para)

%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length 
lP=1./para(:,1);

%compute value of the function at point xx
xxN=abs(xx)./lP;
G=exp(-xxN);

%compute first derivatives
if nbOut>1
    %
    dG=-sign(xx)./lP.^2.*G;
end

%compute second derivatives
if nbOut>2
    ddG=G./lP.^2;
end
end



