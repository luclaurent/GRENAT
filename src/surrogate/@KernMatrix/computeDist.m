%compute inter-points distances
        function distC=computeDist(obj)
            distC=obj.sampling(obj.iX.iXsampling(:,1),:)-obj.sampling(obj.iX.iXsampling(:,2),:);
            obj.distC=distC;
        end