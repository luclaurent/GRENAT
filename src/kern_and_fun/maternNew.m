%%fonction de correlation Matern 
%%L. LAURENT -- 06/02/2013 -- luc.laurent@ens-cachan.fr

%parametres possibles nd+1 (nd: portees et 1: regularite

function [k,dk,ddk]=matern(xx,para)
%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=2
    error(['Wrong number of hyperparameters (',mfilename,')']);
end
%number of evaluations
nE=numel(xx);

%extract length and smoothness hyperparameters
lP=para(:,1);
lS=para(:,2);

%compute coefficients
coefM=(2*lS)^.5./lP;
coefS=lS./2.^(lS-1)*gamma(lS);

%compute specific terms of the Matern function
xxN=abs(xx)./lP;
xxPN=abs(xx).^(-lS);

%check values close too zeros
II=xxPN>eps;

%compute responses
k=ones(nE,1);
bess_nu=besselmx(double('K'),lS(1),xxN,0);
k(II)=coefM(II).^lS.*coefS./xxPN(II).*bess_nu(II);

if nbOut>2
    %compute first derivatives
    dk=zeros(nE,1);
    dk(II)=-coefS.*coefM(II).^(lS+1)./xxPN(II).*...
        besselmx(double('K'),lS(1)-1,xxPN(II),0).*sign(xx(II));
end

if nbOut>3
    %compute second derivatives
    bess_num=besselmx(double('K'),nu-1,xx_n,0);
    ddk=-coefS.*coefM.^(nu+1).*(abs(xx).^(nu-1).*bess_num-...
        coefM.*abs(xx).^nu.*besselmx(double('K'),nu-2,xx_n,0));
end
end