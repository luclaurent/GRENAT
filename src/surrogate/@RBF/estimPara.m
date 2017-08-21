

%% Estimate internal parameters
function estimPara(obj)
%objective function for hyperparameters estimation
fun=@(x)obj.cv(x,'estim');
%
obj.paraEstim=EstimPara(obj.nP,obj.metaData,fun);
obj.lVal=obj.paraEstim.l.Val;
obj.paraVal=obj.paraEstim.Val;
if isfield(obj.paraEstim,'p')
    obj.pVal=obj.paraEstim.p.Val;
end
if isfield(obj.paraEstim,'nu')
    obj.nuVal=obj.paraEstim.nu.Val;
end
end
