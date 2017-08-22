        %display the gradients approximated by the metamodel
        function showGrad(obj,nbG)
            %default value
            if nargin==1;nbG=1:size(obj.nonsampleGrad,3);end
            for itG=1:numel(nbG)
                obj.confDisp.title=(['Approximated gradients /x' num2str(nbG(itG))]);
                displaySurrogate(obj.nonsamplePts,obj.nonsampleGrad(:,:,nbG(itG)),obj.sampling,obj.resp,obj.grad,obj.confDisp);
            end
        end