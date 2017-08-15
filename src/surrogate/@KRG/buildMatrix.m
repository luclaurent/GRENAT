%% build kernel matrix and remove missing part
function K=buildMatrix(obj,paraValIn)
%in the case of GKRG
if obj.flagG
    [KK,KKd,KKdd]=obj.kernelMatrix.buildMatrix(paraValIn);
    obj.K=[KK -KKd;-KKd' -KKdd];
else
    [obj.K]=obj.kernelMatrix.buildMatrix(paraValIn);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Improve condition number of the KRG/GKRG Matrix
if obj.metaData.recond
    %coefficient for reconditionning (co)kriging matrix
    coefRecond=(10+size(obj.krgLS.XX,1))*eps;
    %
    obj.K=obj.K+coefRecond*speye(size(obj.K));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%remove missing parts
if obj.checkMiss
    if obj.flagG
        obj.K=obj.missData.removeGRM(obj.K);
    else
        obj.K=obj.missData.removeRM(obj.K);
    end
end
%
K=obj.K;
%
end