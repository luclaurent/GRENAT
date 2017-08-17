

%% build factorization, solve the RBF problem
function compute(obj,paraValIn)
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
            obj.coreQR;
        case 'LU'
            obj.coreLU;
        case 'LL'
            obj.coreLL;
        otherwise
            obj.coreClassical;
    end
    %
end
end
