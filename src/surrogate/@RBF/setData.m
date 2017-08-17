

%% prepare data for building (deal with missing data)
function setData(obj)
%Responses and gradients at sample points
YYT=obj.resp;
%remove missing response(s)
if obj.checkMiss
    YYT=obj.missData.removeRV(YYT);
end
%
der=[];
if obj.flagG
    tmp=obj.grad';
    der=tmp(:);
    %remove missing gradient(s)
    if obj.checkMiss
        der=obj.missData.removeGV(der);
    end
end
obj.YY=YYT;
obj.YYD=der;
%
obj.YYtot=[YYT;obj.YYD];
%initialize kernel matrix
obj.kernelMatrix=KernMatrix(obj.kernelFun,obj.sampling,obj.getParaVal);
end