function K=getKKdd(obj)
            obj.fGrad;
            obj.fIX;
            if isempty(obj.KKd)||obj.requireRun||obj.requireUpdate
                [~,~,K]=obj.updateMatrix();
            else
                K=obj.KKdd;
            end
        end