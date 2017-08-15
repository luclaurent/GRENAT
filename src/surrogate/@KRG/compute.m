%% build factorization, solve the kriging problem and evaluate the log-likelihood
function [detK,logDetK]=compute(obj,paraValIn)
if nargin==1;
    paraValIn=obj.paraVal;
else
    obj.paraVal=paraValIn;
end
%
if obj.requireCompute
    %build the kernel Matrix
    obj.buildMatrix(paraValIn);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Factorization of the matrix
    switch obj.factK
        case 'QR'
            [detK,logDetK]=obj.coreQR;
        case 'LU'
            [detK,logDetK]=obj.coreLU;
        case 'LL'
            [detK,logDetK]=obj.coreLL;
        otherwise
            [detK,logDetK]=obj.coreClassical;
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %variance of the Gaussian process
    sizeK=size(obj.K,1);
    obj.sig2=1/sizeK*...
        ((obj.YYtot-obj.krgLS.XX*obj.beta)'*obj.gamma);
end
end