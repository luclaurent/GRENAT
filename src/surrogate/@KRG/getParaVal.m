%% get value of the internal parameters
function pV=getParaVal(obj)
if isempty(obj.paraVal)
    %w/o estimation, the initial values of hyperparameters are chosen
    switch obj.kernelFun
        case {'expg','expgg'}
            obj.paraVal=[obj.metaData.para.l.Val obj.metaData.para.p.Val];
        case {'matern'}
            obj.paraVal=[obj.metaData.para.l.Val obj.metaData.para.nu.Val];
        otherwise
            obj.paraVal=obj.metaData.para.l.Val;
    end
end
pV=obj.paraVal;
end
