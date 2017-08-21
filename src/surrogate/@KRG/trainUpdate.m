%% Building/training the updated metamodel
function trainUpdate(obj,samplingIn,respIn,gradIn)
%Prepare data
obj.updateData(samplingIn,respIn,gradIn);
% estimate the internal parameters or not
if obj.estimOn
    obj.estimPara;
else
    obj.compute;
end
%
obj.requireCompute=false;
%
obj.showInfo('end');
%
obj.cv();
%
if obj.metaData.cvDisp
    obj.showCV();
end
end
