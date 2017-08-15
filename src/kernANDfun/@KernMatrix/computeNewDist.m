%compute new inter-points distances (since new sample points are
%added)
function [distN,distNO]=computeNewDist(obj)
distN=obj.newSample(obj.NiX.iXsamplingN(:,1),:)-obj.newSample(obj.NiX.iXsamplingN(:,2),:);
distNO=obj.newSample(obj.NiX.iXsamplingNO(:,1),:)-obj.sampling(obj.NiX.iXsamplingNO(:,2),:);
obj.distN=distN;
obj.distNO=distNO;
end