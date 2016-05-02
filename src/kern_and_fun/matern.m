%% Matern kernel function
% L. LAURENT -- 06/02/2013 (r: 31/08/2015)-- luc.laurent@lecnam.net

%nd+1 hyperparameters (length + nd smoothness parameters)

function [k,dk,ddk]=matern(xx,para)
%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=2
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length and smoothness hyperparameters
lP=para(:,1);
lS=para(:,2);

%useful functions
% sqrt(2*nu)*abs(x)/long
nx=@(nu,ll,xx) sqrt(2*nu).*abs(xx)./ll;
% first derivative
dnx=@(nu,ll,xx) sqrt(2*nu).*sign(xx)./ll;
% x^u*besselk
xbessel=@(nu,xx) xx.^nu.*besselk(nu,xx);
%first derivative of the previous function
dxbessel=@(nu,xx) -xx.^nu.*besselk(nu-1,xx);
%second derivative of the previous function
ddxbessel=@(nu,xx) -xx.^(nu-1).*besselk(nu-1,xx)+xx.^nu.*besselk(nu-2,xx);

%compute value of the function at points xx
coefS=2.^(1-lS)./gamma(lS);
xxN=nx(lS,lP,xx);
k=coefS.*xbessel(lS,xxN);

%check values close too zeros
II=abs(xx)<1e-50;
k(II)=1;

%compute first derivatives
if nbOut>1
    dxxN=dnx(lS,lP,xx);
    dk=coefS.*dxxN.*dxbessel(lS,xxN);
    %correction in 0
    dk(II)=0;
end

%compute second derivatives
if nbOut>2
    ddk=coefS.*dxxN.^2.*ddxbessel(lS,xxN);
    %correction in 0
    vdp=-lS(II).*gamma(lS(II)-1)./gamma(lS(II))./lP(II).^2;
    ddk(II)=vdp;
end
end