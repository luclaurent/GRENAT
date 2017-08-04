
%% add new sample points
function addData(obj,samplingIn,respIn,gradIn)
%
obj.addSampling(samplingIn);
obj.addResp(respIn);
if nargin>3;obj.addGrad(gradIn);end
%
obj.check();
end