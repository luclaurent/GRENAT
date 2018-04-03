%% Function: exponential (laplacian)
%% L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@cnam.fr

function [k,dk,ddk]=expo(xx,para)

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
k=exp(-xxN);

%compute first derivatives
if nbOut>1
    %
    dk=-sign(xx)./lP.*k;
end

%compute second derivatives
if nbOut>2
    ddk=k./lP.^2;
end
end



