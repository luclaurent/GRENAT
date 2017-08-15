%% Building/training metamodel
function train(obj)
obj.showInfo('start');
%Prepare data
obj.setData;
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