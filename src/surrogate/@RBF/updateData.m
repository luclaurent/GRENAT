

%% Prepare data for building (deal with missing data)
function updateData(obj,samplingIn,respIn,gradIn)
%Responses and gradients at sample points
YYT=respIn;
%remove missing response(s)
if obj.checkNewMiss
    YYT=obj.missData.removeRV(YYT,'n');
end
%
der=[];
if obj.flagG
    tmp=gradIn';
    der=tmp(:);
    %remove missing gradient(s)
    if obj.checkNewMiss
        der=obj.missData.removeGV(der,'n');
    end
end
obj.YY=[obj.YY;YYT];
obj.YYD=[obj.YYD;der];
%
obj.YYtot=[obj.YY;obj.YYD];
%initialize kernel matrix
obj.kernelMatrix.updateMatrix(samplingIn);
end
