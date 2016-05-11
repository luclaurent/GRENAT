%% Function for computing Likelihood and Log-likelihood of the krigind
%L. LAURENT -- 10/11/2010 -- luc.laurent@lecnam.net

% //!\\ specific process for evaluating the logarithm of the determinant
%in order to reduce computational  issues

function [logLi,Li,liSack]=KRGLikelihood(dataKRG)

%size of the kernel matrix
sizeK=size(dataKRG.build.K,1);

%computation of the log-likelihood (Jones 1993 / Leary 2004)
switch dataKRG.build.factKK
    case 'QR'
        diagRK=diag(dataKRG.build.RK);
        detK=abs(prod(diagRK)); %Q is an unitary matrix
        logDetK=sum(log(abs(diagRK)));
    case 'LL'
        diagLK=diag(dataKRG.build.LK);
        detK=prod(diagLK)^2;
        logDetK=2*sum(log(abs(diagLK)));
    case 'LU'
        diagUK=diag(dataKRG.build.UK);
        detK=prod(diagUK); %L is a quasi-triangular matrix and contains ones on the diagonal
        logDetK=sum(log(abs(diagUK)));
    otherwise
        eigVal=eig(dataKRG.build.K);
        detK=prod(eigVal);
        logDetK=sum(log(eigVal));
end

logLi=sizeK/2*log(2*pi*dataKRG.build.sig2)+1/2*logDetK+sizeK/2;
liSack=0;
if nargout==3
    liSack=abs(detK)^(1/sizeK)*dataKRG.build.sig2;
end


if isinf(logLi)||isnan(logLi)
    logLi=1e16;
end

if nargout>=2
    %computation of the likelihood (Jones 1993 / Leary 2004)
    Li=1/((2*pi*dataKRG.build.sig2)^(sizeK/2)*sqrt(detK))*exp(-sizeK/2);
    
elseif nargout >3
    error(['Wrong number of output variables (',mfilename,')\n']);
end