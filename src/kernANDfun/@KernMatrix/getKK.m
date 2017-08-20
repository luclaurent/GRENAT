function K=getKK(obj)
if isempty(obj.KK)||obj.requireRun||obj.requireUpdate
    K=obj.updateMatrix();
else
    K=obj.KK;
end
end