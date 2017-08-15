%% function evaluate likelihood
function [logLi,Li,liSack]=likelihood(obj,paraValIn)
if nargin==1;paraValIn=obj.paraVal;end
%compute matrices
[detK,logDetK]=obj.compute(paraValIn);
%size of the kernel matrix
sizeK=size(obj.K,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of the log-likelihood (Jones 1993 / Leary 2004)
logLi=sizeK/2*log(2*pi*obj.sig2)+1/2*logDetK+sizeK/2;
if nargout>=2
    %computation of the likelihood (Jones 1993 / Leary 2004)
    Li=1/((2*pi*obj.sig2)^(sizeK/2)*sqrt(detK))*exp(-sizeK/2);
end
%computation of the log-likelihood from Sacks 1989
if nargout==3
    liSack=abs(detK)^(1/sizeK)*obj.sig2;
end
if isinf(logLi)||isnan(logLi)
    logLi=1e16;
end
end